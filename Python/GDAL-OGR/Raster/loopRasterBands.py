from osgeo import gdal
import sys

<<<<<<< HEAD
src_ds = gdal.Open("C:\Users\gamaa\OneDrive\CINVESTAV\Thesis\TMP NetLogo\QGIS Project\Geo-Miramar-Image.tif")
=======
src_ds = gdal.Open("grid.tiff")
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
if src_ds is None:
	print 'Unable to open file'
	sys.exit(1)

print "[RASTER BAND COUNT ]: ",src_ds.RasterCount
for band in range( src_ds.RasterCount ):
	band += 1
	print "[GETTING BAND]: ",band
	srcband = src_ds.GetRasterBand(band)
	if srcband is None:
		continue

	stats = srcband.GetStatistics( True, True )
	if stats is None:
		continue

	print "[ STATS ] = Minimum=%.3f, Maximum=%.3f, Mean=%.3f, StdDev=%.3f" % ( stats[0], stats[1], stats[2], stats[3] )