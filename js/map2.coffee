log = (obj) ->
  try
    console.log obj

image = new ol.style.Circle(
  radius: 5
  fill: null
  stroke: new ol.style.Stroke(
    color: "blue"
    width: 1
  )
)
styles =
  Point: [new ol.style.Style(image: image)]
  LineString: [new ol.style.Style(stroke: new ol.style.Stroke(
    color: "green"
    width: 1
  ))]
  MultiLineString: [new ol.style.Style(stroke: new ol.style.Stroke(
    color: "green"
    width: 1
  ))]
  MultiPoint: [new ol.style.Style(image: image)]
  MultiPolygon: [new ol.style.Style(
    stroke: new ol.style.Stroke(
      color: "yellow"
      width: 1
    )
    fill: new ol.style.Fill(color: "rgba(255, 255, 0, 0.1)")
  )]
  Polygon: [new ol.style.Style(
    stroke: new ol.style.Stroke(
      color: "red"
#      lineDash: [4]
      width: 3
    )
    fill: new ol.style.Fill(color: "rgba(255, 0, 0, 0.1)")
  )]
  GeometryCollection: [new ol.style.Style(
    stroke: new ol.style.Stroke(
      color: "magenta"
      width: 2
    )
    fill: new ol.style.Fill(color: "magenta")
    image: new ol.style.Circle(
      radius: 10
      fill: null
      stroke: new ol.style.Stroke(color: "magenta")
    )
  )]
  Circle: [new ol.style.Style(
    stroke: new ol.style.Stroke(
      color: "red"
      width: 2
    )
    fill: new ol.style.Fill(color: "rgba(255,0,0,0.2)")
  )]

styleFunction = (feature, resolution) ->
  styles[feature.getGeometry().getType()]


#
#@type {olx.source.GeoJSONOptions}
# 
geojson = JSON.parse(localStorage.getItem("geojson"))
console.log geojson
#console.log localStorage.getItem("geojson")

# 中心点からの距離を足す
#      map_center =
#        lat : 35.155080
#        lon : 136.963791
map_center =
  lat : 4184975.9183342634
  lon : 15246739.471236346

features = []

if geojson and geojson.features.length>0
  for object in geojson.features
    log object
    coordinates = []
    for geometry in object.geometry.coordinates[0]
      x = geometry[0]
      y = geometry[1]
      coordinate = [map_center.lon+x, map_center.lat+y]
      coordinates.push(coordinate)
    data =
      "type": "Feature"
      "geometry":
        "type": "Polygon",
        "coordinates": [
          coordinates
        ]
      "properties": object.properties
    features.push(data)

new_geojson =
  "type": "FeatureCollection"
  "features": features

log new_geojson

vectorSource = new ol.source.GeoJSON(object: new_geojson)
features = vectorSource.getFeatures()
console.log features
vectorLayer = new ol.layer.Vector(
  source: vectorSource
  style: styleFunction
)

center = ol.proj.transform([
  136.963791
  35.155080
], "EPSG:4326", "EPSG:3857")
console.log center
center = ol.proj.transform([
  136.963791
  35.155049
], "EPSG:4326", "EPSG:3857")
console.log center

map = new ol.Map(
  layers: [
    new ol.layer.Tile(source: new ol.source.OSM())
    vectorLayer
  ]
  target: "map"
  view: new ol.View2D(
    center: center
    zoom: 6
    projection: "EPSG:4326"
  )
)

features = []
if geojson and new_geojson.features.length>0
  for object in new_geojson.features
    log object
    coordinates = []
    for geometry in object.geometry.coordinates[0]
      x = geometry[0]
      y = geometry[1]
      coordinate = center = ol.proj.transform([x,y], "EPSG:3857", "EPSG:4326")
      coordinates.push(coordinate)
    data =
      "type": "Feature"
      "geometry":
        "type": "Polygon",
        "coordinates": [
          coordinates
        ]
      "properties": object.properties
    features.push(data)

EPSG3857_geojson =
  "type": "FeatureCollection"
  "features": features

#proj4("EPSG:3857", "EPSG:4326", [2, 5])
$('#geojson').val(JSON.stringify(EPSG3857_geojson, null, 4))