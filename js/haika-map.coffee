$ ->
  setTimeout ->
    $($('.map_setting')[0]).trigger('click')
  , 1000

map_created = false
$('.map_setting').click ->
  if $('.haika_container').css('display')=='block'
    if not map_created
      map_setting()
      map_created = true
    $('.haika_container').hide()
    $('.map_container').show()
    $('#map_query').focus()
  else
    $('.haika_container').show()
    $('.map_container').hide()


map_setting = ->


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
    $('#canvas_lon').val(lon)
    $('#canvas_lat').val(lat)
    haika.options.lon = lon
    haika.options.lat = lat
    haika.save()
    for feature in features
      map.data.remove feature
    features = map.data.addGeoJson(haika.createGeoJson())

  $('#map_search').submit ->
  #  alert $('#map_query').val()
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
      else
        alert "ジオコーディングがうまくいきませんでした。: " + status
    return false

  $('.canvas_angle').change ->
    $('#canvas_angle').val($('.canvas_angle').val())
    haika.options.angle = $('.canvas_angle').val()
    haika.save()
    if features.length>0
      for feature in features
        map.data.remove feature
    features = map.data.addGeoJson(haika.createGeoJson())

#  if haika.isLocal()
#    gmap.data.addGeoJson(haika.createGeoJson())
#  else
#    gmap.data.loadGeoJson('/haika_store/data/'+sprintf('%06d',haika.id)+'.geojson')
  


