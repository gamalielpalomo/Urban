from osgeo import gdal
import matplotlib.image as mpImg
import matplotlib.pyplot as plt

#raster = gdal.Open('C:\Users\gamaa\Desktop\GeoPythonLib\\nyc\\nyc')
#raster = gdal.Open('C:\Users\gamaa\Desktop\GeoData\gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-2015\gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif')
#raster = gdal.Open('C:\Users\gamaa\Desktop\GeoData\\nalcmsmx11gw-Uso de suelo en mexico 2011\\nalcmsmx11gw.tif')
raster = gdal.Open('C:\Users\gamaa\Desktop\GeoData\Land Use ZMG\Land Use ZMG.tif')
if raster is None:
	print 'Unable to open file'
	sys.exit(1)

print "[RASTER BAND COUNT ]: ",raster.RasterCount
for band in range( raster.RasterCount ):
	band += 1
	print "[GETTING BAND]: ",band
	srcband = raster.GetRasterBand(band)
	if srcband is None:
		continue

	stats = srcband.GetStatistics( True, True )
	if stats is None:
		continue

	print "[ STATS ] = Minimum=%.3f, Maximum=%.3f, Mean=%.3f, StdDev=%.3f" % ( stats[0], stats[1], stats[2], stats[3] )

print "Raster Columns: ", raster.RasterXSize
print "Raster Rows: ", raster.RasterYSize

transform = raster.GetGeoTransform()
print "Georeference Info: ", transform
print "xOrigin: ", transform[0]
print "yOrigin: ", transform[3]
print "pixelWidth: ", transform[1]
print "pixelHeight: ", transform[5]
print "metadata: ", raster.GetMetadata()

print "......................................"
"""print "raster data:\n"

band = raster.GetRasterBand(1)

print "First lines: \n"
for row in range (10):
	line = []
	for column in range(10):
		line.append(band.ReadAsArray(row,column,1,1))
	print line"""

#for bandIndex in range(1,raster.RasterCount):
bandIndex = 1
band = raster.GetRasterBand(bandIndex)
rasterArray = band.ReadAsArray()
plt.imshow(rasterArray)
plt.set_cmap('nipy_spectral')
plt.colorbar()
plt.show()