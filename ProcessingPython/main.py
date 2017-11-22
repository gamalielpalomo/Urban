from graphics import *
from Schelling import Schelling

class Window(GraphWin):

	def __init__(self, title, width, height):
		super(GraphWin, self).__init__(title,width,height)
		#self.schelling = Schelling(self.get_size()[0],self.get_size()[1])

	def on_draw(self):
		self.clear()
		self.schelling.draw()
		#self.schelling.update()

if __name__ == '__main__':
	window = Window("Schelling Model", 800, 800)