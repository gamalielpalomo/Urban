import java.util.ArrayList;

int cellSize;
int rows;
int columns;
int types;
ArrayList<Cell> freeCells;
ArrayList<Cell> cells;
ArrayList<Cell> next;
int [][]board;

void setup(){
  //Graphic initialization
  size(600,600);
  
  //Simulation variables
  cellSize = 20;
  types = 2;
  
  //Board building
  board = new int[rows][columns];
  cells = new ArrayList();
  freeCells = new ArrayList();
  rows = height/cellSize;
  columns = width/cellSize;
  for(int row = 0; row<rows; row++){
    for(int column = 0; column<columns; column++){
      int random = int(random(0,100));
      if(random<33){
        freeCells.add(new Cell(row,column,0));
        board[row][columns] = 0;
      }
      else if(random>=33 && random<66){
        cells.add(new Cell(row,column,1));
        board[row][column] = 1;
      }
      else{
        cells.add(new Cell(row,column,2));
        board[row][column] = 2;
      }        
    }
  }
}
void draw(){
  delay(100);
  for(Cell element:freeCells){
    noFill();
    rect(element.getRow()*cellSize,element.getColumn()*cellSize,cellSize,cellSize);
  }
  for(Cell element:cells){
    if(element.getType()==1)
      fill(color(255,0,0));
    else if(element.getType()==2)
      fill(color(0,0,255));
    rect(element.getRow()*cellSize,element.getColumn()*cellSize,cellSize,cellSize);
  }  
}
void updateScenario(){
  next = new ArrayList();
  for(Cell element:cells){
    
  }
}

int getSatisfaction(Cell cell){
  int result = 100;
  int row = cell.getRow();
  int column = cell.getColumn();
  int type = cell.getType(); 
  for(int r=-1; r<=1; r++){
        for(int c=-1; c<=1; c++)
          result += board[row+r][column+c];
  }
  return result;
}