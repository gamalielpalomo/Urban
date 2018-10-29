/**
 *  crowds
 *  Author: gamaa
 *  Description: Model for social interactions in a city
 */

model crowds


global torus:false{
	
	int sumEncounters;
	int peopleInEncounter <- 0 update: people count (each.interacting); // this is the people that is in an encounter
	int acumEncounters;
	int meanEncounters;
	int timeStep;
	float worldDimension <- 100#m;
	float distanceForInteraction;
	graph road_network;
	bool connectedGraph;
	int numberOfPeople;
	list<int> peoplePerLink;
	
	geometry shape <- square(worldDimension);
	//geometry shape <- envelope(streets_shp);
	
	
	
	init{
		numberOfPeople <- 160;
		distanceForInteraction <- 30#m;
		create people number:numberOfPeople{
			point initialLocation <- {(0+rnd(worldDimension)),0+rnd(worldDimension)};
			location <- any_location_in(initialLocation) ;
		}
		loop times:numberOfPeople{
			add 0 to : peoplePerLink;
		}
		
	}
	
	reflex mainLoop{
		peoplePerLink <- nil;
		loop times:numberOfPeople{
			add 0 to : peoplePerLink;
		}
		ask people{
			peoplePerLink[self.links] <- peoplePerLink[self.links]+1;
		}
		write "Mean: "+mean(peoplePerLink);
		write "Sum: "+sum(peoplePerLink);
		save (peoplePerLink) to: "output" type: "text";
		do pause;
	}
	
}



species people skills:[moving]{
	bool interacting;
	int links;
	list<people> linkedPeople;
	init{
		links <- 0;
		interacting <- false;
			
	}
	
	reflex timeStep{
		linkedPeople <- people at_distance(distanceForInteraction);
		ask people at_distance(distanceForInteraction){
			draw polyline([self.location, myself.location]) color:#black;
			myself.interacting <- true;
			self.interacting <- true;
		}
		if length(linkedPeople) > 0{
			links <- length(linkedPeople);	
		}	
	}
	
	
	aspect name:standard_aspect{
		draw geometry:circle(5#m) color:#blue;					
	}
		
}

experiment simulation type:gui{
	output{
		display chart {
			/*chart "Encounters" type:series{
				data "encounters" value:peopleInEncounter color:#red;
				//data "mean" value:meanEncounters color: #blue;
			}*/
			chart "Degree of Connectivity" type:series{
				data "Agents" value:peoplePerLink color:#blue;
			}
		}
		monitor "number of encounters" value:sumEncounters;
		display display1{
			species people aspect:standard_aspect;
			//species targets aspect:targets_aspect;
		}
	}
}