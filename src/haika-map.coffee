# haikaの地図設定
# haikaを拡張
$.extend haika,
  map:
    map: null

  # EPSG:3857(経度緯度)のgeojsonの作成
    convertLatLon: (geojson)->

      ### 定数 ###
      PI = Math.PI
      radian = (2 * PI) / 360 #0.017...
      earthRadius = 6378150 #地球の半径
      earthCircumference = (2 * PI * earthRadius) #地球の円周 = 40054782
      latSecPmetre = (360 * 60 * 60) / earthCircumference #1m相当の緯度秒

      #メートル -> 緯度秒
      metreToLatitudeSecond = (metre) ->
        metre * latSecPmetre

      #メートル,緯度 -> 経度秒
      metreToLongitudeSecond = (metre, lat) ->
        metre * ((360 * 60 * 60) / (earthCircumference * Math.cos(lat * radian)))

      features = []
      for object in geojson.features
        if object.properties.type == 'floor' or object.properties.type == 'beacon'
          continue
        coordinates = []
        for geometry in object.geometry.coordinates[0]
          x = geometry[0]
          y = geometry[1]
          # 回転
          sin = Math.sin(fabric.util.degreesToRadians(-haika.xyAngle))
          cos = Math.cos(fabric.util.degreesToRadians(-haika.xyAngle))
          rx = x * cos - y * sin
          ry = x * sin + y * cos
          x = rx
          y = ry
          # 拡大・縮小
          x = x * haika.xyScaleFactor
          y = y * haika.xyScaleFactor
          # 経緯度に変換
          ySecond = metreToLatitudeSecond(y / 100)
          yHour = ySecond / 3600
          xSecond = metreToLongitudeSecond(x / 100, haika.xyLatitude + yHour)
          xHour = xSecond / 3600
          coordinates.push([haika.xyLongitude + xHour, haika.xyLatitude + yHour])
        object.geometry.coordinates = [coordinates]
        features.push(object)
      geojson.features = features
      return geojson
    draw: ->
      @map.data.forEach (feature) =>
        @map.data.remove feature
        return
      @map.data.addGeoJson @convertLatLon($.extend(true, {}, haika._geojson))

    save: ->
      log 'map.save'
      haika.saveDelay()

    init: ()->
      log 'map.init'
      centerLatLng =
        lat: if haika.xyLatitude then haika.xyLatitude else 0
        lng: if haika.xyLongitude then haika.xyLongitude else 0
      @map = new google.maps.Map document.getElementById('haika-map'),
        zoom: 20
        maxZoom: 28
        scaleControl: true,
        center: centerLatLng
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
        position: centerLatLng
        map: @map
        icon: markerImage # アイコン画像を指定
        draggable: true
      google.maps.event.addListener centerMarker, "dragend", =>
        log 'centerMarker'
        position = centerMarker.getPosition()
        haika.xyLongitude = position.lng()
        haika.xyLatitude = position.lat()
        @draw()
        @save()
      $('#haika-map-search').submit =>
        address = $('#haika-map-query').val()
        geocoder = new google.maps.Geocoder()
        geocoder.geocode
          address: address
        , (results, status) =>
          if status == google.maps.GeocoderStatus.OK
            @map.setCenter results[0].geometry.location
            haika.xyLongitude = results[0].geometry.location.lng()
            haika.xyLatitude = results[0].geometry.location.lat()
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
        value: haika.xyAngle
        formatter: (value) =>
          $('#haika-canvas-angle').find('.slider-handle').focus()
          if haika.xyAngle != value
            haika.xyAngle = value
            @draw()
            @save()
          return value + '度'
      $('#haika-geojson-scale').slider
        tooltip: 'always'
        step: 1
        min: 80
        max: 120
        value: haika.xyScaleFactor * 100
        formatter: (value) =>
          $('#haika-geojson-scale').find('.slider-handle').focus()
          if haika.xyScaleFactor != value / 100
            haika.xyScaleFactor = value / 100
            @draw()
            @save()
          return value + '%'