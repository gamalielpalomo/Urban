from osgeo import gdal
gtif = gdal.Open("grid.tiff")
print gtif.GetMetadata()