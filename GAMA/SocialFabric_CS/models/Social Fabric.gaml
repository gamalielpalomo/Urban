/**
 *  crowds
 *  Author: Gamaliel Palomo
 *  Description: Model for social interactions in a city
 */

model SocialFabric

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
	bool showInteractions;
	bool showPaths;
	bool showPlaces;
	bool showSuburbs;
	bool showStreets;
	bool showLuciasMap;
	
	bool showAsfaltoStreet;
	bool showConcretoStreet;
	bool showEmpedradoStreet;
	bool showPavimentadoStreet;
	bool showTerraceriaStreet;
	bool showNoEspecificadoStreet;
	
	bool allowRoadsKnowledge;
	
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
	list<places> suburbs;
	map<road, float> weight_map;
	
	//Test variables
	list<road> road_elements;
	list<road> road_gis_data;
	list<gis_data> gis_data_elements;
	
	// ______ Zapopan Geo Info  ________________
	//file<geometry> roads_file <- osm_file("/gis/miramar/miramar.osm");
	file roads_file <- file("/gis/test/test.shp");
	file street_conditions_file <- file("/gis/miramar/Condicion_de_calles.shp"); 
	file places_file <- file("/gis/miramar/miramar-places.shp");
	file<geometry> suburbs_file <- osm_file("/gis/miramar/Miramar-suburbs.osm");
	geometry shape <- envelope(roads_file);
	
	//The graph for the representation of the relations between people in the physical space
	graph Encounters <- graph([]);
	float networkDensity <- 0.0;
	float maxNumOfEdges;
	
	
	reflex mainLoop{
		do updateGraph();
		int stepEdges <- length(Encounters.edges);
		networkDensity <- stepEdges / maxNumOfEdges;
		string dataSpec <- string(cycle) + "," + distanceForInteraction + "," +allowRoadsKnowledge+ "," +stepEdges + "," + networkDensity + "," + stepEdges + "," + maxNumOfEdges;
		save dataSpec to: "output" rewrite:false;
		int res <- int(cycle/250);
		int module <- cycle-(res * 250);
		if module = 0{
			write "timeStep: "+cycle;
			do pause;
		}		
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
		
		allowRoadsKnowledge <- false;
		
		//Create osm agents that will be used as ROADS
		//create osm_agent from:roads_file with: [highway_str::string(read("highway")),name_str::string(read("name"))];
		create road from:roads_file;
		/*ask osm_agent{
			
				if(highway_str != nil and highway_str != "" and highway_str != "turning_circle" and highway_str != "traffic_signals" and highway_str != "bus_stop"){
					
					create road with: [shape::shape, road_type:: highway_str, name:: name_str];
					//create road;
					if self.name_str = nil{
						self.name_str <- "no_name";
					}
					
				}
			do die;
		}*/
		
		//Create osm agents that will be used as PLACES
		
		create osm_agent from: places_file with: [amenity::string(read("amenity")), name_str::string(read("name")), place_str::string(read("place"))]{
			if amenity != nil and amenity != "" or place_str != ""{
				create places with: [shape::shape, amenity::amenity, name_str::name_str,place_str::place_str]{
					if place_str = "neighbourhood" or place_str = "suburb"{
						add(self) to: suburbs;
					}
				}
			}
			do die;
		}
		write "Places: " + length(places-suburbs);
		write "Suburbs: " + length(suburbs);
		//Integrate the streets conditions according with the DATA GIVEN BY EXPERTS 
		//Here we extract the information from the shapefile and search the recently created streets objects, we look for a coincidence in the name and load the condition feature
		create gis_data from:street_conditions_file with: [name_str::string(read("NOMBRE")),condition_str::string(read("CONDICION"))]{
			if condition_str = "A"{
				condition_str <- "ASFALTO";
			}
			else if condition_str = "C"{
				condition_str <- "CONCRETO";
			}
			else if condition_str = "E"{
				condition_str <- "EMPEDRADO";
			}
			else if condition_str = "P"{
				condition_str <- "PAVIMENTO";
			}
			else if condition_str = "T"{
				condition_str <- "TERRACERIA"; 
			}
			else {
				condition_str <- "CNE";
			}
		}
		
		int counter <- 0;
		list<gis_data> noCoincidence;
		list<road> coincidence;
		
		
		/*ask road{
	
			self.condition <- "CNE";
			list<gis_data> coincidences <- gis_data where(lower_case(each.name) = lower_case(self.name));
			if length(coincidences) > 0 {
				
				gis_data gis_data_element <- one_of(coincidences);
				self.condition <- gis_data_element.condition_str;
				add self to: coincidence;
				
				if self.condition = "ASFALTO"{
					self.weight_value <- 10.0;
				}
				else if self.condition = "PAVIMENTO"{
					self.weight_value <- 10.0;
				}
				else if self.condition = "CONCRETO"{
					self.weight_value <- 10.0;
				}
				else if self.condition = "EMPEDRADO"{
					self.weight_value <- 60.0;
				}
				else if self.condition = "TERRACERIA"{
					self.weight_value <- 100.0;
				}
				else if self.condition = "CNE"{
					self.weight_value <- 1000.0;
				}
				counter <- counter + 1;
				
				//write self.name_str + ":" + self.weight;
			}
			else{
				self.weight_value <- 1000.0;
			}
			
		}*/
		
		
		weight_map <- road as_map(each::each.weight_value);
		
		//road_network <- as_edge_graph(road) with_weights weight_map;
		road_network <- as_edge_graph(road);
		write "Coincidences = " + counter + " of " + length(gis_data);
		
		//Create suburb agents
		create suburb from: suburbs_file with: [name_str::string(read("name")),place::string(read("place")),population::int(read("population"))];
		//Create agents representing people
		numAgents <- 500;
		create people number:numAgents{
			add node(self) to: Encounters;
		}
		do updateGraph();
		maxNumOfEdges <- (numAgents * (numAgents - 1)) / 2;
	}
}

