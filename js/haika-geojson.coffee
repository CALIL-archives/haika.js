# GeoJSONデータの出力、変換
$.extend haika,

# GeoJsonからデータを読み込む
#
# @param {Object} geojson 省略時は保持しているデータを読み込む
#
  loadFromGeoJson: (geojson = null)-> # GeoJsonからデータを読み込む
    if not geojson
      # TODO:haika-io の @_geojson
      geojson = @_geojson
    if geojson.haika.backgroundScaleFactor?
      @backgroundScaleFactor = geojson.haika.backgroundScaleFactor
    if not @backgroundScaleFactor
      @backgroundScaleFactor = 1
    if geojson.haika.backgroundOpacity?
      @backgroundOpacity = geojson.haika.backgroundOpacity
    if not @backgroundOpacity
      @backgroundOpacity = 1
    if geojson.haika.backgroundUrl?
      @backgroundUrl = geojson.haika.backgroundUrl
    else
      @backgroundUrl = ''
    if geojson.haika.xyAngle?
      @xyAngle = geojson.haika.xyAngle
    if geojson.haika.xyScaleFactor?
      @xyScaleFactor = geojson.haika.xyScaleFactor
    if geojson.haika.xyLongitude? and geojson.haika.xyLatitude?
      @xyLongitude = geojson.haika.xyLongitude
      @xyLatitude = geojson.haika.xyLatitude
    if geojson and geojson.features.length > 0
      for object in geojson.features
        if object.properties.id > @lastId
          @lastId = object.properties.id
        klass = @getClass(object.properties.type)
        shape = new klass(
          id: object.properties.id
          top: @transformTopY_cm2px(object.properties.top_cm)
          left: @transformLeftX_cm2px(object.properties.left_cm)
          top_cm: object.properties.top_cm
          left_cm: object.properties.left_cm
          fill: object.properties.fill
          stroke: object.properties.stroke
          angle: object.properties.angle
        )
        schema = shape.constructor.prototype.getJsonSchema()
        for key of schema.properties
          shape[key] = object.properties[key]
        @add(shape)


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


# オブジェクトのプロパティの保存
  prepareData: ()->
    log 'prepareData'
    for object in @canvas.getObjects()
      count = @getCountFindById(object.id)
      @objects[count].id = object.id
      @objects[count].type = object.type
      @objects[count].top_cm = @transformTopY_px2cm(object.top)
      @objects[count].left_cm = @transformLeftX_px2cm(object.left)
      @objects[count].scaleX = object.scaleX / @scaleFactor
      @objects[count].scaleY = object.scaleY / @scaleFactor
      @objects[count].angle = object.angle
      @objects[count].fill = object.fill
      @objects[count].stroke = object.stroke
      object.top_cm = @objects[count].top_cm
      object.left_cm = @objects[count].left_cm
      schema = object.constructor.prototype.getJsonSchema()
      for key of schema.properties
        @objects[count][key] = object[key]


  # Todo:Mapでのみ使う関数だけど、現状haika直下
  # Todo:この部分をnodeモジュールにしてサーバーサイド使えるようにしたい
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
      mapCenter = proj4("EPSG:4326", "EPSG:3857", [@xyLongitude, @xyLatitude])
      if mapCenter
        coordinates = []
        for geometry in object.geometry.coordinates[0]
          x = geometry[0] * @xyScaleFactor
          y = geometry[1] * @xyScaleFactor
          # 回転の反映
          new_coordinate =  fabric.util.rotatePoint(new fabric.Point(x, y), new fabric.Point(0, 0), fabric.util.degreesToRadians(-@xyAngle))
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