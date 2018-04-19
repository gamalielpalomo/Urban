/**
 *  graphexample2
 *  Author: gamaa
 *  Description: 
 */

model graphexample2

global{
	int number_of_agents <- 5;
	init {
		create graph_agent number:number_of_agents;
	}
}

species graph_agent parent: graph_node edge_species: edge_agent skills:[moving]{
	reflex main{
		do wander;
	}
  bool related_to(graph_agent other){
  	return true;
  }
  aspect base {
  	draw circle(1) color:#green;
  }
}

species edge_agent parent: base_edge {
	aspect base {
  	draw shape color:#blue;
  }
}

experiment MyExperiment type: gui {
    output {
        display MyDisplay type: java2D {
            species graph_agent aspect:base;
            species edge_agent aspect:base;
        }
    }
}