/***
* Name: Violence
* Author: gamalielpalomo
* Description: This GAMA model implements a ABM model for violence based on the Levy equation for movements.
* Tags: Tag1, Tag2, TagN
***/

model Asaltos

global torus:false{
	int crimes;
	float mu parameter: 'Mu:' category: 'Model' <- 1.0 min: 0.0 max: 2.0; 
	graph road_network;
	file roads_file <- file("/gis/Zapopan/calles.shp");
	file blocks_file <- file("/gis/Zapopan/manzanas.shp");
	geometry shape <- envelope(roads_file);
		
	init{
		crimes <- 0;
		mu <- 1.0;
		create road from:roads_file with:[name_str::string(read("NOMVIAL"))];
		road_network <- as_edge_graph(road);
		create block from:blocks_file;
		create people number:500;
		create offender number: 50{
			do updateState();
		}
	}
}

species osm_agent{
	string name_str;
	string type_str;
}

grid cell width:world.shape.width/200 height:world.shape.height/200{
	int current_people_inside;
	int tension; //Tension is refered as the perception of security, and its value depends on social and environmental factors 
				 // such as crimes commited and physical layer conditions. 
	init{
		current_people_inside <- 0;
		tension <- 0;
	}
	reflex main{
		current_people_inside <- length(people inside self);
	}
	aspect crimeAttractiveAreas{
		draw shape color:rgb(current_people_inside*50, 0,0, 0+current_people_inside*50) border:rgb(current_people_inside*50, 0,0, 0+current_people_inside*50) ;	
	}
	aspect tension{
		draw shape color:rgb(tension*50, 0,0)  border:rgb(tension*50, 0,0) ;
	}
}

species road{
	string name_str;
	string type;
	
	aspect default{
		draw shape color:rgb (121, 121, 121,255);
	}
}

species block{
	aspect default{draw shape color: #slategray depth:30;}
}

species offender skills:[moving]{
	point target;
	int clusteringAttractivity;
	bool onTheWay;
	init{
		onTheWay <- false;
		clusteringAttractivity <- rnd(1,5);
		target <- any_location_in(one_of(road));
		location <- any_location_in(one_of(road));
	}
	reflex update{
		do updateState();
	}
	action updateState{
		if !onTheWay{
			list<cell> attractiveCells <- cell where (each.current_people_inside >= clusteringAttractivity);
			if length(attractiveCells)>0{
				cell selected <- one_of(attractiveCells);
				float delta <- distance_to(selected,self);
				float maxDistance <- sqrt(world.shape.width^2+world.shape.height^2);
				delta <- (delta/maxDistance)*100;
				//float pi <- delta/100;
				float pi <- delta^(-mu)*10;
				float rndVar <- rnd(100)/100;
				if(rndVar>pi){
					target <- selected.location;
					onTheWay <- true;
				}
			}
		}
	}
	reflex move{
		if(location = target or path_between(road_network,location,target)=nil){
			location <- location + 1; //sometimes it is not possible to find a path between the current agent and its target, move until it is foud.
			target <- any_location_in(one_of(road));
			do commitCrime;
			onTheWay <- true;
		}
		do goto on:road_network target:target speed:10.0;
	}
	action commitCrime{
		//cell currentCell <- one_of(cell at_distance(0));
		cell currentCell <- cell closest_to(self);
		people victim <- one_of(people at_distance(100));
		if(victim != nil and victim.victimized = false){
			victim.victimized <- true;
			currentCell.tension <- currentCell.tension + 1;
			crimes <- crimes + 1;
		}
	}
	aspect default{
		draw circle(25) color:rgb (255, 255, 0,255);
	}	
}

species people skills:[moving]{
	point target;
	bool victimized;
	init{
		victimized <- false;
		target 		<- any_location_in(one_of(road));
		location 	<- any_location_in(one_of(road));
	}
	reflex move{
		if(location = target or path_between(road_network,location,target)=nil){
			location <- location + 1;
			target <- any_location_in(one_of(road));
		}
		do goto on:road_network target:target speed:10.0;
	}
	
	aspect default{
		if (victimized = true){
	      draw circle(35) color:rgb (255, 0, 255,255) ;
		}
		else{
		  draw circle(15) color:rgb (10, 192, 83,255);	
		}
	}
}



experiment experiment1 type:gui{
	output{
		layout #split;
		display view type:opengl background:#black{
			species block refresh:false;
			species people trace:0;
			species offender trace:0;
		}
		display crime type:opengl background:#black{
			species cell aspect:crimeAttractiveAreas;
			//species road refresh:false;
		}
		display tension type:opengl background:#black{
			species cell aspect:tension;
			//species road refresh:false;
		}
		display chart background:#black{
			chart "Crimes" type:series{
				data "Crimes" value:crimes color:rgb (255, 0, 0,255);
			}
		}
	}
}