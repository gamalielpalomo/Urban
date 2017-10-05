/**
 * An application with a basic interactive map. You can zoom and pan the map.
 */

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.data.GeoJSONReader;
import de.fhpotsdam.unfolding.data.Feature;
import de.fhpotsdam.unfolding.marker.Marker;
import de.fhpotsdam.unfolding.data.ShapeFeature;
import de.fhpotsdam.unfolding.marker.SimpleLinesMarker;
import java.util.List;
import java.util.ArrayList;

UnfoldingMap map;

void setup() {
  size(800, 600, P2D);

  map = new UnfoldingMap(this);
  map.zoomAndPanTo(18, new Location(20.676961f,-103.347782f));
  MapUtils.createDefaultEventDispatcher(this, map);
  
  List<Feature> regions = GeoJSONReader.loadData(this, "regions.geo.json");
  List<Marker> markers = MapUtils.createSimpleMarkers(regions);
  
  for(Marker element : markers){
    element.setColor(color(0,218,197,100));
    element.setStrokeColor(color(0,218,197));
    //System.out.println("Color: "+element.get);
  }
  map.addMarkers(markers);
  
  List<Marker> transitMarkers = new ArrayList<Marker>();
  List<Feature> transitLines = GeoJSONReader.loadData(this,"transitLines.json");
  
  for (Feature feature : transitLines){
    ShapeFeature lineFeature = (ShapeFeature) feature;
    SimpleLinesMarker m = new SimpleLinesMarker(lineFeature.getLocations());
    String lineColor = lineFeature.getStringProperty("LINE");
    
    if(lineColor.equals("GREEN"))
      m.setColor(color(59,130,79));
    m.setStrokeWeight(3);
    transitMarkers.add(m);
  }
  map.addMarkers(transitMarkers);
  
}

void draw() {
  map.draw();
}