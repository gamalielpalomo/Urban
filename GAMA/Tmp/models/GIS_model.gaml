/**
* Name: GISmodel
* Author: gamaa
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model GISmodel

/* Insert your model definition here */

global{
	graph red_de_calles;
	
	file<geometry> calles <- osm_file("/gis/miramar.osm");
	file lugares <- file("/gis/miramar.shp");
	
	geometry shape <- envelope(calles);
	
	init{
		//Importamos del archivo GIS las formas que nos interesan y creamos agentes tipo calle
		create agente_osm from:calles with: [tipo::string(read("highway")),nombre::string(read("name"))];
		ask agente_osm{
				if(tipo != nil and tipo != "" and tipo != "turning_circle" and tipo != "traffic_signals" and tipo != "bus_stop"){
					create calle with: [shape::shape, tipo:: tipo, nombre::nombre];
					if self.nombre = nil{
						self.nombre <- "sin nombre";
					}
				}
			do die;
		}
		
		//Importamos del archivo GIS las formas que nos interesan y creamos agentes tipo calle
		create agente_osm from: lugares with: [tipo::string(read("amenity")), name_str::string(read("name"))]{
			if tipo != nil and tipo != "" or tipo != ""{
				create lugar with: [shape::shape, tipo::tipo, nombre::nombre];
			}
			do die;
		}
		
		//Pasos finales
		red_de_calles <- as_edge_graph(calle);
		int numAgentes <- 100;
		create people number:numAgentes;
		
	}
}

species agente_osm{
	string nombre;
	string tipo;
}
species calle{
	string nombre;
	string tipo;
	aspect basico{
		draw shape color:#silver;
	}
}
species lugar{
	string nombre;
	string tipo;
	aspect basico{
		draw geometry:square(60) color:rgb (86, 140, 158,255) depth:100;
	}
}
species people skills:[moving]{
	point objetivo;
	path camino;
	init{
		location <- any_location_in(one_of(lugar));
		objetivo <- any_location_in(one_of(lugar));
		camino <- path_between(red_de_calles, location, objetivo);
	}
	reflex move{
		do follow path:camino;
	}
	aspect esfera{
		draw sphere(10) color:#blue;
	}
}

experiment simulacion1 type:gui{
	output{
		display display1 type:opengl{
			species calle aspect:basico;
			species people aspect:esfera;
			species lugar aspect:basico;	
			
			//graphics "Lugares"{
			//	loop element over:lugar{
			//		draw geometry:square(60#m) color:rgb (86, 140, 158,255) border:#indigo at:element.location;
			//	}
			//}
			
		}
	}
}