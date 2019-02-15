/***
* Name: Violence
* Author: gamalielpalomo
* Description: This GAMA model implements a ABM model for violence based on the Levy equation for movements.
* Tags: Tag1, Tag2, TagN
***/

model Violence

/* Insert your model definition here */

global torus:false{
	int crimes;
	graph road_network;
	file<geometry> roads <- osm_file("/gis/centinela/centinela.osm");
	geometry shape <- envelope(roads);	
	init{
		crimes <- 0;
		create osm_agent from:roads with:[name_str::string(read("name")), type_str::string(read("highway"))]{
			if(type_str != nil and type_str != "" and type_str != "turning_circle" and type_str != "traffic_signals" and type_str != "bus_stop"){
				create road with: [shape::shape, type::type_str, name::name_str];
			}
			do die;
		}
		road_network <- as_edge_graph(road);
		create people number:100;
	}
	reflex update{
		ask cell{
			do updateState;
		}
	}
}

species osm_agent{
	string name_str;
	string type_str;
}

grid cell width:10 height:10{
	int current_people_inside;
	int tension;
	rgb current_color; 
	init{
		current_color <- #black;
		current_people_inside <- 0;
		tension <- 0;
	}
	action updateState{
		current_people_inside <- length(people inside self);
		if(tension>0){
			current_color <- #red;
		}
	}
}

species road{
	string name;
	string type;
}

species people skills:[moving]{
	point target;
	int clusteringAttractivity;
	bool victimized;
	string state; // Walker or Offender
	rgb current_color;
	init{
		state <- "walker";
		victimized <- false;
		clusteringAttractivity <- rnd(8,9);
		target 		<- any_location_in(one_of(road));
		location 	<- any_location_in(one_of(road));
		current_color <- rgb (11, 157, 44,255);	
	}
	reflex updateState{
		list<cell> attractiveCells <- cell where (each.current_people_inside >= clusteringAttractivity);
		if(length(attractiveCells)>0){			
			cell selected <- one_of(attractiveCells);
			float distance <- distance_to(selected,self);
			float pi <- distance^(-2);
			float rndVar <- rnd(100) / 100;
			if(rndVar<pi){
				state <- "offender";
				target <- selected.location;
				current_color <- rgb (210, 23, 23,255);
			}
		}
	}
	reflex move{
		if(location = target or path_between(road_network,location,target)=nil){
			location <- location + 1;
			target <- any_location_in(one_of(road));
			current_color <- rgb (11, 157, 44,255);
		}
		do goto on:road_network target:target speed:5.0;
	}
	action commitCrime{
		cell current <- one_of(cell at_distance(0));
		people victim <- one_of(people where(one_of(cell at_distance(0)) = current));
		if(victim != nil){
			victim.victimized <- true;
			current.tension <- current.tension + 1;
		}
		crimes <- crimes + 1;
	}
}

experiment experiment1 type:gui{
	output{
		display scenario{
			graphics "grid"{
				loop element over:cell{
					draw rectangle(world.shape.width/10,world.shape.height/10) color:element.current_color at:element.location ;
				}
			}
			graphics "roads"{
				rgb road_Color <- rgb (121, 121, 121,255);
				loop element over:road{
					draw element color:road_Color width:2.0;
				}
			}
			graphics "people"{
				loop element over:people{
					draw circle(30) color:element.current_color at:element.location;
				}
			}
		}
		display chart{
			chart "Crimes" type:series{
				data "Crimes" value:crimes color:rgb (255, 0, 0,255);
			}
		}
	}
}