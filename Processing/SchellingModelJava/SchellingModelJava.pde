import java.util.ArrayList;
//Simulation variables
int cellSize;
int rows;
int columns;
int types;
int gridSize;
int nSize;
float satisfied;


ArrayList<Cell> freeCells;
ArrayList<Cell> cells;
int [][]board;

void setup(){
  
 
  //Graph window
  /*String []args = {"Output data"};
  Graph output = new Graph();
  PApplet.runSketch(args,output);*/
  
  //Graphic initialization
  size(900,900);
  //fullScreen();
  
  
  //Simulation variables
  cellSize = 2;
  types = 2;
  nSize = 5;
  
  //Board building  
  rows = height/cellSize;
  columns = width/cellSize;
  gridSize = columns*rows;
  board = new int[rows][columns];
  cells = new ArrayList();
  freeCells = new ArrayList();
  
  for(int row = 0; row<rows; row++){
    for(int column = 0; column<columns; column++){
      int random = int(random(0,100));
      if(random<50){
        freeCells.add(new Cell(row,column,0,0f));
        board[row][column] = 0;
      }
      else if(random>=50 && random<75){
        //float  rndmSatisfaction = int(random(20,100))/100f;
        cells.add(new Cell(row,column,1,0.5f));
        board[row][column] = 1;
      }
      else{
        //float  rndmSatisfaction = int(random(0,50))/100f;
        cells.add(new Cell(row,column,2,0.5f));
        board[row][column] = 2;
      }
    }
  }
}
void draw(){
  delay(300);
  for(Cell element:freeCells){
    fill(color(255,255,255));
    rect(element.getRow()*cellSize,element.getColumn()*cellSize,cellSize,cellSize);
  }
  for(Cell element:cells){
    if(element.getType()==1)
      fill(color(142,49,49));
    else if(element.getType()==2)
      fill(color(53,191,181));
    rect(element.getRow()*cellSize,element.getColumn()*cellSize,cellSize,cellSize);
  }
  /*System.out.println("size(cells) -> "+cells.size());
  satisfied = (gridSize-cells.size());
  satisfied = satisfied / gridSize;
  System.out.println("Satisfied cells -> "+(gridSize-cells.size())+"/"+gridSize+" ("+satisfied*100+" %)");
  if(cells.size()>0)*/
    updateScenario();
  //else 
    //System.out.println("COMPLETED");
}
void updateScenario(){
  //ArrayList<Cell> unsatisfied = new ArrayList();
  for(Cell element:cells){
    if(getActualSatisfaction(element)<element.getSatisfaction()){
      moveCell(element);
      //unsatisfied.add(element);
    }
  }
  //cells = new ArrayList(unsatisfied);
}

float getActualSatisfaction(Cell cell){
  float result = 0;
  int row = cell.getRow();
  int column = cell.getColumn();
  float neighbors = 0;
  for(int r=-nSize; r<=nSize; r++){
    if((row+r>=0)&&(row+r<rows)){
      for(int c=-nSize; c<=nSize; c++){
        if((column+c>=0)&&(column+c<columns)){
          if(board[row+r][column+c]!=0)
            neighbors+=1;
          if(board[row+r][column+c]==cell.getType())
            result+=1;
        }
      }
        
    }
  }
  result = result - 1;
  neighbors = neighbors - 1;
  if(neighbors == 0)
    return 1;
  return result/neighbors;
}

void moveCell(Cell cell){
  if(freeCells.size()>0){
    int index = int(random(0,freeCells.size()-1));
    Cell freeCell = freeCells.get(index);
    freeCells.remove(index);
    freeCells.add(new Cell(cell.getRow(),cell.getColumn(),0,0));
    board[cell.getRow()][cell.getColumn()] = 0;
    cell.setRow(freeCell.getRow());
    cell.setColumn(freeCell.getColumn());
    board[cell.getRow()][cell.getColumn()] = cell.getType();    
  }
}