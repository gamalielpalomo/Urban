/**
 *  crowds
 *  Author: gamaa
 *  Description: Model for social interactions in a city
 */

model crowds

/* Insert your model definition here */

global torus:false{
	
	int sumEncounters;
	int meanEncounters;
	float worldDimension <- 1000#m;
	graph road_network;
	
	//file streets_shp <- file("/Shp/Miramar-streets-roads.shp");
	file streets_shp <- file("/Proceced_SHP/Miramar-streets-roads.shp");
	//file streets_shp <- file("/miramar/zmg.shp");
	//file streets_shp <- file("/miramar/zona-centro.shp");
	//file streets_shp <- file("/MEX_rds/MEX_roads.shp");
	//file streets_shp <- file("/mxr/carre1mgw.shp");
	//file streets_shp <- file("/miramar/Geo-miramar-reduced.shp");
	//file streets_shp <- file("/miramar/miramar_reduced.shp");
	file places_shp <- file("/miramar/miramar-places_2.shp");
	//map filter <- map("highway"::["primary", "secondary", "tertiary", "motorway", "living_street","residential", "unclassified"]);
	file<geometry> osmfile <- file<geometry> (osm_file("/miramar/miramar.osm"));
	
	geometry shape <- square(worldDimension);
	//geometry shape <- envelope(streets_shp);
	
	reflex writeDebug{
		//write sumEncounters;
		//write meanEncounters;
	}
	init{
		create roads from: streets_shp;
		create places from: places_shp;
		road_network <- as_edge_graph(streets_shp);
		create people number:1000;
		//write road_network.connected;
	}
	
}

species roads{
	
	aspect road_aspect {
		//draw shape color: rgb(196, 94, 172);
		draw shape color: rgb(171, 37, 178);
	}
	
}

species places{
	float height <- 20.0 + rnd(100);
	aspect place_aspect{
		draw geometry:square(50#m) color:rgb("gray") depth:height;
	}
}

species targets{
	aspect targets_aspect{
		draw geometry:triangle(1000) color:rgb("red");
	}
}

species people skills:[moving]{
	float socialization;
	float speed <- 1.0;
	point target <- {rnd(worldDimension),rnd(worldDimension)};
	//point targetPnt <- {rnd(worldDimension), rnd(worldDimension)};
	//point target <- targetPnt;
	aspect name:standard_aspect{
		draw geometry:circle(10#m) color:#blue;					
	}
	aspect sphere{
		draw sphere(5) color:#blue;
	}
	init{
		/*create targets number:1{
			location <- myself.target;
		}*/
		/*point center <- {rnd(worldDimension),rnd(worldDimension)};
		location <- center;*/
	}
	reflex move{
		/*location <- location + {1,1};
		float x <- location.x;
		float y <- location.y;
		if location.x > worldDimension{
			x <- 0.0;
		}
		if location.y > worldDimension{
			y <- 0.0;
		}
		location <- {x,y};
		do move;*/
		do goto target:target;
		if(location = target){
			target <- {rnd(worldDimension),rnd(worldDimension)};
			//targetPnt <- {rnd(worldDimension), rnd(worldDimension)};
			//target <- any_location_in(one_of(roads));
			//target <- targetPnt;
			ask targets{
				location<-myself.target;
			}
			write "Target reached";
		}
	}
}

experiment simulation type:gui{
	output{
		
		/*display display1 type:opengl ambient_light:150{
			//species roads aspect:road_aspect;
			//species places aspect:place_aspect;
			species people aspect:sphere;
		}*/
		display display1{
			//species roads aspect:road_aspect;
			//species places aspect:place_aspect;
			species people aspect:standard_aspect;
			//species targets aspect:targets_aspect;
		}
	}
}