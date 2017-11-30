from osgeo import gdal
import sys

gdal.UseExceptions()

try:
	src_ds = gdal.Open("grid.tiff")
except RuntimeError, e:
	print 'Unable to open file'
	print e
	sys.exit(1)

try:
	srcband = src_ds.GetRasterBand(1)
	print 'Success!'
except RuntimeError, e:
	print 'Band (%i) not found' % band_num
	print e
	sys.exit(1)