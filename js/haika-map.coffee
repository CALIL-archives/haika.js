#$ ->
#  setTimeout ->
#    $($('.map_setting')[0]).trigger('click')
#  , 1000

map_created = false
$('.map_setting').click ->
  if $('.haika_container').css('display')=='block'
    if not map_created
      map_setting()
      map_created = true
    $('.haika_container').hide()
    $(document.body).css('background', '#333333')
    map_redraw()
    $('.map_container').show()
    $('#map_query').focus()
  else
    $(document.body).css('background', '#FFFFFF')
    $('.haika_container').show()
    $('.map_container').hide()

map = null
features = []
map_redraw = ()->
  if features.length>0
    for feature in features
        map.data.remove feature
      features = map.data.addGeoJson(haika.createGeoJson())

map_set = (lat, lon)->
  $('#canvas_lon').val(lon)
  $('#canvas_lat').val(lat)
  haika.options.lon = lon
  haika.options.lat = lat
  haika.save()

log haika.options.angle
map_setting = ->
  log haika.options.angle

  map = new google.maps.Map(document.getElementById('map'),
    zoom: 20
    maxZoom: 28
    center:
      lat: haika.options.lat
      lng: haika.options.lon
  )
  # Set the stroke width, and fill color for each polygon
  featureStyle = {
    fillColor: 'orange',
    strokeWeight: 1
  }
  map.data.setStyle(featureStyle)
  features = map.data.addGeoJson(haika.createGeoJson())
  
  google.maps.event.addListener map, 'dragend', ->
    log map.getCenter()
    lon = map.getCenter().lng()
    lat = map.getCenter().lat()
    map_set(lat, lon)
    map_redraw()

  $('#map_search').submit ->
#    alert $('#map_query').val()
    address = $('#map_query').val()
    geocoder = new google.maps.Geocoder()
    geocoder.geocode
      address: address
    , (results, status) ->
      if status==google.maps.GeocoderStatus.OK
        map.setCenter results[0].geometry.location
  #        marker = new google.maps.Marker(
  #          map: map
  #          position: results[0].geometry.location
  #        )
        map_set(results[0].geometry.location.lat(), results[0].geometry.location.lng())
        map_redraw()
      else
        alert "ジオコーディングがうまくいきませんでした。: " + status
    return false

  $('#canvas_lat').change ->
    haika.options.lat = parseFloat($(this).val())
    haika.save()
  $('#canvas_lon').change ->
    haika.options.lon = parseFloat($(this).val())
    haika.save()

  $('#canvas_angle').change ->
    map_redraw()

  $('#canvas_angle').slider
    tooltip: 'always'
    step: 1
    min: 0
    max: 360
    value: haika.options.angle
    formatter: (value) ->
      haika.options.angle = parseFloat(value)
      haika.save()
      map_redraw()
      return value+'度'

  $('#geojson_scale').slider
    tooltip: 'always'
    step: 1
    min: 0
    max: 400
    value: haika.options.geojson_scale * 100
    formatter: (value) ->
      haika.options.geojson_scale = parseFloat(value) / 100
      haika.save()
      map_redraw()
      return value+'%'


#  if haika.isLocal()
#    gmap.data.addGeoJson(haika.createGeoJson())
#  else
#    gmap.data.loadGeoJson('/haika_store/data/'+sprintf('%06d',haika.id)+'.geojson')
  
