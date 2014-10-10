# テスト ロード時にマップ表示
# haikaのデータロード完了時に実行する
#$(haika).on 'haika:load', ->
#    $($('.haika-map-setting')[0]).trigger('click')
#  , 1000

# haikaの地図設定
# haikaを拡張
$.extend haika, 
  map:
    map : null
    created : false
    features : []
    initMap : ->
      $('.haika-map-setting').click =>
        if $('.haika-container').css('display')=='block'
          if not @created
            @setMap()
            @created = true
          $('.haika-container').hide()
          $(document.body).css('background', '#333333')
          @redrawMap()
          $('.haika-map-container').show()
          $('#haika-map-query').focus()
        else
          $(document.body).css('background', '#FFFFFF')
          $('.haika-container').show()
          $('.haika-map-container').hide()
    redrawMap : ->
      if @features.length>0
        for feature in @features
          @map.data.remove feature
        @features = @map.data.addGeoJson(haika.createGeoJson())
    saveMap : (lat, lon)->
      $('#haika-canvas-lon').val(lon)
      $('#haika-canvas-lat').val(lat)
      haika.xyLongitude = lon
      haika.xyLatitude = lat
      haika.save()
    setMap : ->
      @map = new google.maps.Map(document.getElementById('haika-map'),
        zoom: 20
        maxZoom: 28
        scaleControl: true,
        center:
          lat: if haika.xyLatitude then haika.xyLatitude else 0
          lng: if haika.xyLongitude then haika.xyLongitude else 0
      )
      # Set the stroke width, and fill color for each polygon
      featureStyle = {
        fillColor: 'orange',
        strokeWeight: 1
      }
      @map.data.setStyle(featureStyle)
      @features = @map.data.addGeoJson(haika.createGeoJson())

      # センターマーカー
      markerImage = new google.maps.MarkerImage('img/mapCenterMarker.png',
        new google.maps.Size(50, 50),
        new google.maps.Point(0, 0),
        new google.maps.Point(25, 25))
      centerMarker = new google.maps.Marker
        position:
          lat: haika.xyLatitude
          lng: haika.xyLongitude
        map: @map
        icon: markerImage # アイコン画像を指定
        draggable: true
      google.maps.event.addListener centerMarker, "dragend", =>
        log 'centerMarker'
        position = centerMarker.getPosition()
        lon = position.lng()
        lat = position.lat()
        @saveMap(lat, lon)
        @redrawMap()

#      google.maps.event.addListener @map, "center_changed", =>
#        log 'center_changed'
#        position = @map.getCenter()
#        centerMarker.setPosition position
#        lon = @map.getCenter().lng()
#        lat = @map.getCenter().lat()
#        @saveMap(lat, lon)
#        @redrawMap()
#
#      google.maps.event.addListener @map, "zoom_changed", =>
#        log 'zoom_changed'
#        @map.setCenter(lat: haika.xyLatitude, lng: haika.xyLongitude)


      $('#haika-map-search').submit =>
    #    alert $('#map-query').val()
        address = $('#haika-map-query').val()
        geocoder = new google.maps.Geocoder()
        geocoder.geocode
          address: address
        , (results, status) =>
          if status==google.maps.GeocoderStatus.OK
            @map.setCenter results[0].geometry.location
      #        marker = new google.maps.Marker(
      #          map: @map.map
      #          position: results[0].geometry.location
      #        )
            @saveMap(results[0].geometry.location.lat(), results[0].geometry.location.lng())
            @redrawMap()
          else
            alert "ジオコーディングがうまくいきませんでした。: " + status
        return false

      $('#haika-canvas-lat').change ->
        haika.xyLatitude = parseFloat($(this).val())
        haika.save()
      $('#haika-canvas-lon').change ->
        haika.xyLongitude = parseFloat($(this).val())
        haika.save()

      $('#haika-canvas-angle').change =>
        @redrawMap()

      $('#haika-canvas-angle').slider
        tooltip: 'always'
        step: 1
        min: -180
        max: 180
        value: haika.xyAngle
        formatter: (value) =>
          haika.xyAngle = parseFloat(value)
          haika.saveDelay()
          @redrawMap()
          return value+'度'

      $('#haika-geojson-scale').slider
          tooltip: 'always'
          step: 1
          min: 70
          max: 150
          value: haika.xyScaleFactor * 100
          formatter: (value) =>
            haika.xyScaleFactor = parseFloat(value) / 100
            haika.saveDelay()
            @redrawMap()
            return value+'%'

