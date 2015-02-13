# haikaの地図設定
# haikaを拡張
$.extend haika, 
  map:
    map : null
    geojson :null

    draw : ->
      log 'map.draw'
      @map.data.forEach (feature)=>
        @map.data.remove feature
      @map.data.addGeoJson haika.createGeoJSON($.extend(true, {},@geojson))

    save : ->
      log 'map.save'
      haika._geojson=@geojson
      haika.saveDelay()

    init : ()->
      log 'map.init'
      @geojson=haika._geojson
      centerLatLng =
        lat: if @geojson.haika.xyLatitude then @geojson.haika.xyLatitude else 0
        lng: if @geojson.haika.xyLongitude then @geojson.haika.xyLongitude else 0
      @map = new google.maps.Map document.getElementById('haika-map'),
        zoom: 20
        maxZoom: 28
        scaleControl: true,
        center:centerLatLng
      featureStyle =
        fillColor: 'orange',
        strokeWeight: 1
      @map.data.setStyle(featureStyle)
      @draw()
      markerImage = new google.maps.MarkerImage('img/mapCenterMarker.png',
        new google.maps.Size(50, 50),
        new google.maps.Point(0, 0),
        new google.maps.Point(25, 25))
      centerMarker = new google.maps.Marker
        position:centerLatLng
        map: @map
        icon: markerImage # アイコン画像を指定
        draggable: true
      google.maps.event.addListener centerMarker, "dragend", =>
        log 'centerMarker'
        position = centerMarker.getPosition()
        @geojson.haika.xyLongitude = position.lng()
        @geojson.haika.xyLatitude = position.lat()
        @draw()
        @save()
      $('#haika-map-search').submit =>
        address = $('#haika-map-query').val()
        geocoder = new google.maps.Geocoder()
        geocoder.geocode
          address: address
        , (results, status) =>
          if status==google.maps.GeocoderStatus.OK
            @map.setCenter results[0].geometry.location
            @geojson.haika.xyLongitude = results[0].geometry.location.lng()
            @geojson.haika.xyLatitude = results[0].geometry.location.lat()
            @draw()
            @save()
          else
            alert "ジオコーディングがうまくいきませんでした。: " + status
        return false
      $('#haika-canvas-angle').slider
        tooltip: 'always'
        step: 0.1
        precision: 1
        min: -180
        max: 180
        natural_arrow_keys: true
        value: @geojson.haika.xyAngle
        formatter: (value) =>
          $('#haika-canvas-angle').find('.slider-handle').focus()
          if @geojson.haika.xyAngle!=value
            @geojson.haika.xyAngle = value
            @draw()
            @save()
          return value+'度'
      $('#haika-geojson-scale').slider
        tooltip: 'always'
        step: 1
        min: 80
        max: 120
        value: @geojson.haika.xyScaleFactor * 100
        formatter: (value) =>
          $('#haika-geojson-scale').find('.slider-handle').focus()
          if @geojson.haika.xyScaleFactor!= value / 100
            @geojson.haika.xyScaleFactor = value / 100
            @draw()
            @save()
          return value+'%'