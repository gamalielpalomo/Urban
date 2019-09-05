/**
 *  Social Fabric Model 
 *  Author: Gamaliel Palomo and Arnaud Grignard
 *  Description: Model for Social Fabric. This approach follows the idea that social interactions depend on the physical layer of an urban space. 
 * 				This means that if the infrastructure conditions (lightning, paving, etc) are good for an agent's perception, this will prefer to
 * 				walk through this space and it will feel confortable, and social interactions emerge as a result.
 */

model SocialFabric

global torus:false{

	//Model parameters 
	string studyCase;
	int experimentID;
	int numAgents;
	bool allowRoadsKnowledge;
	float agentSpeed; //This is the mean walk speed of a person.
	int agentSize <- 15;
	string outputFile;
	int interactionDistance;
	
	int timeStep;
	graph road_network;
	map<road, float> weight_map;
	list<int> usedRoads;
	float encountersSum<-0.0;

	date starting_date <- date([2019,7,1,20,0,0]);

	file roads_file <- file("/gis/"+studyCase+"/roads.shp");
	file blocks_file <- file("/gis/"+studyCase+"/blocks.shp");
	file block_fronts_file <- file("/gis/"+studyCase+"/block_fronts.shp");
	file places_file <- file("/gis/"+studyCase+"/places.shp");
	geometry shape <- envelope(roads_file);
	
	//string outputFile <- "/output/Encounters.txt";
	
	reflex output0 when: time=3600 and experimentID = 0{
		int tmpCounter <- 0;
		loop i from:0 to: length(usedRoads)-1{
			if usedRoads[i]=1{tmpCounter <- tmpCounter + 1;}
		}
		save tmpCounter type:text to:outputFile rewrite:false;
	}
	reflex output when: experimentID = 1 and time>0{
		encountersSum <- encountersSum + length(edge_agent);
		write encountersSum/time;
		if time=600{save encountersSum/time type:text to:outputFile rewrite:false;}
	}
	init{
		create block from:blocks_file with:[blockID::string(read("CVEGEO")), str_lightning::string(read("ALUMPUB_C"))]{
			if str_lightning = "Todas las vialidades"{ int_lightning <- 2; }
			else if str_lightning = "Alguna vialidad"{ int_lightning <- 1; }
			else{ int_lightning <- 0; }
		}
		create block_front from:block_fronts_file with:[block_frontID::string(read("CVEGEO")), int_lightning::int(read("ALUMPUB_")), int_paving::int(read("RECUCALL_")), int_sideWalk::int(read("BANQUETA_")), int_access::int(read("ACESOPER_"))]{ do init_condition; }
		create road from:roads_file{ do init_condition;	}
		create places from: places_file with:[id::string(read("id")),name_str::string(read("nom_estab"))];			
		weight_map <- road as_map(each::each.valuation);
		road_network <- as_edge_graph(road);
		usedRoads <- list_with(length(road_network),-1);
		create people number:numAgents;
	}
}


species road{
	string road_name;
	float valuation;
	float weight;
	int int_lightning;
	int int_paving;
	int int_sideWalk;
	int int_access;
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
	aspect default{draw shape color: rgb(255-(127*valuation),0+(127*valuation),50,255);}
	aspect gray{draw shape color: rgb (174, 174, 174,200);}
}

