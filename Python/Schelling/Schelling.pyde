from Cell import Cell

#Simulation variables
h = 900
w = 900
cellSize = 5
cellTypes = 2
nSize = 3
columns = int(w/cellSize)
rows = int(h/cellSize)
board = []
freeCells = list()
cells = list()

def setup():
    size(h,w)
    gridSize = columns*rows
    initGrid(columns,rows)
    
def initGrid(columns,rows):
    for row in range (0, rows):
        board.append([])
        for column in range (0, columns):
            rnd = int(random(0,100))
            if rnd<50 :
                freeCells.append(Cell(row,column,0,0))
                board[row].append(0)
            elif rnd>=50 and rnd < 75:
                cells.append(Cell(row,column,1,0.6))
                board[row].append(1)
            else:
                cells.append(Cell(row,column,2,0.7))
                board[row].append(2)
                
def draw():
    for element in freeCells:
        fill(color(255,255,255))
        rect(element.row*cellSize,element.column*cellSize,cellSize,cellSize)
    for element in cells:
        if element.type == 1:
            fill(color(142,49,49))
        elif element.type == 2:
            fill(color(53,191,181))
        rect(element.row*cellSize,element.column*cellSize,cellSize,cellSize)
    updateScenario()
    
def updateScenario():
    for element in cells:
        actualSat = getActualSatisfaction(element)
        cellSat = float(element.satisfaction)
        if actualSat<cellSat:
            moveCell(element)

def getActualSatisfaction(cell):
    row = cell.row
    column = cell.column
    neighbors = 0
    result = 0
    for r in range (-nSize,nSize+1):
        if row+r >= 0 and row+r < rows:
            for c in range (-nSize,nSize+1):
                if column+c >= 0 and column+c < columns:
                    if board[row+r][column+c] != 0:
                        neighbors += 1
                    if board[row+r][column+c] == cell.type:
                        result += 1
    finalResult = result - 1
    finalNeighbors = neighbors -1
    if finalNeighbors == 0:
        return 1
    else:
        return float(finalResult)/float(finalNeighbors)
    
def moveCell(cell):
    if len(freeCells)>0:
        index = int(random(0,len(freeCells)))
        freeCell = freeCells[index]
        del freeCells[index]
        freeCells.append(Cell(cell.row,cell.column,0,0))
        board[cell.row][cell.column] = 0
        cell.row = freeCell.row
        cell.column = freeCell.column
        board[cell.row][cell.column] = cell.type                                                                                                                                