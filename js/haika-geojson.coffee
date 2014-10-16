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
    # 地図のようにキャンバスを使わないケース
    if not @canvas
      return
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
    if @canvas
      for object in @canvas.getObjects()
        geojson = object.toGeoJSON()
        features.push(geojson)
    # 地図のようにキャンバスを使わないケース
    if not @canvas
      features = @_geojson.features
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

# geojsonのクローン
  cloneGeoJSON : ->
    # 参照渡し回避のためにクローンする
    geojson = $.extend(true, {}, @toGeoJSON())
    return geojson

# Todo:Mapでのみ使う関数だけど、現状haika直下
# Todo:この部分をnodeモジュールにしてサーバーサイド使えるようにしたい
# EPSG:3857(経度緯度)のgeojsonの作成
  createGeoJSON: (geojson)->
    geojson = @rotateGeoJSON(geojson)
    geojson = @mergeGeoJSON(geojson)
    geojson = @scaleGeoJSON(geojson)
    geojson = @transformGeoJSON(geojson)
    return geojson

# 共通処理
  changeFeatures : (geojson, func)->
    features = []
    for object in geojson.features
      coordinates = []
      for geometry in object.geometry.coordinates[0]
        x = geometry[0]
        y = geometry[1]
        # 関数処理
        coordinate = func(x, y, geojson)
        coordinates.push(coordinate)
      object.geometry.coordinates = [coordinates]
      features.push(object)
    geojson.features = features
    return geojson

# geojsonの回転
  rotateGeoJSON: (geojson)->
    geojson = @changeFeatures(geojson,(x, y, geojson)->
      # 回転の反映
      cordinate = fabric.util.rotatePoint(new fabric.Point(x, y), new fabric.Point(0, 0),fabric.util.degreesToRadians(-geojson.haika.xyAngle))
      return [cordinate.x, cordinate.y]
    )
    return geojson

# geojson床オブジェクトのマージ
  mergeGeoJSON: (geojson) ->
    if geojson.features.length<=0
      return geojson
    features = []
    paths = []
    for object in geojson.features
      if object.properties.type != 'floor'
        features.push(object)
      if object.properties.type == 'floor'
        path = []
        for geometry in object.geometry.coordinates[0]
          p =
            X: geometry[0]
            Y: geometry[1]
          path.push(p)
        paths.push([path])

    # パスの結合
    cpr = new ClipperLib.Clipper()
    for path in paths
      cpr.AddPaths path, ClipperLib.PolyType.ptSubject, true # true means closed path
    solution_paths = new ClipperLib.Paths()
    cpr.Execute(ClipperLib.ClipType.ctUnion, solution_paths, ClipperLib.PolyFillType.pftNonZero,ClipperLib.PolyFillType.pftNonZero)

    # geojsonにする
    for path in solution_paths
      coordinates = []
      first = true
      for p in path
        if first
          first_coordinates = [p.X, p.Y]
          first = false
        coordinates.push [p.X, p.Y]
      coordinates.push first_coordinates
      # 先頭に追加
      features.unshift(
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

# 倍率
  scaleGeoJSON: (geojson)->
    geojson = @changeFeatures(geojson,(x, y, geojson)->
      x = x * geojson.haika.xyScaleFactor
      y = y * geojson.haika.xyScaleFactor
      return [x, y]
    )
    return geojson

# メートルから経度緯度変換
  transformGeoJSON: (geojson)->
    ### 定数 ###
    PI = Math.PI
    radian =  (2*PI)/360 #0.017...
    earthRadius = 6378150 #地球の半径
    earthCircumference = (2*PI*earthRadius) #地球の円周 = 40054782
    latSecPmetre = (360*60*60)/earthCircumference #1m相当の緯度秒

    cos = Math.cos

    #メートル -> 緯度秒
    metreToLatitudeSecond = (metre) ->
      metre * latSecPmetre

    #メートル,緯度 -> 経度秒
    metreToLongitudeSecond = (metre, lat) ->
      metre * ((360*60*60)/(earthCircumference*cos(lat*radian)))

    geojson = @changeFeatures(geojson,(x, y, geojson)->
      ySecond = metreToLatitudeSecond(y/100)
      yHour = ySecond / 3600
      xSecond = metreToLongitudeSecond(x/100, geojson.haika.xyLatitude+yHour)
      xHour = xSecond / 3600
      return [geojson.haika.xyLongitude+xHour, geojson.haika.xyLatitude+yHour]
    )
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