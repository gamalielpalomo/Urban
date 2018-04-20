/**
 *  crowds
 *  Author: gamaa
 *  Description: Model for social interactions in a city
 */

model crowds

global torus:false{
	
	//Declaration of the global variables
	int sumEncounters;
	int chartEncounters <- 0 update: people count (each.interacting);
	int acumEncounters;
	int meanEncounters;
	int timeStep;
	float worldDimension <- 1000#m;
	float distanceForInteraction;
	int current_hour update: (cycle / 60) mod 24;
	bool is_night <- true update: current_hour < 7 or current_hour > 20;
	graph road_network;
	
	//filter for obtaining only the roads from the osm file
	map filter <- map("highway"::["tertiary", "residential"]);
	//creation of an osm file which will contain the roads of the city
	file<geometry> osm_file <- file<geometry>(osm_file("/miramar/0409/miramar040918.osm"));
	//file<geometry> osm_file <- file<geometry>(osm_file("/miramar/colmena/colmena.osm"));
	//This shp file is used to make the bounders for the simulation area
	file places_shp <- file("/miramar/0409/miramar040818-2-places.shp");
	geometry shape <- envelope(places_shp);
	//The graph for the representation of the relations between people in the physical space
	graph Encounters <- graph([]);
	
	reflex mainLoop{
		string dataSpec <- string(cycle) + " -> " + "";
		do updateGraph();
		//if time >= 1000{do pause;}
	}
	action updateGraph{
		Encounters <- graph([]);
		ask people{
			loop contact over:self.pEncounters{
				if !(Encounters contains_edge (self::contact)){
					Encounters <- Encounters add_edge(self::contact);
				}
			}
		}
	}
	init{
		distanceForInteraction <- 30#m;
		
		create osm_agent from:osm_file with: [highway_str::string(read("highway"))];
		ask osm_agent{
				if(highway_str != nil){
					create road with: [shape ::shape, type:: highway_str];
				}
			do die;
		}
		
		create places from: places_shp;
		road_network <- as_edge_graph(road);
		//point init_location <- any_location_in(one_of(road));
		create people number:1000{
			//location <- init_location;			
			location <- any_location_in(one_of(road)) ;
			target <- any_location_in(one_of(road));
			//add the agent to the graph
			add node(self) to: Encounters;
		}
		do updateGraph();
	}
}



species osm_agent{
	
	string highway_str;
	
}

species road {
	
	aspect road_aspect {
		draw shape color: rgb(198, 59, 175);
	}
	
}



species places{
	//spaceType -> 0:square 1:mall 2:park 3:church
	int spaceType;
	list<string> spaceActivities;
	int size;
	rgb buildingColor;
	//float height <- 20.0 + rnd(100);
	float height;
	aspect place_aspect{
		draw geometry:square(50#m) color:buildingColor border:#gray depth:height;
	}
	init{
		spaceType <- rnd(3);
		if spaceType = 0{
			height <- float(20);
			buildingColor <- rgb(66, 134, 244);
		}		
		else if spaceType = 1{
			height <- float(60);
			buildingColor <- rgb(244, 244, 65);
		}
		else if spaceType = 2{
			height <- float(100);
			buildingColor <- rgb(96, 255, 96);
		}
		else if spaceType = 3{
			height <- float(120);
			buildingColor <- rgb(237, 28, 91);
		}
	}
}

species targets{
	aspect targets_aspect{
		draw geometry:triangle(30) color:rgb("red");
	}
}


species people skills:[moving]{
	bool interacting;
	list pEncounters;
	list sNetwork;
	float speed;
	point target;
	
	init{
		interacting <- false;
		speed <- 2.0;
		target  <- any_location_in(one_of(places));
		create targets number:1{
			location <- myself.target;
		}
		pEncounters <- [];
	}
	
	reflex move{
		interacting <- false;
		do goto target:target on:road_network;
		if(location = target){
			target <- any_location_in(one_of(road));
			ask targets{
				location<-myself.target;
			}
		}
		pEncounters <- people at_distance(distanceForInteraction);
		if length(pEncounters) > 0{
			self.interacting <- true;
			/*loop contact over:pEncounters{
				if !(Encounters contains_edge (self::contact)){
					Encounters << edge (self, contact);	
				}
			}*/
		}
		else{
			self.interacting<-false;
		}
	}
	
	aspect name:standard_aspect{
		draw geometry:circle(30#m) color:#blue;			
	}
	
	aspect sphere{
		draw sphere(15) color:#blue;
	}
	

}
species Encounters_link{
	
	aspect default{
		draw shape color: #red;
	}
	
}

experiment simulation type:gui{
	parameter "perception" var: distanceForInteraction <- 100#m category:"Simple types";
	output{
		display chart {
			chart "Encounters" type:series{
				data "Agents interacting" value:chartEncounters color:rgb(150, 27, 105);
				data "Encounters" value:length(Encounters.edges) color:rgb(41, 152, 160);
				//data "mean" value:meanEncounters color: #blue;
			}
		}
		display display1 type:opengl ambient_light:80{
			//grid cell;
			species road aspect:road_aspect;
			species people aspect:sphere;
			graphics "Encounters Graph"{
				loop edge over: Encounters.edges{
					draw edge color: rgb(60, 140, 127) size:10#m;
				}			
			}
			
			species places aspect:place_aspect transparency: 0.5;
			//species targets aspect:targets_aspect;			
		}
		monitor "Current encounters" value:chartEncounters;
		monitor "Vertices in graph" value: length(Encounters.vertices);
		monitor "Edges in graph" value: length(Encounters.edges);
		monitor "people0 interacting:" value: people[0].interacting;
		monitor "people1 interacting:" value: people[1].interacting;
		/*
		display map background:#lightgray{
			graphics "edges" {
				loop edge over: road_network.edges {
					draw edge color: #black;
				}
			}
		}
		
		monitor "number of encounters" value:sumEncounters;
		
		display display1{
			species road aspect:road_aspect;
			//species places aspect:place_aspect;
			species people aspect:standard_aspect;
			species Encounters_link;
			//species targets aspect:targets_aspect;
		}*/
	
	}
}