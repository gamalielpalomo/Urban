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
	bool showLuciasMap;
	
	bool showAsfaltoStreet;
	bool showConcretoStreet;
	bool showEmpedradoStreet;
	bool showPavimentadoStreet;
	bool showTerraceriaStreet;
	bool showNoEspecificadoStreet;
	
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
	
	//Test variables
	list<road> road_elements;
	list<road> road_gis_data;
	list<gis_data> gis_data_elements;
	
	//filter for obtaining only the roads from the osm file
	//creation of an osm file which will contain the roads of the city
	//file<geometry> roads_file <- file<geometry>(osm_file("/miramar/0525/miramar.osm"));
	file<geometry> suburbs_file <- osm_file("/miramar/Suburbs/Miramar-suburbs-0521.osm");
	//file places_file <- file("/miramar/0525/miramar-places.shp");
	
	
	//TEST-ONLY GIS FILES
	file<geometry> roads_file <- osm_file("/miramar/0409/miramar040918.osm");
	//file roads_file <- file("/miramar/0528/condiciondecalles/Condicion calles/Condicion_de_calles.shp"); 
	file street_conditions_file <- file("/miramar/0528/condiciondecalles/Condicion calles/Condicion_de_calles.shp"); 
	file zapopan_file <- file("miramar/0528/Calles_Nomenclatura/Calles_Nomenclatura.shp");
	file places_file <- file("/miramar/0515/miramar051518-places.shp");
	geometry shape <- envelope(roads_file);
	//file<geometry> osm_file <- file<geometry>(osm_file("/miramar/0525/miramar.osm"));
	//file osm_file <- file("/miramar/0525/miramar.shp");
	//file<geometry> osm_file <- file<geometry>(osm_file("/tijuana/tijuana-042418.osm"));
	//This shp file is used to make the bounders for the simulation area
	//file places_shp <- file("/miramar/0515/miramar051518-places.shp");
	//file places_shp <- file("/tijuana/tijuana-042418.shp");
	
	
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
		
		//Create osm agents that will be used as roads
		create osm_agent from:roads_file with: [highway_str::string(read("highway")),name_str::string(read("name"))];
		ask osm_agent{
				
				if(highway_str != nil and highway_str != "turning_circle"){
					//write name_str;
					create road with: [shape::shape, type:: highway_str, name_str:: name_str]{
						self.condition <- "NO ESPECIFICADO";
						add self to: road_elements;
					}
					
				}
			do die;
		}
		road_network <- as_edge_graph(road);
		
		//Create osm agents that will be used as places
		create osm_agent from: places_file with: [amenity::string(read("amenity")), highway_str::string(read("highway")), power_str::string(read("power")), name_strs::string(read("name"))];
		ask osm_agent{
			//if(highway_str = nil or (highway_str != nil and highway_str != "traffic_signals" and highway_str != "turning_circle") and power_str != "tower"){
			if(amenity != nil and (amenity="school" or amenity="college" or amenity="university" or amenity="social_facility" or amenity="kindergarten")){
				//Here we create spaces for each osm_agent with the "amenity" feature as one of the values "school", "kindergarten", "college", "university", "social_facilty"
				create places number:1 with: [shape::shape, amenity::amenity];
				//create places with: [shape::shape, type:: highway_str];
			}
		}		
		
		
		//Integrate the streets conditions according with the data given by the experts
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
			else{
				condition_str <- "NO ESPECIFICADO";
			}
		}
		//road_elements <- road where(lower_case(each.name_str)="prolongación avenida guadalupe" or lower_case(each.name_str)="avenida guadalupe");
		gis_data_elements <- gis_data where (lower_case(each.name_str)="guadalupe" or lower_case(each.name_str)="guadalupe prolongacion");
		
		//road_network <- as_edge_graph(gis_data);
		
		if gis_data = nil{
			write "gis_data_elements nil";
		}
		if road_elements = nil{
			write "road_elements nil";
		}
		/*
		loop element over:road_elements{
			if one_of(gis_data_elements where(each overlaps element)) != nil{
				write "OVERLAP!!";
			}
			else if one_of(gis_data_elements where(each partially_overlaps element)) != nil{
				write "PARTIALLY OVERLAP!!";
			}
			else{
				write "no overlaps";
			}
		}*/
		int counter <- 0;
		list<gis_data> noCoincidence;
		list<gis_data> coincidence;
		loop element over: gis_data{
			string lowerCaseName <- lower_case(element.name_str);
			//suburb LaFlorestaDelColli <- one_of(suburb where (each.name_str="La Floresta del Colli"));
			road tmpRoad <- one_of(road_elements where(lower_case(each.name_str)=lowerCaseName));
			if tmpRoad != nil{
				write tmpRoad.name_str + " = " + lowerCaseName;
				//save lowerCaseName to: "Coincidence" type:text rewrite:false;
				add element to: coincidence;
				counter <- counter+1;
			}
			else{
				add element to: noCoincidence;
			}
		}
		write "Coincidences = " + counter + " of " + length(gis_data);
		write "No coincidences = " + length(noCoincidence);
		/*loop element over: noCoincidence{
			save lower_case(element.name_str) to: "noCoincidence" type:text rewrite:false;
		}*/
		
		//Here we make the elements from both lists to coincide and load the road elements with condition feature
		loop element over: road_elements{
			gis_data tmpGisData <- one_of(coincidence where(lower_case(each.name_str)=lower_case(element.name_str)));
			element.condition <- tmpGisData.condition_str;
		}
		
		//Create suburb agents
		create suburb from: suburbs_file with: [name_str::string(read("name")),place::string(read("place")),population::int(read("population"))];
		loop s over:suburb{
		}
		
		//Create agents representing people
		numAgents <- 100;
		create people number:numAgents{
			add node(self) to: Encounters;
		}
		do updateGraph();
	}
}

