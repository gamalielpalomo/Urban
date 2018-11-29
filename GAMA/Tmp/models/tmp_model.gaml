/**
* Name: tmpmodel
* Author: gamaa
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model tmpmodel

/* Insert your model definition here */

global {
	int number_of_adults <- 50;
	int number_of_children <- 20; 
	int infected_adults;
	int infected_children;
	init{
		create adults number:number_of_adults;
		create children number:number_of_children;
	}
	reflex update{
		infected_adults <- adults count(each.is_infected = true);
		infected_children <- children count(each.is_infected = true);
	}
}
species adults skills:[moving]{
	bool is_infected <- false;
	aspect adult_aspect{
		draw circle(2) color: (is_infected)? #red : #green;
	}
	reflex moving{
		do wander;
	}
}
species children skills:[moving]{
	bool is_infected <- flip(0.5);
	int infect_range <- 5;
	aspect child_aspect{
		draw circle(1) color: (is_infected)? #red : #green;
	}
	reflex moving{
		do wander;
	}
	reflex spread when: !empty(adults at_distance infect_range){
		ask adults at_distance infect_range{
			if(self.is_infected){
				myself.is_infected <- true;
			}
			else if(myself.is_infected){
				self.is_infected <- true;
			}
		}
	}
}

experiment my_experiment type:gui{
	output{
		display chart{
			chart "Infection" type:series{
				data "Infected adults" value: infected_adults color:rgb(150, 27, 105);
				data "Infected children" value: infected_children color:rgb(41, 152, 160);
			}
		}
		display my_display type:opengl{
		 	species adults aspect: adult_aspect;
		 	species children aspect: child_aspect;
		}
		monitor "Infected adults" value: infected_adults;
		monitor "Infected children" value: infected_children;
	}
}