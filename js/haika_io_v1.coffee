# haikaのsave, load関連の関数
# haikaを拡張
$.extend haika, 
  # 実行環境 ローカルか？
  isLocal : ->
    return location.protocol=='file:' or location.port!=''
  # ハッシュの変更イベント
  setHashChange : ()->
    # ハッシュ変更時に再読み込み
    $(window).bind "hashchange", ->
      location.reload()
  # データのロード
  load : ()->
    if location.hash!='' and location.hash.length!=7
      location.hash = sprintf('%06d',location.hash.split('#')[1])
      return
    # ローカルか？
    if @isLocal()
      data =
        canvas : JSON.parse(localStorage.getItem('canvas'))
        geojson : JSON.parse(localStorage.getItem('geojson'))
      log data
      @loadRender(data)
      return
    # location.hashにIDはあるか？
    if location.hash!=''
      @id = location.hash.split('#')[1]
      # サーバーからロード
      @load_server()
    else
      # 新規IDの取得, ハッシュに設定
      @getHaikaId()
  # ロードして描画
  loadRender : (data)->
    log data
    canvas = data.canvas
    geojson = data.geojson
    if canvas
      log canvas
      @state   = canvas.state
      $('.nav a.'+@state).tab('show')
      @scale   = canvas.scale
      $('.zoom').html((@scale*100).toFixed(0)+'%')
      @centerX = canvas.centerX
      @centerY = canvas.centerY
      @bgimg_data = canvas.bgimg_data
      @options.bgscale = if canvas.bgscale then canvas.bgscale else 4.425
      @options.bgopacity = canvas.bgopacity
      if @isLocal()
        @setBg()
      else
        if canvas.bgurl?
          @loadBgFromUrl(canvas.bgurl)
      if canvas.lon?
        @options.lon = parseFloat(canvas.lon)
        @options.lat = parseFloat(canvas.lat)
        @options.angle = parseInt(canvas.angle)
    if geojson and geojson.features.length>0
      for object in geojson.features
        if object.properties.id>@lastId
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
#          log key
#          log object.properties[key]
          shape[key] = object.properties[key]
        @add(shape)
    @render()
  # 新規配架図idを取得
  getHaikaId : ->
    url = '/haika_store/index.php'
    $.ajax
      url: url
      type: "GET"
      cache : false
      dataType: "json"
      error: ()->
      success: (data)=>
        location.hash = data.id
        @id = data.id
        @setHashChange()
  # サーバーからデータをロード
  load_server : ->
    url = """/haika_store/data/#{@id}.json"""
    $.ajax
      url: url
      type: "GET"
      cache : false
      dataType: "text"
      error: ()=>
        alert 'load error'
      success: (data)=>
        log data
        try
          data = JSON.parse(data)
        catch
          alert 'parse error'
          $(window).off 'beforeunload'
          location.href = """/haika_store/data/#{@id}.json"""
        @loadRender(data)
        @setHashChange()
  # キャンバスのプロパティを取得
  getCanvasProperty : ->
    return {
      state : @state
      scale : @scale
      centerX : @centerX
      centerY : @centerY
      bgimg_data: @bgimg_data
      bgurl: @options.bgurl
      bgscale : @options.bgscale
      bgopacity : @options.bgopacity
      lon : @options.lon
      lat : @options.lat
      angle: @options.angle
    }
  # ローカルストレージに保存
  saveLocal : ->
    canvas = @getCanvasProperty()
    localStorage.setItem('canvas', JSON.stringify(canvas))
#    localStorage.setItem('app_data', JSON.stringify(@objects))
    localStorage.setItem('geojson', JSON.stringify(@toGeoJSON(), null, 4))
  # サーバーに保存
  saveServer : ->
    param = 
      canvas : @getCanvasProperty()
      geojson: @toGeoJSON()
    param = JSON.stringify(param)
    log param
    data =
      ext: 'json'
      id  : @id
      data: param
#    log data
    url = '/haika_store/index.php'
    $.ajax
      url: url
      type: "POST"
      data: data
      dataType: "json"
      error: ()->
      success: (data)=>
        log data
    @saveGeoJson()
  # geojsonの保存
  saveGeoJson : ->
    geojson = @createGeoJson()
    param = JSON.stringify(geojson)
    data =
      ext: 'geojson'
      id  : @id
      data: param
#    log data
    url = '/haika_store/index.php'
    $.ajax
      url: url
      type: "POST"
      data: data
      dataType: "json"
      error: ()->
      success: (data) >
        log data
        log 'geojson save'
  # 保存
  save : ->
    log 'save'
    for object in @canvas.getObjects()
      @saveProperty(object)
    @saveLocal()
    if not @isLocal()
      @saveServer()
  # オブジェクトのプロパティの保存
  saveProperty : (object, group=false)->
#    log object.__proto__.getJsonSchema()
#    log object.constructor.prototype.getJsonSchema()
    count = @findById(object.id)
    @objects[count].id      = object.id
    @objects[count].type    = object.type
    @objects[count].top_cm  = @transformTopY_px2cm(object.top)
    object.top_cm           = @objects[count].top_cm
    @objects[count].left_cm = @transformLeftX_px2cm(object.left)
    object.left_cm          = @objects[count].left_cm
    @objects[count].scaleX  = object.scaleX / @scale
    @objects[count].scaleY  = object.scaleY / @scale
    @objects[count].angle   = object.angle
    @objects[count].fill    = object.fill
    @objects[count].stroke  = object.stroke
    schema = object.constructor.prototype.getJsonSchema()
    for key of schema.properties
#      log key
#        log object[key]
      @objects[count][key] = object[key]
#      @objects[count].count = object.count
#      @objects[count].side  = object.side
#      @objects[count].eachWidth  = object.eachWidth
#      @objects[count].eachHeight = object.eachHeight
  # オブジェクトをgeojsonに変換
  toGeoJSON : ->
    features = []
    for object in @canvas.getObjects()
      geojson = object.toGeoJSON()
      features.push(geojson)
    data = 
      "type": "FeatureCollection"
      "features": features
    return data
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
            coordinate = ol.proj.transform([x,y], "EPSG:3857", "EPSG:4326")
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
          x = geometry[0]
          y = geometry[1]
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
