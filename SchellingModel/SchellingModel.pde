import java.util.ArrayList;

int cellSize;
int rows;
int columns;
int types;
ArrayList freeCells;
ArrayList cells;


void setup(){
  //Graphic initialization
  size(600,600);
  
  //Simulation variables
  cellSize = 20;
  types = 2;
  
  //Board building
  cells = new ArrayList();
  freeCells = new ArrayList();
  rows = height/cellSize;
  columns = width/cellSize;
  for(int row = 0; row<rows; row++){
    for(int column = 0; column<columns; column++){
      int random = int(random(0,100));
      if(random<33)
        freeCells.add(new Cell(row,column,0));
      else if(random>=33 && random<66)
        cells.add(new Cell(row,column,1));
      else
        cells.add(new Cell(row,column,2));
    }
  }
}
void draw(){
  delay(100);
  
}