species block{
	string blockID;
	string str_lightning;
	int int_lightning;
	aspect default{	draw shape color: rgb(255-(127*int_lightning),0+(127*int_lightning),50,255) depth:rnd(30);}
	aspect simple{ draw shape color: rgb (218, 179, 61,120) depth:0;}
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

species places{
	string id;
	string name_str;
	float height;
	init{ height <- float(50+rnd(100)); }
	aspect default{ draw geometry:square(60#m)  color:rgb (86, 140, 158,255) border:#indigo depth:height; }
}

species targets{ aspect default{ draw geometry:triangle(agentSize#m) color:rgb("red"); } }

species people skills:[moving] parent: graph_node edge_species: edge_agent{
//species people skills:[moving]{
	int routineCount;
	point target;
	path shortestPath;
	map<road, float> roads_knowledge;
	list<places> routine;
	
	init{
		routineCount <- 0;
		roads_knowledge <- weight_map;
		speed <- agentSpeed;
		do buildRoutine;
		do updateTarget;
		loop while: shortestPath = nil or shortestPath = []{
				routine[routineCount] <- one_of(places);
				target <- routine[routineCount].location;
				do updateShortestPath;
		}
		create targets{ location <- myself.target; }
	}
	bool related_to(people other){
	  	using topology:topology(world) {return (self.location distance_to other.location < interactionDistance);}
	}
	action buildRoutine{ 
		add one_of(places) to:routine;
		location <- routine[0].location;
		loop times: 2{add one_of(places) to: routine;}
	}
	action updateTarget{
		if length(routine)-1 = routineCount{
			target <- routine[0].location;
			routineCount <- 0;
		}else{
			routineCount <- routineCount + 1;
			target <- routine[routineCount].location;	
		}
		do updateShortestPath;
	}
	action updateShortestPath{
		if allowRoadsKnowledge{ shortestPath <- path_between(road_network with_weights roads_knowledge, location, target); }
		else{ shortestPath <- path_between(road_network, location, target); }
	}
	reflex move{
		do follow path:shortestPath move_weights: shortestPath.edges as_map(each::each.perimeter);
		if(location = target){
			do updateTarget;
			loop while: shortestPath = nil or shortestPath = []{
				routine[routineCount] <- one_of(places);
				target <- routine[routineCount].location;
				do updateShortestPath;
			}
			ask targets{ location<-myself.target; }
		}
		
	}
	reflex prepareOutput when:experimentID=0{
		if current_edge!=nil and string(current_edge)!=""{
			string tmpStr <- replace(string(current_edge),"road(","");
			tmpStr <- replace(tmpStr,")","");
			int tmpInt <- int(tmpStr);
			if !(usedRoads contains tmpInt){usedRoads[tmpInt] <- 1;}
		}
	}
	aspect name:default{ draw geometry:circle(agentSize#m) color:rgb (255, 242, 9,255); }
}

species edge_agent parent: base_edge {aspect default {draw shape color:#blue;}}

experiment GUI type:gui{
	parameter "Experiment_ID" var:experimentID <- 2;
	parameter "Number_of_Agents" var:numAgents <- 500;
	parameter "Roads_Knowledge" var: allowRoadsKnowledge  <- false;
	parameter "Agents_Speed" var:agentSpeed <- 1.4;
	output{
		layout #split;
		display Main type:opengl ambient_light:50{
			species block aspect:default refresh:false;
			species people aspect:default;
		}
	}
}
experiment GUI_Encounters type:gui until:(time>3600){
	parameter "Output_File" var:outputFile <- "/output/Encounters.txt";
	parameter "Interaction_Distance" var:interactionDistance <- 200;
	parameter "Experiment_ID" var:experimentID <- 1;
	parameter "Number_of_Agents" var:numAgents <- 500;
	parameter "Roads_Knowledge" var: allowRoadsKnowledge  <- true;
	parameter "Agents_Speed" var:agentSpeed <- 1.4;
	output{
		display Main type:opengl ambient_light:50{
			species people aspect:default;
			species edge_agent aspect:default;
		}
	}
}
experiment Batch_Encounters type:batch repeat:100 keep_seed:true until:(time>600){
	parameter "Study_Case" var:studyCase <- "miramar";
	parameter "Output_File" var:outputFile <- "/output/Encounters.txt";
	parameter "Interaction_Distance" var:interactionDistance <- 100;
	parameter "Experiment_ID" var:experimentID <- 1;
	parameter "numAgents" var:numAgents <- 500;
	parameter "Roads_Knowledge" var: allowRoadsKnowledge  <- true;
	parameter "Agents_Speed" var:agentSpeed <- 1.4;
}
experiment Batch_StreetsUsage type:batch repeat:100 keep_seed:true until:(time>3600){
	parameter "Study_Case" var:studyCase <- "miramar";
	parameter "Output_File" var:outputFile <- "/output/StreetsUsage.txt";
	parameter "Experiment_ID" var:experimentID <- 0;
	parameter "numAgents" var:numAgents <- 500;
	parameter "Roads_Knowledge" var: allowRoadsKnowledge  <- true;
	parameter "Agents_Speed" var:agentSpeed <- 1.4;
}