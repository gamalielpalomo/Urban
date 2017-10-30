import random as rnd
import pyglet as pg
from Cell import Cell
class Schelling:
	def __init__(self, window_width, window_height):

		#Simulation variables
		self.cellSize = 2
		self.types = 2
		self.nSize = 2

		self.columns = int(window_width/self.cellSize)
		self.rows = int(window_height/self.cellSize)
		gridSize = self.columns*self.rows
		self.board = []
		self.cells = list()
		freeCells = list()

		for row in range(0, self.rows):
			self.board.append([])
			for col in range(0, self.columns):
				cellType = rnd.random()
				if cellType < 0.5:
					freeCells.append(Cell(row,col,0,0))
					self.board[row].append(0)
				elif cellType >=0.5 and cellType<0.75:
					self.cells.append(Cell(row,col,1,0.5))
					self.board[row].append(1)
				else:
					self.cells.append(Cell(row,col,2,0.5))
					self.board[row].append(2)	

	def draw(self):
		for element in freeCells:
			################### Here I left
			square_coords = (element.column*self.cellSize,element.row*self.cellSize,
							 element.column*self.cellSize,)
			pg.graphics.draw(4, pg.gl.GL_QUADS,('v2i', square_coords),('c3B', (142,49,49, 142,49,49, 142,49,49,  142,49,49)))
		for col in range(0, self.columns):
			for row in range(0, self.rows):
				if self.board[col][row] != 0:
					square_coords = (row*self.cellSize, col*self.cellSize,
									 row*self.cellSize, col*self.cellSize + self.cellSize,
									 row*self.cellSize + self.cellSize, col*self.cellSize + self.cellSize,
									 row*self.cellSize + self.cellSize, col*self.cellSize)
					if self.board[col][row] == 1:
						pg.graphics.draw(4, pg.gl.GL_QUADS,('v2i', square_coords),('c3B', (142,49,49, 142,49,49, 142,49,49,  142,49,49)))
					else:
						pg.graphics.draw(4, pg.gl.GL_QUADS,('v2i', square_coords),('c3B', (53,191,181,53,191,181,53,191,181,53,191,181)))
					#print square_coords

	
					