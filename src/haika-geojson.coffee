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
        object.top_cm = @px2cm_y(object.top + object.group.top)
        object.left_cm = @px2cm_x(object.left + object.group.left)
      else
        object.top_cm = @px2cm_y(object.top)
        object.left_cm = @px2cm_x(object.left)
      count = @getCountFindById(object.id)
      _data = object.toGeoJSON()
      @objects[count] = _data.properties


# 現在開いているデータをGeoJSONに変換
#
# @return [Object] GeoJSON形式のデータ
#
  toGeoJSON: ->
    if @canvas
      features = []
      for object in @canvas.getObjects()
        geojson = object.toGeoJSON()
        features.push(geojson)
    else
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