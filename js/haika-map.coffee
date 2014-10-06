# テスト ロード時にマップ表示
# haikaのデータロード完了時に実行する
#$(haika).on 'haika:load', ->
#    $($('.map_setting')[0]).trigger('click')
#  , 1000

# haikaの地図設定
# haikaを拡張
$.extend haika, 
  map:
    map : null
    created : false
    features : []
    initMap : ->
      $('.map_setting').click =>
        if $('.haika-container').css('display')=='block'
          if not @created
            @setMap()
            @created = true
          $('.haika-container').hide()
          $(document.body).css('background', '#333333')
          @redrawMap()
          $('.map_container').show()
          $('#map_query').focus()
        else
          $(document.body).css('background', '#FFFFFF')
          $('.haika-container').show()
          $('.map_container').hide()
    redrawMap : ->
      if @features.length>0
        for feature in @features
          @map.data.remove feature
        @features = @map.data.addGeoJson(haika.createGeoJson())
    saveMap : (lat, lon)->
      $('#canvas_lon').val(lon)
      $('#canvas_lat').val(lat)
      haika.xyLongitude = lon
      haika.xyLatitude = lat
      haika.save()
    setMap : ->
      @map = new google.maps.Map(document.getElementById('map'),
        zoom: 20
        maxZoom: 28
        center:
          lat: haika.xyLatitude
          lng: haika.xyLongitude
      )
      # Set the stroke width, and fill color for each polygon
      featureStyle = {
        fillColor: 'orange',
        strokeWeight: 1
      }
      @map.data.setStyle(featureStyle)
      @features = @map.data.addGeoJson(haika.createGeoJson())

      google.maps.event.addListener @map, 'dragend', =>
        log @map.getCenter()
        lon = @map.getCenter().lng()
        lat = @map.getCenter().lat()
        @saveMap(lat, lon)
        @redrawMap()

      $('#map_search').submit =>
    #    alert $('#map_query').val()
        address = $('#map_query').val()
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

      $('#canvas_lat').change ->
        haika.xyLatitude = parseFloat($(this).val())
        haika.save()
      $('#canvas_lon').change ->
        haika.xyLongitude = parseFloat($(this).val())
        haika.save()

      $('#canvas_angle').change =>
        @redrawMap()

      $('#canvas_angle').slider
        tooltip: 'always'
        step: 1
        min: 0
        max: 360
        value: haika.xyAngle
        formatter: (value) =>
          haika.xyAngle = parseFloat(value)
          haika.saveDelay()
          @redrawMap()
          return value+'度'

      $('#geojson_scale').slider
          tooltip: 'always'
          step: 1
          min: 0
          max: 400
          value: haika.xyScaleFactor * 100
          formatter: (value) =>
            haika.xyScaleFactor = parseFloat(value) / 100
            haika.saveDelay()
            @redrawMap()
            return value+'%'

