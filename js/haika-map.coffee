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
  # geojsonの作成 座標変換
  createGeoJson : ->
    geojson = @translateGeoJSON()
    features = []
    if geojson and geojson.features.length>0
      for object in geojson.features
        # 結合前の床は省く
        if object.properties.type!='floor'
          coordinates = []
          for geometry in object.geometry.coordinates[0]
            x = geometry[0]
            y = geometry[1]
#            log [x,y]
#            coordinate = ol.proj.transform([x,y], "EPSG:3857", "EPSG:4326")
            coordinate = proj4('EPSG:3857', 'EPSG:4326', [x,y]);
            coordinates.push(coordinate)
          # 結合した床面をfloorに戻す
          if object.properties.type=='merge_floor'
            log object.properties
            object.properties.type='floor'
          data =
            "type": "Feature"
            "geometry":
              "type": "Polygon",
              "coordinates": [
                coordinates
              ]
            "properties": object.properties
          features.push(data)
    EPSG3857_geojson =
      "type": "FeatureCollection"
      "features": features
    return EPSG3857_geojson
  # geojsonの回転
  translateGeoJSON : ->
    geojson = @toGeoJSON()
    geojson = @mergeGeoJson(geojson)
    features = []
    for object in geojson.features
      mapCenter = proj4("EPSG:4326", "EPSG:3857", [@options.lon, @options.lat])
      if mapCenter
        coordinates = []
        for geometry in object.geometry.coordinates[0]
          x = geometry[0] * @options.geojson_scale
          y = geometry[1] * @options.geojson_scale
          # 回転の反映
          new_coordinate =  fabric.util.rotatePoint(new fabric.Point(x, y), new fabric.Point(0, 0), fabric.util.degreesToRadians(-@options.angle))
          coordinate = [mapCenter[0]+new_coordinate.x, mapCenter[1]+new_coordinate.y]
          coordinates.push(coordinate)
        object.geometry.coordinates = [coordinates]
      features.push(object)
    geojson.features = features
    return geojson
  # geojson床オブジェクトのマージ
  mergeGeoJson : (geojson) ->
    paths = []
    if geojson and geojson.features.length>0
      for object in geojson.features
        if object.properties.type=='floor'
          path = []
          log object.geometry.coordinates[0]
          for geometry in object.geometry.coordinates[0]
            p = {
              X: geometry[0]
              Y: geometry[1]
            }
            path.push(p)
          paths.push([path])
      log paths

      cpr = new ClipperLib.Clipper()
      for path in paths
        cpr.AddPaths path, ClipperLib.PolyType.ptSubject, true # true means closed path
      solution_paths = new ClipperLib.Paths()
      succeeded = cpr.Execute(ClipperLib.ClipType.ctUnion, solution_paths, ClipperLib.PolyFillType.pftNonZero, ClipperLib.PolyFillType.pftNonZero)

      log solution_paths
      for path in solution_paths
        coordinates = []
        first = true
        for p in path
          if first
            first_coordinates = [p.X, p.Y]
            first = false
          coordinates.push [p.X, p.Y]
        coordinates.push first_coordinates

        geojson.features.push(
          "type": "Feature"
          "geometry":
            "type": "Polygon",
            "coordinates": [coordinates]
          "properties":
            "type": "merge_floor",
            "fill"  :"#FFFFFF",
            "stroke":"#FFFFFF"
        )

    return geojson

# 初期設定
haika.map.init()


#  if haika.isLocal()
#    map.data.addGeoJson(haika.map.createGeoJson())
#  else
#    map.data.loadGeoJson('/haika_store/data/'+sprintf('%06d',haika.id)+'.geojson')
  
