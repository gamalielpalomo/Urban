public class Cell{
  int row;
  int column;
  int type;
  public Cell(int r, int c, int t){
       this.row = r;
       this.column = c;
       this.type = t;
  }
  public int getType(){return this.type;}
  public int getRow(){return this.row;}
  public int getColumn(){return this.column;}
}