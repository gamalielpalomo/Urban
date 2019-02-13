/**
* Name: gistmp
* Author: gamaa
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model gistmp

global{
	graph red_de_calles;
	file<geometry> calles <- osm_file("/gis/miramar.osm");
	file lugares <- file("/gis/miramar.shp");
	
	geometry shape <- envelope(calles);
	
	init{
		create agente_osm from:calles with: [tipo::string(read("highway")),nombre::string(read("name"))];
		ask agente_osm{
			if(tipo != nil and tipo!="" and tipo != "turnig_circle" and tipo != "traffic_signals" and tipo != "bus_stop"){
				create calle with:[shape::shape, tipo::tipo, nombre::nombre];
				if self.nombre = nil{
					self.nombre <- "S/N";
				}
			}
			do die;
		}
		
		create agente_osm from:lugares with:[tipo::string(read("amenity")), nombre::string(read("name"))]{
			if tipo!= nil and tipo!="" or tipo != ""{
				create lugar with: [shape::shape, tipo::tipo, nombre::nombre];
			}
			do die;
		}
	
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
	bool iluminada;
	string nombre;
	string tipo_material;
	aspect basico{
		draw shape color:#silver;
	}
}
species lugar{
	string nombre;
	string colonia;
	string tipo;
	aspect basico{
		draw geometry:square(60) color:rgb(86,140,158,255) depth:100;
	}
}
species people skills:[moving]{
	point objetivo;
	path camino;
	init{
		location <- any_location_in(one_of(lugar));
		objetivo <- any_location_in(one_of(lugar));
		camino <- path_between(red_de_calles,location,objetivo);
	}
	reflex move{
		do follow path:camino;
	}
	aspect basico_esfera{
		draw sphere(10) color:#white;
	}
}

experiment simulation type:gui{
	output{
		display display1 type:opengl{
			species calle aspect:basico;
			species people aspect:basico_esfera;
			species lugar aspect:basico;
		}
	}
}