species osm_agent{

	string name_str;
	string highway_str;
	string power_str;
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
	string name_str;
	string condition;
}

species gis_data{
	string name_str;
	string condition_str;
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
	point target;
	path shortestPath;
	
	init{
		interacting <- false;
		speed <- agentsSpeed;
		loop while: shortestPath = nil{
			do initLocationAndTarget;
			do updateShortestPath;
		}
		create targets number:1{
			location <- myself.target;
		}
		pEncounters <- [];
	}
	action updateShortestPath{
		shortestPath <- path_between(road_network, location, target);
	}
	
	action initLocationAndTarget{
		int selection <- rnd(2);
		suburb LaFlorestaDelColli <- one_of(suburb where (each.name_str="La Floresta del Colli"));
		suburb miramar <- one_of(suburb where (each.name_str="Miramar"));
		suburb SantaAnaTepetitlan <- one_of(suburb where (each.name_str="Santa Ana Tepetitlán"));
		
		if selection = 0{
			location <- LaFlorestaDelColli.location;
		}
		else if selection = 1{
			location <- miramar.location;
		}
		else {
			location <- SantaAnaTepetitlan.location;
		}
		location <- any_location_in(one_of(places));
		target <- one_of(suburb).location;
	}
	
	reflex move{
		speed <- agentsSpeed;
		do follow path:shortestPath;
		//do goto target:target on:road_network recompute_path:false;
		if(location = target){
			target <- one_of(places).location;
			do updateShortestPath;
			loop while: shortestPath = nil{
				target <- one_of(places).location;
				do updateShortestPath;
			}
			ask targets{
				location<-myself.target;
			}
		}
		pEncounters <- people at_distance(distanceForInteraction);
		if pEncounters != nil{interacting <- true;}else{interacting<-false;}
		if length(pEncounters) > 0{
			self.interacting <- true;
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
	
	parameter "perception" var: distanceForInteraction <- 0.0#m category:"Globals";
	parameter "speed" var:agentsSpeed <- 5.0 category:"Agents";
	parameter "Agents-size" var:agentsSize <- 20 category:"GUI";
	parameter "Edges-Width" var:edgesWidth <- 1 category:"GUI";
	//parameter "Streets-Width" var:streetWidth <- 1 category:"GUI";
	//parameter "Paths-Width" var:pathWidth <- 0 category:"GUI";
	parameter "Show People" var:showPeople <- true category: "GUI";
	parameter "Show Streets" var:showStreets <- true category:"GUI";
	parameter "Show Lucia's Map" var:showLuciasMap <- false category:"GUI";
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
				//data "mean" value:meanEncounters color: #blue;
			}
		}
		display display1 type:opengl ambient_light:60{
			//grid cell;
			//species road aspect:road_aspect;
			graphics "Roads" {
				if showStreets{
					if showAsfaltoStreet {
						loop element over: road_elements where (each.condition="ASFALTO"){
							draw element color: rgb(72, 161, 206) border:rgb(72, 161, 206);	
						}
					}
					if showConcretoStreet {
						loop element over: road_elements where (each.condition="CONCRETO"){
							draw element color: rgb(72, 161, 206) border:rgb(72, 161, 206);	
						}
					}
					if showEmpedradoStreet {
						loop element over: road_elements where (each.condition="EMPEDRADO"){
							draw element color: rgb(72, 161, 206) border:rgb(72, 161, 206);	
						}
					}
					if showPavimentadoStreet {
						loop element over: road_elements where (each.condition="PAVIMENTO"){
							draw element color: rgb(72, 161, 206) border:rgb(72, 161, 206);	
						}
					}
					if showTerraceriaStreet {
						loop element over: road_elements where (each.condition="TERRACERIA"){
							draw element color: rgb(72, 161, 206) border:rgb(72, 161, 206);	
						}
					}
					if showNoEspecificadoStreet {
						loop element over: road_elements where (each.condition="NO ESPECIFICADO"){
							draw element color: rgb(72, 161, 206) border:rgb(72, 161, 206);	
						}
					}
					
					//draw geometry(road_network.edges) color: rgb(72, 161, 206) border:rgb(72, 161, 206);
					/*loop element over: road_network.edges{
						draw geometry(element) color: rgb(72, 161, 206) border:rgb(72, 161, 206);
					}*/
				}
			}
			
			/*graphics "suburbs"{
				loop element over: suburb{
					draw geometry:square(100#m) color:rgb("RED") depth:200#m at: element.location;
				}
			}*/
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
			graphics "People"{
				if showPeople{
					loop element over: people{
						draw element geometry:circle(agentsSize) color:#mediumslateblue at:element.location;
					}
				}
			}
			//species places aspect:place_aspect transparency: 0.1;
			//species people aspect:sphere;
			
			//species targets aspect:targets_aspect;
					
		}
		display display2{
			graphics "Encounters Graph"{
				loop edge over: Encounters.edges{
					draw geometry(edge)+edgesWidth color: rgb(60, 140, 127) border: rgb(60, 140, 127);
				}
			}	
		}
		monitor "Agents interacting" value: people count(each.interacting=true);
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