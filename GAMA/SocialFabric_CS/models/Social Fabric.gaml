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
	bool allowRoadsKnowledge <- true;
	float agentsSpeed <- 1.4; //This is the mean walk speed of a person.
	int agentsSize <- 5;
	
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
		seed <- 10.0;
		create block from:blocks_file with:[blockID::string(read("CVEGEO")), str_lightning::string(read("ALUMPUB_C"))]{
			if str_lightning = "Todas las vialidades"{ int_lightning <- 2; }
			else if str_lightning = "Alguna vialidad"{ int_lightning <- 1; }
			else{ int_lightning <- 0; }
		}
		create block_front from:block_fronts_file with:[block_frontID::string(read("CVEGEO")), int_lightning::int(read("ALUMPUB_")), int_paving::int(read("RECUCALL_")), int_sideWalk::int(read("BANQUETA_")), int_access::int(read("ACESOPER_"))]{ do init_condition; }
		create road from:roads_file{ do init_condition;	}
		/*string id;
	string name_str;
	string economic_activity; */
		create places from: places_file with:[id::string(read("id")),name_str::string(read("nom_estab"))];			
		weight_map <- road as_map(each::each.valuation);
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
	string road_name;
	float valuation;
	float weight;
	int int_lightning;
	int int_paving;
	int int_sideWalk;
	int int_access;
	float weight_value;
	action init_condition{
		valuation <- 0.0;
		list nearBlockFronts;
		nearBlockFronts <- block_front at_distance(50);
		if length(nearBlockFronts)>0{
			block_front tmpBlockFront <- one_of(nearBlockFronts);
			valuation <- tmpBlockFront.valuation;
			int_lightning <- tmpBlockFront.int_lightning;
			int_paving <- tmpBlockFront.int_paving;
			int_sideWalk <- tmpBlockFront.int_sideWalk;
			int_access <- tmpBlockFront.int_access;
			if int_access = 0{valuation <- 0.0;}
		}
		weight <- valuation / 2; //Normalization of valuation 0 to 1 according to the model
		weight <- 100*(1 - weight); //In weighted networks, a path is shorted than other if it has smaller value. 0 <- best road, 1 <- worst road
	}
	aspect default{
		draw shape color: rgb(255-(127*valuation),0+(127*valuation),50,255);
	}
	aspect gray{
		draw shape color: rgb (174, 174, 174,200);
	}
}

species block{
	string blockID;
	string str_lightning;
	int int_lightning;
	aspect default{	draw shape color: rgb(255-(127*int_lightning),0+(127*int_lightning),50,255) depth:rnd(30);}
	aspect simple{ draw shape color: rgb (218, 179, 61,255) depth:rnd(30);}
}

species block_front{
	string block_frontID;
	int int_lightning;
	int int_paving;
	int int_sideWalk;
	int int_access;
	float valuation;
	action init_condition{
		if int_lightning = 1 { int_lightning <-2; }
			else if int_lightning = 2 { int_lightning <- 0; }
			else{ int_lightning <- 1; }
			if int_paving = 1 or int_paving = 2 { int_paving <- 2; }
			else if int_paving = 2 { int_paving <- 0; }
			else{ int_paving <- 1; }
			if int_sideWalk = 1 {int_sideWalk <- 2;}
			else if int_sideWalk = 2 {int_sideWalk <- 0;}
			else {int_sideWalk <- 1;}
			if int_access = 2 {int_access <- 2;}
			else {int_access <- 0;}
			do init_Valuation;
	}
	action init_Valuation{
		valuation <- 0.0;
		int sum <- int_lightning + int_paving + int_sideWalk + int_access;
		valuation <- sum / 4;  
	}
	aspect default{	draw shape color: rgb(255-(127*int_lightning),0+(127*int_lightning),50,255); }
}

species gis_data{
	string name_str;
	string condition_str;
}

species places{
	string id;
	string name_str;
	string economic_activity;
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
	
	init{
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
		display Main type:opengl ambient_light:50{
			species block aspect:default refresh:false;
			species people aspect:default trace:0;
		}
		display Environment type:opengl{
			species road aspect:default refresh:false;
		}
		display Mobility type:opengl ambient_light:100{
			graphics "paths"{
				loop person over:people{
					if person.shortestPath != nil{draw person.shortestPath.shape color:rgb (255, 0, 128,255) width:2.0;}
				}
			}
			species road aspect:gray refresh:false;
			//species cell aspect:default refresh:false;
		}
	}
}