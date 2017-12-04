from osgeo import gdal
import matplotlib.image as mpImg
import matplotlib.pyplot as plt
import numpy

raster = gdal.Open('Land Use ZMG\Land Use ZMG.tif')
if raster is None:
	print 'Unable to open file'
	sys.exit(1)

#------------------Printing raster metadata-----------------------

print "Raster bands: ",raster.RasterCount
print "Raster Columns: ", raster.RasterXSize
print "Raster Rows: ", raster.RasterYSize
transform = raster.GetGeoTransform()
print "Georeference Info: ", transform
print "xOrigin: ", transform[0]
print "yOrigin: ", transform[3]
print "pixelWidth: ", transform[1]
print "pixelHeight: ", transform[5]
print "metadata: ", raster.GetMetadata()

print "----------------------------------------------------------------"

for band in range( raster.RasterCount ):
	band += 1
	print "BAND %i:" %band
	srcband = raster.GetRasterBand(band)
	if srcband is None:
		continue

	stats = srcband.GetStatistics( True, True )
	if stats is None:
		continue

	print "[ STATS ] = Minimum=%.3f, Maximum=%.3f, Mean=%.3f, StdDev=%.3f" % ( stats[0], stats[1], stats[2], stats[3] )

print "----------------------------------------------------------------"

#------------------Simulation variables---------------------------------
print
rows = raster.RasterYSize
columns = raster.RasterXSize

timesteps = 5
nSize = 1
gridSize = columns * rows

print "Simulation Variables:"
print "Grid rows: ",rows
print "Grid columns: ",columns
print "Time-steps: ",timesteps
print "Neighborhod size: ",nSize
print "Grid size: ", gridSize
print 
board = raster.ReadAsArray()


#------------------Simulation functions---------------------------------
def runSim():
	board = initGrid()
	stpCounter = 0
	while stpCounter < timesteps:
		board = updateScenario(board)	
		stpCounter+=1
	plotBand(board)


def initGrid():
	rasterArray = raster.ReadAsArray()
	print ""
	print rasterArray
	print "array shape: ",rasterArray.shape
	return rasterArray
	"""for y in range(0,rows):
					board.apped([])
					for x in range(0,columns):
						#We have to be careful with the x,y format used in rasters (X are the columns and Y are the rows)
						#We make the raster sweep left-right and up-down
						pxValue = raster.ReadAsArray(x,y,1,1)"""

def updateScenario(grid):
	tmpGrid = numpy.array(grid)
	for row in range (0, rows-1):
		for column in range (0, columns-1):
			nextState = getNextState(row, column)
			if nextState != None:
				tmpGrid[row,column] = nextState

	return tmpGrid

def getNextState(row, column):
	value = board[row,column]

	if value == 1:
		pass
	elif value == 2:
		pass
	elif value == 3:
		pass
	elif value == 4:
		pass
	elif value == 5:
		pass
	elif value == 6:
		pass
	elif value == 7:
		pass
	elif value == 8:
		pass
	elif value == 9:
		if 17 in getNeighborhod(row, column):
			board[row,column] = 17
	elif value == 10:
		if 17 in getNeighborhod(row, column):
			board[row,column] = 17
	elif value == 11:
		pass
	elif value == 12:
		pass
	elif value == 13:
		pass
	elif value == 14:
		pass
	elif value == 15:
		pass
	elif value == 16:
		pass
	elif value == 17:
		pass
	elif value == 18:
		pass
	elif value == 19:
		pass

def getNeighborhod(row, column):
	neighborhod = []
	for r in range (-nSize, nSize+1):
		if row+r >= 0 and row+r < rows:
			for c in range (-nSize, nSize+1):
				if column+c >= 0 and column+c < columns:
					neighborhod.append(board[row+r,column+c])
	return neighborhod


def plotBand(npArrayToPlot):
	plt.imshow(npArrayToPlot)
	plt.set_cmap('nipy_spectral')
	#plt.set_cmap('nipy_spectral')
	plt.colorbar()
	plt.show()

#------------------Starting the simulation----------------------------

runSim()