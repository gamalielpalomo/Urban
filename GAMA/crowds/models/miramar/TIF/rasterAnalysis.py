from osgeo import gdal
gdal.UseExceptions()

ds = gdal.Open("img.tif")
band = ds.GetRasterBand(1)
arr = band.ReadAsArray()
ct = band.GetColorTable()

# index value to RGB (ignore A)
i2rgb = [ct.GetColorEntry(i)[:3] for i in range(ct.GetCount())]
print i2rgb
# RGB to index value (assumes RGBs are unique)
rgb2i = {rgb: i for i, rgb in enumerate(i2rgb)}

# Now look up an index, e.g., water is light blue
#print(rgb2i[(132, 193, 255)])  # 2