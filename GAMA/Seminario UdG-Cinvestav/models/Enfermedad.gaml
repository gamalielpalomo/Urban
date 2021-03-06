/**
* Name: modelotmp
* Author: Gamaliel Palomo
* Description: Modelo acerca de propagacion enfermedades
* Tags: Tag1, Tag2, TagN
*/

model modelotmp

/* Insert your model definition here */

global{
	int num_ninos <- 50;
	int num_adultos <- 30;
	init{
		create adultos number:num_adultos;
		create ninos number:num_ninos;
	}
}
species adultos skills:[moving]{
	bool infectado <- false;
	reflex movimiento{
		do wander;
	}
	aspect basico{
		draw sphere(3) color: (infectado)? #red : #green;
	}
}
species ninos skills:[moving]{
	int rango <- 5;
	bool infectado <- flip(0.5);
	reflex movimiento{
		do wander;
	}
	aspect basico{
		draw circle(1) color: (infectado)? #red : #green;
	}
	reflex esparcir when: !empty(adultos at_distance rango){
		ask adultos at_distance rango{
			if(self.infectado){
				myself.infectado <- true;
			}
			else if(myself.infectado){
				self.infectado <- true;
			}
		}
	}
}
experiment experimento1 type:gui{
	output{
		display simulacion type:opengl{
			species adultos aspect: basico;
			species ninos aspect:basico;
		}
	}
}