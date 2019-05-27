#	Author: Gamaliel Palomo
#	File: streetPerception.py
#	Description: This script reads one field of a shp file and writes it to an specific field
#				 of another shp file. This is applied for all features in the file.
#

import shapefile

sf = shapefile.Reader("models/gis/test/")