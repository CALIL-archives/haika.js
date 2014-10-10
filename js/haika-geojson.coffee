# GeoJSONデータの出力、変換
$.extend haika,

# GeoJsonからデータを読み込む
#
  loadFromGeoJson: ()->
    if @_geojson.haika?
      header = @_geojson.haika
    else
      header = {}
    @backgroundScaleFactor = if header.backgroundScaleFactor? then header.backgroundScaleFactor else 1
    @backgroundOpacity = if header.backgroundOpacity? then header.backgroundOpacity else 1
    @backgroundUrl = if header.backgroundUrl? then header.backgroundUrl else ''
    @xyAngle = if header.xyAngle? then header.xyAngle else 0
    @xyScaleFactor = if header.xyScaleFactor? then header.xyScaleFactor else 1
    @xyLongitude = if header.xyLongitude? then header.xyLongitude else null
    @xyLatitude = if header.xyLatitude? then header.xyLatitude else null
    @objects = []
    if @_geojson.features?
      for object in @_geojson.features
        @objects.push(object.properties)


# オブジェクトのプロパティの保存
  prepareData: ()->
    log 'prepareData'
    for object in @canvas.getObjects()
      if object.group?
        object.top_cm = @transformTopY_px2cm(object.top + object.group.top)
        object.left_cm = @transformLeftX_px2cm(object.left + object.group.left)
      else
        object.top_cm = @transformTopY_px2cm(object.top)
        object.left_cm = @transformLeftX_px2cm(object.left)
      count = @getCountFindById(object.id)
      _data = object.toGeoJSON()
      @objects[count] = _data.properties


# 現在開いているデータをGeoJSONに変換
#
# @return [Object] GeoJSON形式のデータ
#
  toGeoJSON: ->
    features = []
    for object in @canvas.getObjects()
      geojson = object.toGeoJSON()
      features.push(geojson)
    data =
      "type": "FeatureCollection"
      "features": features
      "haika":
        backgroundUrl: @backgroundUrl
        backgroundScaleFactor: @backgroundScaleFactor
        backgroundOpacity: @backgroundOpacity
        xyLongitude: @xyLongitude
        xyLatitude: @xyLatitude
        xyAngle: @xyAngle
        xyScaleFactor: @xyScaleFactor
        version: 1
    return data


# Todo:Mapでのみ使う関数だけど、現状haika直下
# Todo:この部分をnodeモジュールにしてサーバーサイド使えるようにしたい
# geojsonの作成 座標変換
  createGeoJson: ->
    geojson = @toGeoJSON()
    geojson = @rotateGeoJSON(geojson)
    geojson = @mergeGeoJson(geojson)
    geojson = @moveGeoJSON(geojson)

    features = []
    if geojson and geojson.features.length > 0
      for object in geojson.features
        coordinates = []
        for geometry in object.geometry.coordinates[0]
          x = geometry[0]
          y = geometry[1]
          coordinate = proj4('EPSG:3857', 'EPSG:4326', [x, y]);
          coordinates.push(coordinate)
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
  rotateGeoJSON: (geojson)->
    features = []
    for object in geojson.features
      coordinates = []
      for geometry in object.geometry.coordinates[0]
        x = geometry[0]
        y = geometry[1]
        # 回転の反映
        new_coordinate = fabric.util.rotatePoint(new fabric.Point(x, y), new fabric.Point(0, 0),
          fabric.util.degreesToRadians(-@xyAngle))
        coordinate = [new_coordinate.x, new_coordinate.y]
        coordinates.push(coordinate)
      object.geometry.coordinates = [coordinates]
      features.push(object)
    geojson.features = features
    return geojson
# geojson床オブジェクトのマージ
  mergeGeoJson: (geojson) ->
    if geojson.features.length<=0
      return geojson
    features = []
    paths = []
    for object in geojson.features
      if object.properties.type != 'floor'
        features.push(object)
      if object.properties.type == 'floor'
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
    succeeded = cpr.Execute(ClipperLib.ClipType.ctUnion, solution_paths, ClipperLib.PolyFillType.pftNonZero,
      ClipperLib.PolyFillType.pftNonZero)

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

      features.push(
        "type": "Feature"
        "geometry":
          "type": "Polygon",
          "coordinates": [coordinates]
        "properties":
          "type": "floor",
          "fill": "#FFFFFF",
          "stroke": "#000000"
      )
    geojson.features = features
    return geojson
# geojsonの移動
  moveGeoJSON: (geojson)->
    features = []
    for object in geojson.features
      mapCenter = proj4("EPSG:4326", "EPSG:3857", [@xyLongitude, @xyLatitude])
      if mapCenter
        coordinates = []
        for geometry in object.geometry.coordinates[0]
          x = geometry[0] * @xyScaleFactor / 100
          y = geometry[1] * @xyScaleFactor / 100
          coordinate = [mapCenter[0] + x, mapCenter[1] + y]
          coordinates.push(coordinate)
        object.geometry.coordinates = [coordinates]
      features.push(object)
    geojson.features = features
    return geojson


# オブジェクトをSVGに変換
  toSVG: ->
    svgs = []
    for object in @canvas.getObjects()
      svg = object.toSVG()
      svgs.push(svg)
    log svgs
    start = '<svg viewBox="0 0 1024 768">'
    end = '</svg>'
    data = [start, svgs.join(''), end].join('')
    log data
    return data
  import: ->
    id = window.prompt('idを入力してください', '')
    url = """http://lab.calil.jp/haika_store/data/#{@id}.json"""
    $.ajax
      url: url
      type: 'GET'
      cache: false
      dataType: 'text'
      success: (data)=>
        json = JSON.parse(data)
        canvas = json.canvas
        json.geojson.haika = json.canvas
        @loadRender(json.geojson)
      error: ()=>
        alert '読み込めません'