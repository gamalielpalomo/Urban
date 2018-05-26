import random as rnd
from graphics import *
from Cell import Cell

window = GraphWin("Schelling Model",800,800)

window.setBackground("white")

#Simulation variables
cellSize = 5
cellTypes = 2
nSize = 2

columns = int(window.getWidth()/cellSize)
rows = int(window.getHeight()/cellSize)


gridSize = columns*rows
board = []
cells = list()
freeCells = list()

def Schelling():
	for row in range(0, rows):
		board.append([])
		for col in range(0, columns):
			cellType = rnd.random()
			if cellType < 0.5:
				freeCells.append(Cell(row,col,0,0))
				board[row].append(0)
			elif cellType >=0.5 and cellType<0.75:
				cells.append(Cell(row,col,1,0.5))
				board[row].append(1)
			else:
				cells.append(Cell(row,col,2,0.5))
				board[row].append(2)	

	
	#time.sleep(0.)
	draw()
	window.getMouse()

def draw():
	for element in freeCells:
		cell = Rectangle(Point(element.column*cellSize,element.row*cellSize),Point(element.column*cellSize+cellSize,element.row*cellSize+cellSize))
		cell.setFill("white")
		cell.draw(window)

		#pg.graphics.draw(4, pg.gl.GL_QUADS,('v2i', square_coords),('c3B', (255,255,255,255,255,255,255,255,255,255,255,255)))
	"""
	for col in range(0, columns):
		for row in range(0, rows):
			if board[col][row] != 0:
				square_coords = (row*cellSize, col*cellSize,
								 row*cellSize, col*cellSize + cellSize,
								 row*cellSize + cellSize, col*cellSize + cellSize,
								 row*cellSize + cellSize, col*cellSize)
				if board[col][row] == 1:
					pg.graphics.draw(4, pg.gl.GL_QUADS,('v2i', square_coords),('c3B', (142,49,49, 142,49,49, 142,49,49,  142,49,49)))
				else:
					pg.graphics.draw(4, pg.gl.GL_QUADS,('v2i', square_coords),('c3B', (53,191,181,53,191,181,53,191,181,53,191,181)))
				#print square_coords
	"""
Schelling()