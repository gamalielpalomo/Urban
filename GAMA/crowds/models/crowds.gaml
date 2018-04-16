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
	
	map filter <- map("highway"::["tertiary", "residential"]);
	file<geometry> osm_file <- file<geometry>(osm_file("/miramar/0409/miramar040918.osm"));
	//file<geometry> osm_file <- file<geometry>(osm_file("/zona_centro/zona_centro.osm"));
	file places_shp <- file("/miramar/0409/miramar040818-2-places.shp");
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
		create places from: places_shp;
		road_network <- as_edge_graph(road);
		create people number:1000{
			location <- any_location_in(one_of(places)) ;
			target <- any_location_in(one_of(places));
		}
	}
}

species osm_agent{
	
	string highway_str;
	
}

species road {
	
	aspect road_aspect {
		draw shape color: rgb(3, 130, 173);
	}
	
}

species node_agent{
	
	string type;
	aspect default{
		draw square(3) color:#red;
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
	float speed;
	point target;
	init{
		interacting <- false;
		speed <- 3.0;
		target  <- any_location_in(one_of(places));
		create targets number:1{
			location <- myself.target;
		}
	}
	
	reflex move{
		interacting <- false;
		do goto target:target on:road_network;
		if(location = target){
			target <- any_location_in(one_of(places));
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
		draw geometry:circle(30#m) color:#blue;			
	}
	
	aspect sphere{
		draw sphere(10) color:#blue;
	}
	

}
experiment simulation type:gui{
	output{
		display chart {
			chart "Encounters" type:series{
				data "encounters" value:chartEncounters color:#red;
				//data "mean" value:meanEncounters color: #blue;
			}
		}
		display display1 type:opengl{
			image "/miramar/TIF/Geo-Miramar-Image-clear.tif";
			species road aspect:road_aspect;
			species people aspect:sphere;
			species places aspect:place_aspect transparency: 0.5;			
			//species targets aspect:targets_aspect;			
		}
		monitor "Current encounters" value:chartEncounters;
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
			species places aspect:place_aspect;
			species people aspect:standard_aspect;
			//species targets aspect:targets_aspect;
		}*/
	
	}
}