map_setting = ->
  center = ol.proj.transform([ app.options.lon, app.options.lat ], "EPSG:4326", "EPSG:3857")
  window.map = new ol.Map(
    target: "map"
    ol3Logo: false
    layers: [new ol.layer.Tile(source: new ol.source.OSM())]
    view: new ol.View2D(
      center: center
      zoom: 2
      maxZoom: 5
      maxResolution: 20
    )
  )
  map.on 'moveend', (e)->
#    center = map.getView().getCenter()
#    new_center = ol.proj.transform(center, "EPSG:3857", "EPSG:4326")
#    $('#canvas_lon').val(new_center[0])
#    app.options.lon = new_center[0]
#    $('#canvas_lat').val(new_center[1])
#    app.options.lat = new_center[1]
#    app.save()

  featureOverlay = new ol.FeatureOverlay({
    style: new ol.style.Style({
      fill: new ol.style.Fill({
        color: 'rgba(255, 255, 255, 0.2)'
      }),
      stroke: new ol.style.Stroke({
        color: '#ffcc33',
        width: 2
      }),
      image: new ol.style.Circle({
        radius: 7,
        stroke: new ol.style.Stroke({
          color: '#ffffff',
          width: 2
        }),
        fill: new ol.style.Fill({
          color: '#0077FF'
        })
      })
    })
  })
  featureOverlay.addFeature(new ol.Feature(new ol.geom.Point(center)))

  featureOverlay.setMap(map);
  draw = new ol.interaction.Draw({features: featureOverlay.getFeatures(), type: "Point"})
  modify = new ol.interaction.Modify({
    features: featureOverlay.getFeatures(),
    deleteCondition: (event) =>
      return ol.events.condition.shiftKeyOnly(event) &&
        ol.events.condition.singleClick(event);
  })
  #map.addInteraction(modify);
  #map.addInteraction(new ol.interaction.DragRotateAndZoom())
  #map.addInteraction(draw);
  map.addControl(new ol.control.ZoomSlider())
  map.addControl(new ol.control.ScaleLine())

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
        view.setZoom(10)
      else
        alert '見つかりませんでした。'
  return false;