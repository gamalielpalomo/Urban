/**
 *  crowds
 *  Author: gamaa
 *  Description: Model for social interactions in a city
 */

model crowds

global torus:false{
	
	//Declaration of the global variables
	
	//Simulation parameters 
	int numAgents <- 0;
	float agentsSpeed;
	int agentsSize;
	int streetWidth;
	int edgesWidth;
	int pathWidth;
	bool showPeople;
	bool showPaths;
	bool showStreets;
	
	bool lockStreetRefresh;
	
	//
	
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
	file<geometry> suburbs_file <- file<geometry>(osm_file("/miramar/Suburbs/Miramar-suburbs-0521.osm"));
	file<geometry> osm_file <- file<geometry>(osm_file("/miramar/0409/miramar040918.osm"));
	//file<geometry> osm_file <- file<geometry>(osm_file("/tijuana/tijuana-042418.osm"));
	//This shp file is used to make the bounders for the simulation area
	//file places_shp <- file("/miramar/0515/miramar051518-places.shp");
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
		
		//Create osm agents that will be used as roads
		create osm_agent from:osm_file with: [highway_str::string(read("highway")),name::string(read("name"))];
		ask osm_agent{
				if(highway_str != nil and highway_str != "turning_circle"){
					create road with: [shape ::shape, type:: highway_str];
				}
			do die;
		}
		
		//Create osm agents that will be used as places
		create osm_agent from: osm_file with: [amenity::string(read("amenity")), highway_str::string(read("highway")), power_str::string(read("power")), name::string(read("name"))];
		ask osm_agent{
			//if(highway_str = nil or (highway_str != nil and highway_str != "traffic_signals" and highway_str != "turning_circle") and power_str != "tower"){
			if(amenity != nil and (amenity="school" or amenity="college" or amenity="university" or amenity="social_facility" or amenity="kindergarten")){
				//Here we create spaces for each osm_agent with the "amenity" feature as one of the values "school", "kindergarten", "college", "university", "social_facilty"
				create places number:1 with: [shape::shape, amenity::amenity];
				//create places with: [shape::shape, type:: highway_str];
			}
		}		
		road_network <- as_edge_graph(road);
		//point init_location <- any_location_in(one_of(road));
		
		//Create suburb agents
		create suburb from: suburbs_file with: [name::string(read("name")),place::string(read("place")),population::int(read("population"))];
		
		loop s over:suburb{
			write s;
		}
		
		//Create agents representing people
		create people number:numAgents{
			//location <- init_location;			
			//location <- any_location_in(one_of(places)) ;
			int selection <- rnd(2);
			suburb LaFlorestaDelColli <- one_of(suburb where (each.name="La Floresta del Colli"));
			suburb miramar <- one_of(suburb where (each.name="Miramar"));
			suburb SantaAnaTepetitlan <- one_of(suburb where (each.name="Santa Ana Tepetitlán"));
			if selection = 0{
				location <- LaFlorestaDelColli.location;
			}
			if selection = 1{
				location <- miramar.location;
			}
			if selection = 2{
				location <- SantaAnaTepetitlan.location;
			}
			target <- any_location_in(one_of(places));
			//add the agent to the graph
			add node(self) to: Encounters;
		}
		do updateGraph();
	}
}

species suburb{
	string name;
	string place;
	int population;
}

species osm_agent{
	
	string name;	
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
		//write amenity;
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
		draw geometry:triangle(agentsSize) color:rgb("red");
	}
}


species people skills:[moving]{
	bool interacting;
	list pEncounters;
	list sNetwork;
	float speed;
	point target;
	path shortestPath;
	
	init{
		interacting <- false;
		speed <- 0.01+rnd(agentsSpeed);
		create targets number:1{
			location <- myself.target;
		}
		shortestPath <- path_between (road_network, location, target);
		pEncounters <- [];
	}
	
	action updateShortestPath{
		shortestPath <- path_between(road_network, location, target);
	}
	
	reflex move{
		speed <- 0.01+rnd(agentsSpeed);
		interacting <- false;
		do follow path:shortestPath;
		//do goto target:target on:road_network recompute_path:false;
		if(location = target){
			target <- any_location_in(one_of(places));
			ask targets{
				location<-myself.target;
			}
			do updateShortestPath;
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
		draw circle(agentsSize) color:#blue;
	}
	

}
experiment simulation type:gui{
	parameter "perception" var: distanceForInteraction <- 200#m category:"Globals";
	parameter "speed" var:agentsSpeed <- 1.0 category:"Agents";
	parameter "Agents-size" var:agentsSize <- 30 category:"GUI";
	parameter "Edges-Width" var:edgesWidth <- 1 category:"GUI";
	//parameter "Streets-Width" var:streetWidth <- 1 category:"GUI";
	//parameter "Paths-Width" var:pathWidth <- 0 category:"GUI";
	parameter "Show People" var:showPeople <- true category: "GUI";
	parameter "Show Streets" var:showStreets <- true category:"GUI";
	parameter "Show Paths" var:showPaths <- false category:"GUI";
	output{
		display chart {
			chart "Encounters" type:series{
				data "Agents interacting" value:chartEncounters color:rgb(150, 27, 105);
				data "Encounters" value:length(Encounters.edges) color:rgb(41, 152, 160);
				//data "mean" value:meanEncounters color: #blue;
			}
		}
		display display1 type:opengl ambient_light:60{
			//grid cell;
			graphics "Roads"{
				if showStreets{
					draw geometry(road_network.edges) color: rgb(72, 161, 206) border:rgb(72, 161, 206);
				}
				/*loop element over: road_network.edges{
					draw geometry(element)+streetWidth color: rgb(72, 161, 206) border:rgb(72, 161, 206);
				}*/
			}
			graphics "suburbs"{
				loop element over: suburb{
					draw geometry:square(100#m) color:rgb("RED") depth:200#m at: element.location;
				}
			}
			graphics "shortestPath"{
				if showPaths{
					loop element over: people{
						draw geometry:triangle(agentsSize+3) color:rgb("red") at:element.target;
						if element.shortestPath != nil{
							/*loop seg over:element.shortestPath.edges{
								draw seg color: rgb(249, 246, 57) border:rgb(249, 246, 57);	
							}*/
							draw geometry(element.shortestPath.shape) color: rgb(249, 246, 57) border:rgb(249, 246, 57);
						}
					}
				}
			}
			//species road aspect:road_aspect;
			graphics "People"{
				if showPeople{
					loop element over: people{
						draw element geometry:circle(agentsSize) color:rgb(68, 150, 10) at:element.location;
					}
				}
			}
			species places aspect:place_aspect transparency: 0.1;
			//species people aspect:sphere;
			
			//species targets aspect:targets_aspect;
			graphics "Encounters Graph"{
				loop edge over: Encounters.edges{
					draw geometry(edge)+edgesWidth color: rgb(60, 140, 127) border: rgb(60, 140, 127);
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