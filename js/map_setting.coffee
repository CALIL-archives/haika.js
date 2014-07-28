map_setting = ->
  gmap = new google.maps.Map(document.getElementById("gmap"),
    disableDefaultUI: true
    keyboardShortcuts: false
    draggable: false
    disableDoubleClickZoom: true
    scrollwheel: false
    streetViewControl: false
  )
  # Set the stroke width, and fill color for each polygon
  featureStyle = {
    fillColor: 'orange',
    strokeWeight: 1
  }
  gmap.data.setStyle(featureStyle)
  gmap.data.loadGeoJson('data/000087.geojson');
  
  # make sure the view doesn't go beyond the 22 zoom levels of Google Maps
#  view = new ol.View2D(maxZoom: 21)

#  center = ol.proj.transform([
#    app.options.lon
#    app.options.lat
#  ], "EPSG:4326", "EPSG:3857")
#  map_center =
#    lon : center[0]
#    lat : center[1]
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
  geojson = app.toGeoJSON()
  log geojson
  vectorSource = new ol.source.GeoJSON(object: geojson)
  features = vectorSource.getFeatures()
  console.log features
  vectorLayer = new ol.layer.Vector(
    source: vectorSource
    style: styleFunction
  )

  center = ol.proj.transform([ app.options.lon, app.options.lat ], "EPSG:4326", "EPSG:3857")
  view = new ol.View2D(
    layers: [vectorLayer]
    center: center
    zoom: 2
    maxZoom: 21
#    maxResolution: 20
  )
  view.on "change:center", ->
    center = ol.proj.transform(view.getCenter(), "EPSG:3857", "EPSG:4326")
    gmap.setCenter new google.maps.LatLng(center[1], center[0])
  view.on "change:resolution", ->
    gmap.setZoom view.getZoom()

  olMapDiv = document.getElementById("olmap")
  window.map = new ol.Map(
    target: "map"
    ol3Logo: false
    layers: [vectorLayer]
#    layers: [new ol.layer.Tile(source: new ol.source.OSM())]
    interactions: ol.interaction.defaults(
        altShiftDragRotate: false
        dragPan: false
        rotate: false
    ).extend([new ol.interaction.DragPan(kinetic: null)])
    target: olMapDiv
    view: view
  )
  view.setCenter(center)
  view.setZoom(20)
  olMapDiv.parentNode.removeChild olMapDiv
  gmap.controls[google.maps.ControlPosition.TOP_LEFT].push olMapDiv

  map.on 'moveend', (e)->
    center = map.getView().getCenter()
    new_center = ol.proj.transform(center, "EPSG:3857", "EPSG:4326")
    $('#canvas_lon').val(new_center[0])
    app.options.lon = new_center[0]
    $('#canvas_lat').val(new_center[1])
    app.options.lat = new_center[1]
    app.save()

#  featureOverlay = new ol.FeatureOverlay({
#    style: new ol.style.Style({
#      fill: new ol.style.Fill({
#        color: 'rgba(255, 255, 255, 0.2)'
#      }),
#      stroke: new ol.style.Stroke({
#        color: '#ffcc33',
#        width: 2
#      }),
#      image: new ol.style.Circle({
#        radius: 7,
#        stroke: new ol.style.Stroke({
#          color: '#ffffff',
#          width: 2
#        }),
#        fill: new ol.style.Fill({
#          color: '#0077FF'
#        })
#      })
#    })
#  })
#  featureOverlay.addFeature(new ol.Feature(new ol.geom.Point(center)))
#
#  featureOverlay.setMap(map);
#  draw = new ol.interaction.Draw({features: featureOverlay.getFeatures(), type: "Point"})
#  modify = new ol.interaction.Modify({
#    features: featureOverlay.getFeatures(),
#    deleteCondition: (event) =>
#      return ol.events.condition.shiftKeyOnly(event) &&
#        ol.events.condition.singleClick(event);
#  })
  #map.addInteraction(modify);
  #map.addInteraction(new ol.interaction.DragRotateAndZoom())
  #map.addInteraction(draw);
#  map.addControl(new ol.control.ZoomSlider())
#  map.addControl(new ol.control.ScaleLine())

$('#map_search').submit ->
  url = 'http://nominatim.openstreetmap.org/search'
  $.ajax
    url: url
    type: "GET"
    data:
      q: $('#map_query').val()
      format: "json"
    dataType: "jsonp"
    jsonp: "json_callback"
    error: ()->
    success: (data)=>
      log data
      if data.length>0
        app.options.lon = parseFloat(data[0].lon)
        app.options.lat = parseFloat(data[0].lat)
        app.save()
        $('#canvas_lon').val app.options.lon
        $('#canvas_lat').val app.options.lat
        center = ol.proj.transform([ app.options.lon, app.options.lat ], "EPSG:4326", "EPSG:3857")
        view = map.getView()
        view.setCenter(center)
        view.setZoom(20)
      else
        alert '見つかりませんでした。'
  return false;