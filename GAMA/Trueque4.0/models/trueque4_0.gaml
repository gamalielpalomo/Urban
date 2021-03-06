/**
* Name: trueque40
* Author: gamaa
* Description: This is a model designed
* Tags: Tag1, Tag2, TagN
*/

model trueque40

/* Insert your model definition here */

global{
	graph roads_network;
	
	file<geometry> roads <- osm_file("/gis/miramar.osm");
	file places <- file("/gis/miramar.shp");
	
	geometry shape <- envelope(roads);
	
	init{
		//Importamos del archivo GIS las formas que nos interesan y creamos agentes type street
		create agente_osm from:roads with: [type::string(read("highway")),name::string(read("name"))];
		ask agente_osm{
				if(type != nil and type != "" and type != "turning_circle" and type != "traffic_signals" and type != "bus_stop"){
					create street with: [shape::shape, type:: type, name::name];
					if self.name = nil{
						self.name <- "sin name";
					}
				}
			do die;
		}
		
		//Importamos del archivo GIS las formas que nos interesan y creamos agentes type place
		create agente_osm from:places with: [type::string(read("amenity")), name::string(read("name"))]{
			if type != nil and type != "" or type != ""{
				create place with: [shape::shape, type::type, name::name];
			}
			do die;
		}
		
		//Pasos finales
		roads_network <- as_edge_graph(street);
		int numAgentes <- 300;
		create people number:numAgentes;
		
	}
}

species agente_osm{
	string name;
	string type;
}
species street{
	string name;
	string type;
	aspect basic{
		draw shape color:#silver;
	}
}
species place{
	string name;
	string type;
	aspect basic{
		draw geometry:square(60) color:rgb (86, 140, 158,255) depth:100;
	}
}
species people skills:[moving]{
	point target;
	item carrying;
	path path_to_follow;
	image_file icon;
	init{
		location <- any_location_in(one_of(place));
		target <- any_location_in(one_of(place));
		path_to_follow <- path_between(roads_network, location, target);
		int tmp_rnd <- rnd(100);
		if tmp_rnd < 25{
			icon <- file("img/rc.png");	
		}else if tmp_rnd >= 25 and tmp_rnd < 75{
			icon <- file("img/food.png");
		}
		else{
			icon <- file("img/item.png");
		}
		
	}
	reflex move{
		do follow path:path_to_follow;
		if(location=target){
			target <- any_location_in(one_of(place));
			path_to_follow <- path_between(roads_network, location, target);
		}
	}
	aspect icon{
		draw icon size:30;	
	}
	aspect esfera{
		draw sphere(10) color:#blue;
	}
}

species item{
	string type;
	point location;
	image_file icon;
	init{
		if (type="medicine"){
			icon <- file("img/rc.png");
		} 
	}
	aspect base{
		draw square(5) color:rgb(150, 27, 105);
	}
	aspect icon{
		draw icon;	
	}
}

experiment simulacion1 type:gui{
	output{
		display display1 type:opengl{
			species street aspect:basic;
			species people aspect:icon;
			species place aspect:basic;	
			
		}
	}
}