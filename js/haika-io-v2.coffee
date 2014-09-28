# haikaのsave, load関連の関数
# haikaを拡張
$.extend haika, 
  revision : null
  setHash : ->
    $(window).off "hashchange"
    location.hash = @id + '@' + @revision
    # ハッシュ変更時に再読み込み
    $(window).bind "hashchange", ->
      location.reload()

  # データのロード
  load : ()->
#    if location.hash!='' and location.hash.length!=7
#      location.hash = sprintf('%06d',location.hash.split('#')[1])
#      location.reload()
#      return
    # ローカルか？
    # location.hashにfloor_idはあるか？
    if location.hash!=''
      hash = location.hash.split('#')[1]
      @id = hash.split('@')[0]
      @revision = hash.split('@')[1]
      # サーバーからロード
      @loadServer()
    else
      # 
      alert('floor id が指定されていません。')
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
        log data
        json = JSON.parse(data)
        if json.locked
          if confirm 'ロックされています。リロードしますか？'
            location.hash = @id
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
        @setHash()
      error: ()=>
        alert 'エラーが発生しました'
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
  save_flag : true
  save : ->
    log 'save'
    # ajaxが終わるまで保存を防ぐ、衝突回避
    if not @save_flag
      setTimeout =>
        @save
      , 500
    @save_flag = false
    for object in @canvas.getObjects()
      @saveProperty(object)
    @saveServer()
    $(@).trigger('haika:save')
  # オブジェクトのプロパティの保存
  saveProperty : (object, group=false)->
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
  # haika.ioに保存
  saveServer : ->
    param = 
      canvas : @getCanvasProperty()
      geojson: @toGeoJSON()
    param = JSON.stringify(param)
    log param
    data =
      ext: 'json'
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
        log data
        json = JSON.parse(data)
        if json.success==false
          alert json.message
        else
          @revision = json.revision
          @collision = json.collision
          @setHash()
        @ave_flag = true
      error: ()=>
        @save_flag = true
        alert  'エラーが発生しました'

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
