import osgeo.ogr as ogr

shapefile = ogr.Open("tl_2012_us_state/tl_2012_us_state.shp")
numLayers = shapefile.GetLayerCount()

print "Shapefile contains %d layers" % numLayers
print

for layerNum in range(numLayers):
	layer = shapefile.GetLayer(layerNum)
	spatialRef = layer.GetSpatialRef().ExportToProj4()
	numFeatures = layer.GetFeatureCount()
	print "Layer %d has spatial reference %s" % (layerNum, spatialRef)
	print "Layer %d has %d features:" % (layerNum, numFeatures)
	print

	for featureNum in range(numFeatures):
		feature = layer.GetFeature(featureNum)
		featureName = feature.GetField("NAME")

		print "Feature %d has name %s" % (featureNum, featureName)

layer = shapefile.GetLayer(0)
feature = layer.GetFeature(55)

#--------------------------------------------------------------------#
print
print "Feature has the following attributes: "
print

attributes = feature.items()

for key, value in attributes.items():
	print " %s = %s" % (key, value)

geometry = feature.GetGeometryRef()
geometryName = geometry.GetGeometryName()

print
print "Feature's geometry data consists of a %s" % geometryName

#--------------------------------------------------------------------#
def analyzeGeometry(geometry, indent=0):
	s = []
	s.append("  " * indent)
	s.append(geometry.GetGeometryName())
	if geometry.GetPointCount() > 0:
		s.append(" with %d data points" % geometry.GetPointCount())
	if geometry.GetGeometryCount() > 0:
		s.append(" containing:")

	print "".join(s)

	for i in range(geometry.GetGeometryCount()):
		analyzeGeometry(geometry.GetGeometryRef(i), indent+1)
print 
analyzeGeometry(geometry)