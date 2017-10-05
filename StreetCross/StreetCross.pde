/**
 * An application with a basic interactive map. You can zoom and pan the map.
 */

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.data.GeoJSONReader;
import de.fhpotsdam.unfolding.data.Feature;
import de.fhpotsdam.unfolding.marker.Marker;
import java.util.List;

UnfoldingMap map;

void setup() {
  size(800, 600, P2D);

  map = new UnfoldingMap(this);
  map.zoomAndPanTo(18, new Location(20.6750337f,-103.4299215f));
  MapUtils.createDefaultEventDispatcher(this, map);
  
  List<Feature> regions = GeoJSONReader.loadData(this, "regions.geo.json");
  List<Marker> markers = MapUtils.createSimpleMarkers(regions);
  for(Marker element : markers){
    element.setColor(color(0,218,197,100));
    element.setStrokeColor(color(0,218,197));
    //System.out.println("Color: "+element.get);
  }
  map.addMarkers(markers);
}

void draw() {
  map.draw();
}