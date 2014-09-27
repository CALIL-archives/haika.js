# テスト ロード時にマップ表示
#$ ->
#  setTimeout ->
#    $($('.map_setting')[0]).trigger('click')
#  , 1000

# haikaの地図設定
# haikaを拡張
$.extend haika, 
  map:
    map : null
    created : false
    features : []
    init : ->
      $('.map_setting').click =>
        if $('.haika_container').css('display')=='block'
          if not @created
            @set()
            @created = true
          $('.haika_container').hide()
          $(document.body).css('background', '#333333')
          @redraw()
          $('.map_container').show()
          $('#map_query').focus()
        else
          $(document.body).css('background', '#FFFFFF')
          $('.haika_container').show()
          $('.map_container').hide()
    redraw : ->
      if @features.length>0
        for feature in @features
            @map.data.remove feature
          @features = @map.data.addGeoJson(haika.createGeoJson())
    save : (lat, lon)->
      $('#canvas_lon').val(lon)
      $('#canvas_lat').val(lat)
      haika.options.lon = lon
      haika.options.lat = lat
      haika.save()
    set : ->
      @map = new google.maps.Map(document.getElementById('map'),
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
      @map.data.setStyle(featureStyle)
      @features = @map.data.addGeoJson(haika.createGeoJson())

      google.maps.event.addListener @map, 'dragend', =>
        log @map.getCenter()
        lon = @map.getCenter().lng()
        lat = @map.getCenter().lat()
        @save(lat, lon)
        @redraw()

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
            @save(results[0].geometry.location.lat(), results[0].geometry.location.lng())
            @redraw()
          else
            alert "ジオコーディングがうまくいきませんでした。: " + status
        return false

      $('#canvas_lat').change ->
        haika.options.lat = parseFloat($(this).val())
        haika.save()
      $('#canvas_lon').change ->
        haika.options.lon = parseFloat($(this).val())
        haika.save()

      $('#canvas_angle').change =>
        @redraw()

      $('#canvas_angle').slider
        tooltip: 'always'
        step: 1
        min: 0
        max: 360
        value: haika.options.angle
        formatter: (value) =>
          haika.options.angle = parseFloat(value)
          haika.save()
          @redraw()
          return value+'度'

      $('#geojson_scale').slider
          tooltip: 'always'
          step: 1
          min: 0
          max: 400
          value: haika.options.geojson_scale * 100
          formatter: (value) =>
            haika.options.geojson_scale = parseFloat(value) / 100
            haika.save()
            @redraw()
            return value+'%'

# 初期設定
haika.map.init()


#  if haika.isLocal()
#    map.data.addGeoJson(haika.createGeoJson())
#  else
#    map.data.loadGeoJson('/haika_store/data/'+sprintf('%06d',haika.id)+'.geojson')
  
