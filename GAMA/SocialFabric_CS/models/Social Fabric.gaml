/**
 *  Social Fabric Model 
 *  Author: Gamaliel Palomo and Arnaud Grignard
 *  Description: Model for Social Fabric. This approach follows the idea that social interactions depend on the physical layer of an urban space. 
 * 				This means that if the infrastructure conditions (lightning, paving, etc) are good for an agent's perception, this will prefer to
 * 				walk through this space and it will feel confortable, and social interactions emerge as a result.
 */

model SocialFabric

global torus:false{
	
	//Declaration of the global variables
	
	//Model parameters 
	int numAgents <- 500;
	bool allowRoadsKnowledge <- false;
	float agentsSpeed <- 5.0; //This is the mean walk speed of a person.
	int agentsSize <- 6;
	int edgesWidth <- 2;
	
	int sumEncounters;
	int chartEncounters <- 0 update: people count (each.interacting);
	int acumEncounters;
	int meanEncounters;
	int timeStep;
	float distanceForInteraction;
	graph road_network;
	map<road, float> weight_map;

	file roads_file <- file("/gis/test/test.shp");
	file blocks_file <- file("/gis/test/manzanas.shp");
	file block_fronts_file <- file("/gis/test/frente_de_manzanas.shp");
	file places_file <- file("/gis/test/interest.shp");
	geometry shape <- envelope(roads_file);
	
	//The graph for the representation of the relations between people in the physical space
	graph Encounters <- graph([]);
	float networkDensity <- 0.0;
	float maxNumOfEdges;
	
	
	reflex mainLoop{
		//do updateGraph();
		int stepEdges <- length(Encounters.edges);
		networkDensity <- stepEdges / maxNumOfEdges;
	}
	action updateGraph{
		Encounters <- graph([]);
		ask people{
			loop contact over:self.pEncounters{
				if !(Encounters contains_edge (self::contact)){ Encounters <- Encounters add_edge(self::contact); }
			}
		}
	}
	init{
		create block from:blocks_file with:[blockID::string(read("CVEGEO")), str_lightning::string(read("ALUMPUB_C"))]{
			if str_lightning = "Todas las vialidades"{ int_lightning <- 2; }
			else if str_lightning = "Alguna vialidad"{ int_lightning <- 1; }
			else{ int_lightning <- 0; }
		}
		create block_front from:block_fronts_file with:[block_frontID::string(read("CVEGEO")), int_lightning::int(read("ALUMPUB_")), int_paving::int(read("RECUCALL_"))]{
			if int_lightning = 1 { int_lightning <-2; }
			else if int_lightning = 2 { int_lightning <- 0; }
			else{ int_lightning <- 1; }
			if int_paving = 1 or int_paving = 2 { int_paving <- 2; }
			else if int_paving = 2 { int_paving <- 0; }
			else{ int_paving <- 1; }
		}
		ask cell{ do initialize(); }
		create road from:roads_file;
		create places from: places_file;			
		weight_map <- road as_map(each::each.weight_value);
		road_network <- as_edge_graph(road);
		create people number:numAgents{ add node(self) to: Encounters; }
		do updateGraph();
		maxNumOfEdges <- (numAgents * (numAgents - 1)) / 2;
	}
}

grid cell width:world.shape.width/100 height:world.shape.height/100{
	int attractivity;
	action initialize{
		attractivity <- 0;
		int result<-0;
		ask block_front inside self{
			result <- result + int_lightning;
		}
		if length(block_front inside self)>0 { attractivity <- int(result / length(block_front inside self)); }
		else{ attractivity <- 0; }
	}
	aspect default{
		draw shape color:rgb(0,100*attractivity,0,200);
	}
}

species road{
	string road_type;
	string name;
	string condition;
	float weight_value;
	aspect default{
		draw shape color: #silver;
	}
}

species block{
	string blockID;
	string str_lightning;
	int int_lightning;
	aspect default{	draw shape color: rgb(255-(127*int_lightning),0+(127*int_lightning),50,100) depth:5.0;}
	aspect simple{ draw shape color: rgb (218, 179, 61,255) depth:10;}
}

species block_front{
	string block_frontID;
	int int_lightning;
	int int_paving;
	aspect default{	draw shape color: rgb(255-(127*int_lightning),0+(127*int_lightning),50,255); }
}

species gis_data{
	string name_str;
	string condition_str;
}

species places{
	string name_str;
	string amenity;
	string place_str;
	float height;
	init{ height <- float(50+rnd(100)); }
	aspect default{ draw geometry:square(60#m)  color:rgb (86, 140, 158,255) border:#indigo depth:height; }
}

species targets{
	aspect targets_aspect{ draw geometry:triangle(agentsSize) color:rgb("red"); }
}

species people skills:[moving]{
	
	bool interacting;
	list pEncounters;
	point target;
	path shortestPath;
	map<road, float> roads_knowledge;
	
	string income;
	
	init{
		do initIncome;
		roads_knowledge <- weight_map;
		interacting <- false;
		speed <- agentsSpeed;
		do initLocationAndTarget;
		do updateShortestPath;
		loop while: shortestPath = nil{
			do initLocationAndTarget;
			do updateShortestPath;
		}
		create targets{
			location <- myself.target;
		}
		pEncounters <- [];
	}
	action updateShortestPath{
		if allowRoadsKnowledge{
			shortestPath <- path_between(road_network with_weights roads_knowledge, location, target);
		}
		else{
			shortestPath <- path_between(road_network, location, target);		
		}
	}
	
	action initIncome{
		int opt <- rnd(2);
		if opt = 0{income <- "low";}
		else if opt = 1{income <- "middle";}
		else {income <- "high";}
	}
	
	action initLocationAndTarget{
		
		location <- any_location_in(one_of(places));
		target <- one_of(places).location;
		
	}
	
	reflex move{
		speed <- agentsSpeed;
		do follow path:shortestPath move_weights: shortestPath.edges as_map(each::each.perimeter);
		if(location = target){
			target <- one_of(places).location;
			do updateShortestPath;
			loop while: shortestPath = nil or shortestPath = []{
				target <- one_of(places).location;
				do updateShortestPath;
			}
			ask targets{ location<-myself.target; }
		}
		
		pEncounters <- people at_distance(distanceForInteraction) where(each != self);
		if length(pEncounters) > 0{ self.interacting <- true; }
		else{ self.interacting<-false; }
	}
	
	aspect name:default{
		draw geometry:circle(agentsSize#m) color:rgb (255, 242, 9,255);			
	}	

}

experiment simulation type:gui{
	
	bool showPaths <- false;
	bool showInteractions <- false;
		
	output{
		layout #split;
		display Main type:opengl ambient_light:100{
			species block aspect:default refresh:false;
			//species block_front aspect:default refresh:false;
			//species places aspect:default;
			species people aspect:default trace:0;
		}
		display Environment type:opengl ambient_light:100{
			species road aspect:default refresh:false;
			species cell aspect:default refresh:false;
		}
	}
}