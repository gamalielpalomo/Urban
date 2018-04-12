from osgeo import gdal
<<<<<<< HEAD
gtif = gdal.Open("C:\Users\gamaa\OneDrive\CINVESTAV\Thesis\TMP NetLogo\QGIS Project\Geo-Miramar-Image.tif")
=======
gtif = gdal.Open("grid.tiff")
>>>>>>> 741646ce6d858badea2893ddcf04734206d46273
print gtif.GetMetadata()