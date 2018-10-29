import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.data.GeoJSONReader;
import de.fhpotsdam.unfolding.data.Feature;
import de.fhpotsdam.unfolding.marker.Marker;
import de.fhpotsdam.unfolding.data.ShapeFeature;
import de.fhpotsdam.unfolding.marker.SimpleLinesMarker;

UnfoldingMap map;
PImage bg;
int columns, rows;
int [][] board;
int [][] next;
int w;

void setup() {
  //Graphic initialization
  size(800, 600, P2D);
  w = 10;
  
  //Bidimensional arrays initialization
  columns = width/w;
  rows = height/w;
  bg = loadImage("GdlMap.png");
  board = new int [columns][rows];
  next = new int [columns][rows];
  
  System.out.println("Columns: "+columns);
  System.out.println("Rows: "+rows);
  
  for(int column = 0; column < columns; column++){
    for(int row = 0; row<rows; row++){
      //int randomNumber = int(random(2));
      if(int(random(0,100))>50)
        board[column][row] = 1;
      else 
        board[column][row] = 0;
    }
  }
  
}

void draw() {
  delay(100);
  background(bg);
  for (int i = 0; i<columns; i++){
    for ( int j=0; j<rows; j++){
      if((board[i][j]==1))
        fill(0);
      else 
        noFill();
      stroke(0);
      rect(i*w,j*w,w,w);
    }
  }
  updateScenario();
}

void updateScenario(){
  next = new int [columns][rows];
  for(int column = 1; column<columns-1; column++) {
    for(int row = 1; row<rows-1; row++){
    
      int neighbors;
      neighbors = 0;  
      for(int i=-1; i<=1; i++){
        for(int j=-1; j<=1; j++)
          neighbors += board[column+i][row+j];
      }
      
      neighbors -= board[column][row];
      
      if( ( board[column][row] == 1 ) && ( neighbors < 2 ) ) next[column][row] = 0;
      else if( (board[column][row]) == 1  && ( neighbors > 3 ) ) next[column][row] = 0;
      else if( (board[column][row]) == 0  && ( neighbors == 3 ) ) next[column][row] = 1;
      else next[column][row] = board[column][row];
    }
  } 
  board = next;
}