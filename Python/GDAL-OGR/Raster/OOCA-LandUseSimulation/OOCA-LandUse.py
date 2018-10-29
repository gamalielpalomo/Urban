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

timesteps = 10
nSize = 1
gridSize = columns * rows

landUseNames = [
	
	"",
	"Temperate or sub-polar needleleaf forest",
	"",
	"Tropical or sub-tropical broadleaf evergreen forest",
	"Tropical or sub-tropical broadleaf deciduous forest",
	"Temperate or sub-polar broadleaf deciduous forest",
	"Mixed forest",
	"Tropical or sub-tropical shrubland",
	"Temperate or sub-polar shrubland",
	"Tropical or sub-tropical grassland",
	"Temperate or sub-polar grassland",
	"",
	"",
	"",
	"Wetland",
	"Cropland",
	"Barren land",
	"Urban and built-up",
	"Water",
	"Snow and ice"
	
]

print "Simulation Variables:"
print "Grid rows: ",rows
print "Grid columns: ",columns
print "Time-steps: ",timesteps
print "Neighborhod size: ",nSize
print "Grid size: ", gridSize
print 
board = []

#------------------Simulation functions---------------------------------
def runSim():
	global board
	typeArray, board = initGrid()
	stpCounter = 0
	print
	for i in range (0,len(typeArray)-1):
		if landUseNames[i] == "":
			pass
		else:
			print "%s: %i" %(landUseNames[i],typeArray[i])
	print
	while stpCounter < timesteps:
		print "timestep ",stpCounter
		tmpBoard = updateScenario(board)
		board = numpy.array(tmpBoard)
		stpCounter+=1
	plotBand(board)


def initGrid():
	typeArray = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	rasterArray = raster.ReadAsArray()
	print ""
	print rasterArray
	print "array shape: ",rasterArray.shape
	
	for row in range (rows):
		for column in range (columns):
			typeArray[rasterArray[row,column]] += 1	

	return typeArray,rasterArray

def updateScenario(grid):
	tmpGrid = numpy.array(grid)
	for row in range (0, rows-1):
		for column in range (0, columns-1):
			nextState = getNextState(row, column)
			if nextState != 0:
				tmpGrid[row,column] = nextState

	return tmpGrid


def getNextState(row, column):
	global board
	value = board[row,column]

	"""
		As we are modeling the ZMG as a cellular automata, it is necessary to
		define the simulation rules.
		There are 18 different types of cell in the raster and every one has 
		its own behavior.
	"""

	if value == 1:
		return 0
	elif value == 2:
		return 0
	elif value == 3:
		return 0
	elif value == 4:
		return 0
	elif value == 5:
		return 0
	elif value == 6:
		return 0
	elif value == 7:
		return 0
	elif value == 8:
		return 0
	elif value == 9:
		if 17 in getNeighborhod(row, column):
			return 17
		else:
			return 0
	elif value == 10:
		if 17 in getNeighborhod(row, column):
			return 17
		else:
			return 0
	elif value == 11:
		return 0
	elif value == 12:
		return 0
	elif value == 13:
		return 0
	elif value == 14:
		return 0
	elif value == 15:
		if 17 in getNeighborhod(row, column):
			return 17
		else:
			return 0
	elif value == 16:
		return 0
	elif value == 17:
		return 0
	elif value == 18:
		return 0
	elif value == 19:
		return 0

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