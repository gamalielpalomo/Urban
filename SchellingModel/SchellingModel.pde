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
  rows = height/cellSize;
  columns = width/cellSize;
  board = new int[rows][columns];
  cells = new ArrayList();
  freeCells = new ArrayList();
  
  for(int row = 0; row<rows; row++){
    for(int column = 0; column<columns; column++){
      int random = int(random(0,100));
      if(random<33){
        freeCells.add(new Cell(row,column,0,0f));
        board[row][column] = 0;
      }
      else if(random>=33 && random<66){
        /*float  rndmSatisfaction = int(random(0,100))/100f;
        cells.add(new Cell(row,column,1,rndmSatisfaction));*/
        cells.add(new Cell(row,column,1,0.6f));
        board[row][column] = 1;
      }
      else{
        /*float  rndmSatisfaction = int(random(0,100))/100f;
        cells.add(new Cell(row,column,2,rndmSatisfaction));*/
        cells.add(new Cell(row,column,2,0.6f));
        board[row][column] = 2;
      }
    }
  }
}
void draw(){
  delay(100);
  for(Cell element:freeCells){
    fill(color(255,255,255));
    rect(element.getRow()*cellSize,element.getColumn()*cellSize,cellSize,cellSize);
  }
  for(Cell element:cells){
    if(element.getType()==1)
      fill(color(255,0,0));
    else if(element.getType()==2)
      fill(color(0,0,255));
    rect(element.getRow()*cellSize,element.getColumn()*cellSize,cellSize,cellSize);
  }  
  updateScenario();
}
void updateScenario(){
  next = new ArrayList();
  for(Cell element:cells){
    if(getActualSatisfaction(element)<element.getSatisfaction()){
      moveCell(element);
    }
  }
}

float getActualSatisfaction(Cell cell){
  float result = 0;
  int row = cell.getRow();
  int column = cell.getColumn();
  float neighbors = 0;
  for(int r=-1; r<=1; r++){
    if((row+r>0)&&(row+r<rows)){
      for(int c=-1; c<=1; c++){
        if((column+c>0)&&(column+c<columns)){
          if(board[row+r][column+c]!=0)
            neighbors+=1;
          if(board[row+r][column+c]==cell.getType())
            result+=1;
        }
      }
        
    }
  }
  result = result - 1;
  if(neighbors == 0)
    return 1;
  return result/neighbors;
}

void moveCell(Cell cell){
  if(freeCells.size()>0){
    Cell freeCell = freeCells.get(0);
    freeCells.remove(0);
    freeCells.add(new Cell(cell.getRow(),cell.getColumn(),0,0));
    board[cell.getRow()][cell.getColumn()] = 0;
    cell.setRow(freeCell.getRow());
    cell.setColumn(freeCell.getColumn());
    board[cell.getRow()][cell.getColumn()] = cell.getType();    
  }
}