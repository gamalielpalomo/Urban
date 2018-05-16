/**
 *  crowds
 *  Author: gamaa
 *  Description: Model for social interactions in a city
 */

model crowds

global torus:false{
	
	//Declaration of the global variables
	
	//Globals for agents 
	
	int numAgents <- 0;
	float agentsSpeed;
	int agentsSize;
	
	
	int sumEncounters;
	int chartEncounters <- 0 update: people count (each.interacting);
	int acumEncounters;
	int meanEncounters;
	int timeStep;
	float distanceForInteraction;
	int current_hour update: (cycle / 60) mod 24;
	bool is_night <- true update: current_hour < 7 or current_hour > 20;
	graph road_network;
	
	//filter for obtaining only the roads from the osm file
	map filter <- map("highway"::["tertiary", "residential"]);
	//creation of an osm file which will contain the roads of the city
	file<geometry> osm_file <- file<geometry>(osm_file("/miramar/0409/miramar040918.osm"));
	//file<geometry> osm_file <- file<geometry>(osm_file("/tijuana/tijuana-042418.osm"));
	//This shp file is used to make the bounders for the simulation area
	file places_shp <- file("/miramar/0515/miramar051518-places.shp");
	//file places_shp <- file("/tijuana/tijuana-042418.shp");
	geometry shape <- envelope(osm_file);
	//The graph for the representation of the relations between people in the physical space
	graph Encounters <- graph([]);
	int density <- 0;
	int maxNumOfEdges;
	
	reflex mainLoop{
		string dataSpec <- string(cycle) + " -> " + "";
		do updateGraph();
		//if time >= 1000{do pause;}
		int stepEdges <- length(Encounters.edges);
		
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
		//distanceForInteraction <- 100#m;
		numAgents <- 500;
		create osm_agent from:osm_file with: [highway_str::string(read("highway"))];
		ask osm_agent{
				if(highway_str != nil and highway_str != "turning_circle"){
					create road with: [shape ::shape, type:: highway_str];
				}
			do die;
		}
		
		create osm_agent from: places_shp with: [amenity::string(read("amenity")), highway_str::string(read("highway")), power_str::string(read("power"))];
		ask osm_agent{
			//if(highway_str = nil or (highway_str != nil and highway_str != "traffic_signals" and highway_str != "turning_circle") and power_str != "tower"){
			if(amenity != nil and (amenity="school" or amenity="college" or amenity="university" or amenity="social_facility")){
				//Here we create spaces for each osm_agent with the "amenity" feature as one of the values "school", "kindergarten", "college", "university", "social_facilty"
				create places number:1 with: [shape::shape, amenity::amenity];
				//create places with: [shape::shape, type:: highway_str];
			}
		}		
		road_network <- as_edge_graph(road);
		//point init_location <- any_location_in(one_of(road));
		create people number:numAgents{
			//location <- init_location;			
			location <- any_location_in(one_of(road)) ;
			target <- any_location_in(one_of(places));
			//add the agent to the graph
			add node(self) to: Encounters;
		}
		do updateGraph();
	}
}



species osm_agent{
	
	string highway_str;
	string power_str;
	string amenity;
}

species road {
	
	aspect road_aspect {
		draw shape color: rgb(198, 59, 175);
	}
	
}



species places{
	//spaceType -> 0:square 1:mall 2:park 3:church
	string amenity;
	list<string> spaceActivities;
	int size;
	rgb buildingColor;
	//float height <- 20.0 + rnd(100);
	float height;
	aspect place_aspect{
		draw geometry:square(50#m) color:buildingColor border:#gray depth:height;
	}
	init{
		write amenity;
		//spaceType <- rnd(3);
		if amenity = "school"{
			height <- float(20);
			buildingColor <- rgb(66, 134, 244); //Blue
		}		
		else if amenity = "kindergarten"{
			height <- float(60);
			buildingColor <- rgb(244, 244, 65); //Yellow
		}
		else if amenity = "college"{
			height <- float(100);
			buildingColor <- rgb(96, 255, 96); //Green
		}
		else if amenity = "University"{
			height <- float(120);
			buildingColor <- rgb(237, 28, 91); //Magenta
		}
		else if amenity = "social_facility"{
			height <- float(150);
			buildingColor <- rgb("red");
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
		speed <- agentsSpeed;
		create targets number:1{
			location <- myself.target;
		}
		pEncounters <- [];
	}
	
	reflex move{
		speed <- agentsSpeed;
		interacting <- false;
		do goto target:target on:road_network;
		if(location = target){
			//target <- any_location_in(one_of(road));
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
		draw geometry:circle(agentsSize#m) color:#blue;			
	}
	
	aspect sphere{
		draw sphere(agentsSize) color:#blue;
	}
	

}
species Encounters_link{
	
	aspect default{
		draw shape color: #red;
	}
	
}

experiment simulation type:gui{
	parameter "perception" var: distanceForInteraction <- 200#m category:"Globals";
	parameter "speed" var:agentsSpeed <- 10.0 category:"Agents";
	parameter "size" var:agentsSize <- 30 category:"Agents";
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
			species places aspect:place_aspect transparency: 0.6;
			species people aspect:sphere;
			//species targets aspect:targets_aspect;
			graphics "Encounters Graph"{
				loop edge over: Encounters.edges{
					draw edge color: rgb(60, 140, 127);
				}
			}			
		}
		monitor "Agents interacting" value:chartEncounters;
		monitor "Vertices in graph" value: length(Encounters.vertices);
		monitor "Edges in graph" value: length(Encounters.edges);
		/*
		display display1{
			species road aspect:road_aspect;
			//species places aspect:place_aspect;
			species people aspect:standard_aspect;
			species Encounters_link;
			//species targets aspect:targets_aspect;
		}*/
	
	}
}