species osm_agent{

	string name_str;
	string highway_str;
	string place_str;
	string amenity;
	string condition;
}

species suburb{
	string name_str;
	string place;
	int population;
}

species road {
	string road_type;
	string name;
	string condition;
	float weight_value;
	aspect standard{
		draw shape color: #silver;
	}
}

species gis_data{
	string name_str;
	string condition_str;
}

species places{
	string name_str;
	string amenity;
	string place_str;
	float height;
	init{
		height <- float(50+rnd(100));
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
	point target;
	path shortestPath;
	map<road, float> roads_knowledge;
	
	string income;
	
	init{
		do initIncome;
		roads_knowledge <- weight_map;
		interacting <- false;
		speed <- agentsSpeed;
		do initLocationAndTarget;
		do updateShortestPath;
		loop while: shortestPath = nil{
			do initLocationAndTarget;
			do updateShortestPath;
		}
		create targets{
			location <- myself.target;
		}
		pEncounters <- [];
	}
	action updateShortestPath{
		if allowRoadsKnowledge{
			shortestPath <- path_between(road_network with_weights roads_knowledge, location, target);
		}
		else{
			shortestPath <- path_between(road_network, location, target);		
		}
	}
	
	action initIncome{
		int opt <- rnd(2);
		if opt = 0{income <- "low";}
		else if opt = 1{income <- "middle";}
		else {income <- "high";}
	}
	
	action initLocationAndTarget{
		
		location <- any_location_in(one_of(places));
		target <- one_of(places).location;
		
	}
	
	reflex move{
		speed <- agentsSpeed;
		
		do follow path:shortestPath move_weights: shortestPath.edges as_map(each::each.perimeter);
		
		if(location = target){
			target <- one_of(places).location;
			do updateShortestPath;
			loop while: shortestPath = nil or shortestPath = []{
				target <- one_of(places).location;
				do updateShortestPath;
			}
			ask targets{
				location<-myself.target;
			}
		}
		
		pEncounters <- people at_distance(distanceForInteraction) where(each != self);
		if length(pEncounters) > 0{
			self.interacting <- true;
		}
		else{
			self.interacting<-false;
		}
	}
	
	aspect name:standard_aspect{
		draw geometry:circle(agentsSize#m) color:rgb (73, 220, 48,255);			
	}
	
	aspect sphere{
		draw circle(agentsSize) color:#blue;
	}
	

}

experiment simulation type:gui{
	
	
	parameter "perception" var: distanceForInteraction <- 50.0#m category:"Agents";
	parameter "speed" var:agentsSpeed <- 5.0 category:"Agents";
	parameter "Agents-size" var:agentsSize <- 5 category:"Agents";
	parameter "Edges-Width" var:edgesWidth <- 3 category:"Agents";
	parameter "Show People" var:showPeople <- true category: "GUI";
	parameter "Show Interactions" var:showInteractions <- true category: "GUI";
	parameter "Show Streets" var:showStreets <- true category:"GUI";
	parameter "Show Places" var:showPlaces <-true category:"GUI";
	parameter "Show Suburbs" var:showSuburbs <-false category:"GUI";
	parameter "Show Paths" var:showPaths <- false category:"GUI";
	parameter "Asfalto" var:showAsfaltoStreet <- true category: "STREETS";
	parameter "Concreto" var:showConcretoStreet <- true category: "STREETS";
	parameter "Empedrado" var:showEmpedradoStreet <- true category: "STREETS";
	parameter "Pavimento" var:showPavimentadoStreet <- true category: "STREETS";
	parameter "Terraceria" var:showTerraceriaStreet <- true category: "STREETS";
	parameter "No Especificado" var:showNoEspecificadoStreet <- true category: "STREETS";
	
	output{
		display chart {
			chart "Encounters" type:series{
				data "Agents interacting" value:chartEncounters color:rgb(150, 27, 105);
				data "Encounters" value:length(Encounters.edges) color:rgb(41, 152, 160);
				data "Network density" value: networkDensity color: rgb (32, 142, 77,255);
				//data "mean" value:meanEncounters color: #blue;
			}
		}
		display display1 type:opengl ambient_light:60{
			//grid cell;
			species road aspect:standard;
			
			
			graphics "Places" refresh:false{
				if showPlaces{
					loop element over:places - suburbs{
						draw geometry:square(60#m) color:rgb (86, 140, 158,255) border:#indigo depth:element.height at:element.location;
					}
					//species places aspect:place_aspect refresh:false transparency: 0.1;
				}
				
			}
			
			graphics "Suburbs"{
				if showSuburbs{
					loop element over:suburbs{
						draw geometry:circle(60#m) color:#chocolate border:#chocolate depth:10#m at: element.location;
					}	
				}
			}
			
			graphics "shortestPath" {
				if showPaths{
					loop element over: people{
						draw geometry:circle(agentsSize) color:rgb (136, 53, 32,255) at:element.target;
						if element.shortestPath != nil{
							draw geometry(element.shortestPath.shape) color:rgb (136, 53, 32,255) border:rgb(249, 246, 57);
						}
					}
				}
			}
			
			species people aspect:standard_aspect;
			
			/*graphics "Encounters Graph"{
				if showInteractions{
					loop edge over: Encounters.edges{
						draw geometry(edge)+edgesWidth color: rgb (0, 0, 0,255) border: rgb(60, 140, 127);
					}
				}
				
			}*/
			//species targets aspect:targets_aspect;
					
		}
		monitor "Agents interacting" value: people count(each.interacting=true);
		monitor "Network density" value: networkDensity;
		monitor "Vertices in graph" value: length(Encounters.vertices);
		monitor "Edges in graph" value: length(Encounters.edges);
		monitor "Vertices in road" value: length(road_network.vertices);
		monitor "Edges in road" value: length(road_network.edges);
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