import ogr

ds = ogr.Open('map.osm')
layer = ds.GetLayer(1)

nameList = []
for feature in layer:
	if feature.GetField("highway") != None:
		name = feature.GetField("name")
		if name != None and name not in nameList:
			nameList.append(name)

for element in nameList:
	print element