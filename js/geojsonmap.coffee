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
      lineDash: [4]
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


###
@type {olx.source.GeoJSONOptions}
###
geojson = localStorage.getItem('geojson')
console.log geojson
vectorSource = new ol.source.GeoJSON((object:
  type: "FeatureCollection"
#  crs:
#    type: "name"
#    properties:
#      name: "EPSG:3857"

  features: [
    {
      type: "Feature"
      geometry:
        type: "Point"
        coordinates: [
          0
          0
        ]
    }
    {
      type: "Feature"
      geometry:
        type: "LineString"
        coordinates: [
          [
            4e6
            -2e6
          ]
          [
            8e6
            2e6
          ]
        ]
    }
    {
      type: "Feature"
      geometry:
        type: "LineString"
        coordinates: [
          [
            4e6
            2e6
          ]
          [
            8e6
            -2e6
          ]
        ]
    }
    {
      type: "Feature"
      geometry:
        type: "Polygon"
        coordinates: [[
#          [
#            -5e6
#            -1e6
#          ]
#          [
#            -4e6
#            1e6
#          ]
#          [
#            -3e6
#            -1e6
#          ]
          [102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0], [102.0, 2.0]
#          [
#              139.7612409007535,
#              35.697086485480376
#          ]
#          [
#              139.7612435935535,
#              35.697086485480376
#          ]
#          [
#              139.7612435935535,
#              35.69708633588038
#          ]
#          [
#              139.7612409007535,
#              35.69708633588038
#          ]
#          [
#              139.7612409007535,
#              35.697086485480376
#          ]
        ]]
    }
    {
      type: "Feature"
      geometry:
        type: "MultiLineString"
        coordinates: [
          [
            [
              -1e6
              -7.5e5
            ]
            [
              -1e6
              7.5e5
            ]
          ]
          [
            [
              1e6
              -7.5e5
            ]
            [
              1e6
              7.5e5
            ]
          ]
          [
            [
              -7.5e5
              -1e6
            ]
            [
              7.5e5
              -1e6
            ]
          ]
          [
            [
              -7.5e5
              1e6
            ]
            [
              7.5e5
              1e6
            ]
          ]
        ]
    }
    {
      type: "Feature"
      geometry:
        type: "MultiPolygon"
        coordinates: [
          [[
            [
              -5e6
              6e6
            ]
            [
              -5e6
              8e6
            ]
            [
              -3e6
              8e6
            ]
            [
              -3e6
              6e6
            ]
          ]]
          [[
            [
              -2e6
              6e6
            ]
            [
              -2e6
              8e6
            ]
            [
              0e6
              8e6
            ]
            [
              0e6
              6e6
            ]
          ]]
          [[
            [
              1e6
              6e6
            ]
            [
              1e6
              8e6
            ]
            [
              3e6
              8e6
            ]
            [
              3e6
              6e6
            ]
          ]]
        ]
    }
    {
      type: "Feature"
      geometry:
        type: "GeometryCollection"
        geometries: [
          {
            type: "LineString"
            coordinates: [
              [
                -5e6
                -5e6
              ]
              [
                0e6
                -5e6
              ]
            ]
          }
          {
            type: "Point"
            coordinates: [
              4e6
              -5e6
            ]
          }
          {
            type: "Polygon"
            coordinates: [[
              [
                1e6
                -6e6
              ]
              [
                2e6
                -4e6
              ]
              [
                3e6
                -6e6
              ]
            ]]
          }
        ]
    }
  ]
))
console.log vectorSource
#vectorSource.addFeature new ol.Feature(new ol.geom.Circle([
#  5e6
#  7e6
#], 1e6))
vectorLayer = new ol.layer.Vector(
  source: vectorSource
  style: styleFunction
)
center = ol.proj.transform([ 139.761239, 35.697086 ], "EPSG:4326", "EPSG:3857")
map = new ol.Map(
  layers: [
    new ol.layer.Tile(source: new ol.source.OSM())
    vectorLayer
  ]
  target: "map"
  view: new ol.View2D(
    center:center
    zoom: 2
#    maxZoom: 5
#    maxResolution: 1
  )
)