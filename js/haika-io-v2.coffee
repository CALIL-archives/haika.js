# haikaのsave, load関連の関数
# haikaを拡張
$.extend haika, 
  revision : null
  # データのロード
  load : ()->
    # URLにfloor_idはあるか？
    @id = 2
    # サーバーからロード
    @loadServer()
#    else
#      alert('floor id が指定されていません。')
    $(@).trigger('haika:load')
  # サーバーからデータをロード
  loadServer : ->
    url = '/api/floor/load'
    data = 
      id: @id
      revision: @revision
    $.ajax
      url: url
      type: 'POST'
      cache : false
      dataType: 'text'
      data: data
      success: (data)=>
#        log data
        json = JSON.parse(data)
        if json.locked
          if confirm 'ロックされています。リロードしますか？'
            location.reload()
        else
#        try
#        catch
#          alert 'parse error'
#          $(window).off 'beforeunload'
#          location.href = """http://lab.calil.jp/haika_store/data/#{@id}.json"""
        @revision = json.revision
        @collision = json.collision
        @loadRender(json.data)
      error: ()=>
        alert 'エラーが発生しました'
  # ロードして描画
  loadRender : (data)->
#    log data
    canvas = data.haika
    geojson = data
    if canvas
#      log canvas
      @state   = canvas.state
      $('.nav a.'+@state).tab('show')
      @scale   = canvas.scale
      $('.zoom').html((@scale*100).toFixed(0)+'%')
      @centerX = canvas.centerX
      @centerY = canvas.centerY
      @bgimg_data = canvas.bgimg_data
      @options.bgscale = if canvas.bgscale then canvas.bgscale else 4.425
      @options.bgopacity = canvas.bgopacity
      @options.angle = canvas.angle
      if canvas.geojson_scale?
        @options.geojson_scale = canvas.geojson_scale
      else
        if canvas.bgurl?
          @loadBgFromUrl(canvas.bgurl)
      if canvas.lon?
        @options.lon = parseFloat(canvas.lon)
        @options.lat = parseFloat(canvas.lat)
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
      geojson_scale: @options.geojson_scale
    }
  # 保存
  nowSaving : false
  saveTimeout: null
  save : ->
    log 'save'
    # ajaxが終わるまで保存を防ぐ、衝突回避
    if @nowSaving
      setTimeout =>
        @save()
      , 500
      return
    @nowSaving = true
    param = @toGeoJSON()
    param['haika'] = @getCanvasProperty()
    param['haika']['version'] = 1
    param = JSON.stringify(param)
#    log param
    data =
      id  : @id
      revision: @revision
      collision: @collision
      data: param
#    log data
    url = '/api/floor/save'
    $.ajax
      url: url
      type: 'POST'
      data: data
      dataType: 'text'
      success: (data)=>
#        log data
        json = JSON.parse(data)
        if json.success==false
          alert json.message
          location.reload()
        else
          @revision = json.revision
          @collision = json.collision
        @nowSaving = false
        if @saveTimeout
          clearTimeout(@saveTimeout)
          @saveTimeout = null
      error: ()=>
        @nowSaving = false
        if @saveTimeout
          clearTimeout(@saveTimeout)
          @saveTimeout = null
        alert  'エラーが発生しました'
    $(@).trigger('haika:save')
  saveDelay : ->
    if not @saveTimeout
      clearTimeout(@saveTimeout)
    @saveTimeout = setTimeout =>
      @save()
    , 2000
  # オブジェクトのプロパティの保存
  prepareData : ()->
    for object in @canvas.getObjects()
      count = @getCountFindById(object.id)
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
        @objects[count][key] = object[key]
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
  # オブジェクトをSVGに変換
  toSVG : ->
    svgs = []
    for object in @canvas.getObjects()
      svg = object.toSVG()
      svgs.push(svg)
    log svgs
    start = '<svg viewBox="0 0 1024 768">'
    end   = '</svg>'
    data = [start, svgs.join(''), end].join('')
    log data
    return data
  import : ->
    id = window.prompt('idを入力してください', '')
    url = """http://lab.calil.jp/haika_store/data/#{@id}.json"""
    $.ajax
      url: url
      type: 'GET'
      cache : false
      dataType: 'text'
      success: (data)=>
        json = JSON.parse(data)
        canvas = json.canvas
        json.geojson.haika = json.canvas
        @loadRender(json.geojson)
      error: ()=>
        alert '読み込めません'