public class Cell{
  int row;
  int column;
  int type;
  float satisfaction;
  public Cell(int r, int c, int t, float s){
       this.row = r;
       this.column = c;
       this.type = t;
       this.satisfaction = s;
  }
  public void setRow(int r){this.row = r;}
  public void setColumn(int c){this.column = c;}
  public int getType(){return this.type;}
  public int getRow(){return this.row;}
  public int getColumn(){return this.column;}
  public float getSatisfaction(){return this.satisfaction;}
}