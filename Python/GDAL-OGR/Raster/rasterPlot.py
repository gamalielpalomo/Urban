from osgeo import gdal
import matplotlib.image as mpImg
import matplotlib.pyplot as plt

rasterFN =  'populationdensity.tif'
ds = gdal.Open(rasterFN)

pixel_values = ds.ReadAsArray()
plt.imshow(pixel_values)
plt.colorbar()

print ds.GetProjection()
print ds.GetGeoTransform()