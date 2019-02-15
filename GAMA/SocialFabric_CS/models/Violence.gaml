/***
* Name: Violence
* Author: gamalielpalomo
* Description: This GAMA model implements a ABM model for violence based on the Levy equation for movements.
* Tags: Tag1, Tag2, TagN
***/

model Violence

/* Insert your model definition here */

global torus:false{
	graph road_network;
	file<geometry> roads <- osm_file("/gis/centinela/centinela.osm");
	geometry shape <- envelope(roads);	
	init{
		create osm_agent from:roads with:[name_str::string(read("name")), type_str::string(read("highway"))]{
			if(type_str != nil and type_str != "" and type_str != "turning_circle" and type_str != "traffic_signals" and type_str != "bus_stop"){
				create road with: [shape::shape, type::type_str, name::name_str];
			}
			do die;
		}
		road_network <- as_edge_graph(road);
		create people number:100;
	}
}

species osm_agent{
	string name_str;
	string type_str;
}

species road{
	string name;
	string type;
}

species people skills:[moving]{
	point target;
	init{
		target 		<- any_location_in(one_of(road));
		location 	<- any_location_in(one_of(road));	
	}
	reflex move{
		do goto on:road_network target:target speed:5.0;
	}
}

experiment experiment1 type:gui{
	output{
		display display1 type:opengl{
			graphics "roads"{
				rgb road_Color <- rgb (199, 219, 241,255);
				loop element over:road{
					draw element color:road_Color;
				}
			}
			graphics "people"{
				loop element over:people{
					draw element geometry:sphere(20) color:rgb (240, 228, 11,255) at:element.location;
				}
			}
		}
	}
}