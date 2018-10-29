/**
 *  crowds
 *  Author: gamaa
 *  Description: Model for social interactions in a city
 */

model crowds

/* Insert your model definition here */

global torus:false{
	
	int sumEncounters;
	int chartEncounters <- 0 update: people count (each.interacting);
	int acumEncounters;
	int meanEncounters;
	int timeStep;
	float worldDimension <- 1000#m;
	float distanceForInteraction;
	graph road_network;
<<<<<<< HEAD
	bool connectedGraph;
	
	file envelope_shp <- file("/miramar/0409/miramar040918-2.osm");
	map filter <- map("highway"::["tertiary", "residential"]);
	file<geometry> osm_file <- file<geometry>(osm_file("/miramar/0409/miramar040918-2.osm"));
	//file streets_shp <- file("/miramar/0408/miramar040818.shp");
=======
	
	file streets_shp <- file("/Shp/Miramar-streets-roads.shp");
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
	//file streets_shp <- file("/Proceced_SHP/Miramar-streets-roads.shp");
	//file streets_shp <- file("/miramar/zmg.shp");
	//file streets_shp <- file("/miramar/zona-centro.shp");
	//file streets_shp <- file("/MEX_rds/MEX_roads.shp");
	//file streets_shp <- file("/mxr/carre1mgw.shp");
	//file streets_shp <- file("/miramar/Geo-miramar-reduced.shp");
	//file streets_shp <- file("/miramar/miramar_reduced.shp");
	file places_shp <- file("/miramar/miramar-places_2.shp");
<<<<<<< HEAD
	
	//geometry shape <- square(worldDimension);
	geometry shape <- envelope(osm_file);
	
	reflex mainLoop{
		//if time >= 1000{do pause;}
	}
	init{
		distanceForInteraction <- 50#m;
		
		create osm_agent from:osm_file with: [highway_str::string(read("highway"))];
		ask osm_agent{
				if(highway_str != nil){
					create road with: [shape ::shape, type:: highway_str];
				}
			do die;
		}
		//create roads from: streets_shp;
		create places from: places_shp;
		road_network <- as_edge_graph(road);
		create people number:100{
			location <- any_location_in(one_of(road)) ;
		} 
		//write connected_components_of(road_network);
=======
	//map filter <- map("highway"::["primary", "secondary", "tertiary", "motorway", "living_street","residential", "unclassified"]);
	file<geometry> osmfile <- file<geometry> (osm_file("/miramar/miramar.osm"));
	
	//geometry shape <- square(worldDimension);
	geometry shape <- envelope(streets_shp);
	
	reflex mainLoop{
		if time >= 1000{do pause;}
	}
	init{
		distanceForInteraction <- 100#m;
		create roads from: streets_shp;
		create places from: places_shp;
		road_network <- as_edge_graph(streets_shp);
		create people number:1000{
			location <- any_location_in(one_of(places)) ;
		}
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
	}
	
}

<<<<<<< HEAD
species osm_agent{
	
	string highway_str;
	
}

species road {
	
	aspect road_aspect {
		draw shape color: rgb(51, 175, 148);
	}
	
}

species node_agent{
	
	string type;
	aspect default{
		draw square(3) color:#red;
=======
species roads{
	
	aspect road_aspect {
		draw shape color: rgb(171, 37, 178);
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
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
<<<<<<< HEAD
		draw geometry:square(50#m) color:buildingColor border:#gray depth:height;
=======
		draw geometry:square(50#m) color:buildingColor border:buildingColor depth:height;
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
	}
	init{
		spaceType <- rnd(3);
		if spaceType = 0{
			height <- float(rnd(5));
			buildingColor <- rgb(66, 134, 244);
		}		
		else if spaceType = 1{
			height <- float(40+rnd(40));
			buildingColor <- rgb(244, 244, 65);
		}
		else if spaceType = 2{
			height <- float(10+rnd(30));
			buildingColor <- rgb(96, 255, 96);
		}
		else if spaceType = 3{
			height <- float(30+rnd(50));
			buildingColor <- rgb(237, 28, 91);
		}
		
	}
}

species targets{
	aspect targets_aspect{
<<<<<<< HEAD
		draw geometry:triangle(30) color:rgb("red");
=======
		draw geometry:triangle(1000) color:rgb("red");
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
	}
}


species people skills:[moving]{
	bool interacting;
	float speed;
	point target;
<<<<<<< HEAD
	init{
		interacting <- false;
		speed <- 3.0;
		target  <- any_location_in(one_of(road));
		create targets number:1{
			location <- myself.target;
		}
=======
	
	init{
		interacting <- false;
		speed <- 5.0;
		target  <- any_location_in(one_of(places));
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
	}
	
	reflex move{
		interacting <- false;
<<<<<<< HEAD
		do goto target:target on:road_network;
		if(location = target){
			target <- any_location_in(one_of(road));
=======
		do goto target:target;
		if(location = target){
			target <- any_location_in(one_of(places));
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
			ask targets{
				location<-myself.target;
			}
		}
		ask people at_distance(distanceForInteraction){
			draw polyline([self.location, myself.location]) color:#black;
			myself.interacting <- true;
			self.interacting <- true;
		}
	}
	
	aspect name:standard_aspect{
<<<<<<< HEAD
		draw geometry:circle(30#m) color:#blue;					
=======
		draw geometry:circle(10#m) color:#blue;					
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
	}
	
	aspect sphere{
		draw sphere(10) color:#blue;
	}
	
}

experiment simulation type:gui{
	output{
		
		display display1 type:opengl ambient_light:150{
<<<<<<< HEAD
			species road aspect:road_aspect;
			species places aspect:place_aspect;
			//species targets aspect:targets_aspect;
			species people aspect:sphere;			
		}
		display chart {
			chart "Encounters" type:series{
				data "encounters" value:chartEncounters color:#red;
				//data "mean" value:meanEncounters color: #blue;
			}
		}/*
		display map background:#lightgray{
=======
			species roads aspect:road_aspect;
			species places aspect:place_aspect;
			species people aspect:sphere;			
		}
		/*display map background:#lightgray{
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
			graphics "edges" {
				loop edge over: road_network.edges {
					draw edge color: #black;
				}
 			}
<<<<<<< HEAD
		}
		
		monitor "number of encounters" value:sumEncounters;
		
		display display1{
			species road aspect:road_aspect;
			//species places aspect:place_aspect;
			species people aspect:standard_aspect;
			species targets aspect:targets_aspect;
=======
		}*/
		/*display chart {
			chart "Encounters" type:series{
				data "encounters" value:chartEncounters color:#red;
				//data "mean" value:meanEncounters color: #blue;
			}
		}*/
		monitor "number of encounters" value:sumEncounters;
		/*
		display display1{
			species roads aspect:road_aspect;
			species places aspect:place_aspect;
			species people aspect:standard_aspect;
			//species targets aspect:targets_aspect;
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
		}*/
	}
}