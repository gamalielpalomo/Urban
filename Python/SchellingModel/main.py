import pyglet as pg
from Schelling import Schelling

class Window(pg.window.Window):

	def __init__(self):
		super(Window, self).__init__(900,900)
		pg.gl.glClearColor(255,255,255,1)
		self.schelling = Schelling(self.get_size()[0],self.get_size()[1])

	def on_draw(self):
		#self.clear()
		self.schelling.draw()
		#self.schelling.update()

if __name__ == '__main__':
	window = Window()
	pg.app.run()