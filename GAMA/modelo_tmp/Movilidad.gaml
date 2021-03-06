/***
* Name: Movilidad
* Author: Gamaliel Palomo
* Description: Modelo para la movilidad dentro de una ciudad

* Tags: Tag1, Tag2, TagN
***/

model Movilidad

global torus:false{
	file archivoSHP_calles <- file("gis/Zapopan/calles.shp");
	file archivoSHP_manzanas <- file("gis/Zapopan/manzanas.shp");
	geometry shape <- envelope(archivoSHP_calles);
	graph red_de_calles;
	init{
		create calle from:archivoSHP_calles with:[nombre::string(read("NOMVIAL"))];	
		red_de_calles <- as_edge_graph(calle);
		create manzana from:archivoSHP_manzanas;
		create automovil number:3000;
	}
}

species calle{
	string nombre;
	aspect default{
		draw shape color:rgb (79, 135, 145,255) width:1.0;
	}
}

species manzana{
	aspect default{
		draw shape color:rgb (53, 146, 181,100) depth:10;
	}
}

grid cell width:world.shape.width/200 height:world.shape.height/200{
	int density;
	init{
		density <- 0;
	}
	reflex actualizar{
		density <- length(automovil inside self);
	}
	aspect default{
		draw shape color:rgb(density*50,0,0,0+density*100) ;
	}
}

species automovil skills:[moving]{
	string tipo;
	point target;
	init{
		location <- any_location_in(one_of(calle));
		target <- any_location_in(one_of(calle));
	}
	reflex caminar{
		if(location=target or path_between(red_de_calles,location,target)=nil){
			location <- location + 1;
			target <- any_location_in(one_of(calle));
		}
		if(length(automovil at_distance(15))>0){do goto on:red_de_calles target:target speed:1.0;}
		else {do goto on:red_de_calles target:target speed:10.0;}
	}
	aspect default{
		draw circle(10#m) color:rgb (255, 255, 0,255);
	}
}

experiment experimento1 type:gui{
	output{
		layout #split;
		display Principal type:opengl background:#black{
			species manzana aspect:default refresh:false;
			species automovil aspect:default;
		}
		display Trafico type:opengl background:#black{
			species calle aspect:default refresh:false;
			species cell aspect:default;
		}
	}
}