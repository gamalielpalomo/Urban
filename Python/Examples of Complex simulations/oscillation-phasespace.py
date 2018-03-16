from pylab import *

def initialize():
	global x, y, xResult, yResult
	x = 1.
	y = 1.
	xResult = [x]
	yResult = [y]

def observe():
	global x, y, xResult, yResult
	xResult.append(x)
	yResult.append(y)

def update():
	global x, y, xResult, yResult
	nextX = 0.5 * x + y
	nextY = -0.3 * x + y
	x = nextX
	y = nextY

initialize()
for t in xrange(100):
	update()
	observe()

#plot(xResult, 'b-')
#plot(yResult, 'g--')
plot(xResult, yResult)
show()