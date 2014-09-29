# データの保存と読み込みに関する処理
# GeoJSONフォーマットに関する処理

$.extend haika,
  _dataId: null #編集中のデータのID (外部参照禁止)
  _revision: null #編集中のデータのリビジョン (外部参照禁止)
  _collision: null #衝突検出キー (外部参照禁止)
  _api_load_endpoint: '/api/floor/load' #データ読み込みAPIのエンドポイント
  _api_save_endpoint: '/api/floor/save' #データ保存APIのエンドポイント
  _geojson: {} #編集中のデータのGeoJSON (外部参照禁止)
  nowSaving: false #保存処理中フラグ(true..保存処理中) (外部参照禁止)

# API経由で開いたデータを閉じる
#
  close: ()->
    @_dataId = null
    @_revision = null
    @_collision = null
    @_geojson = {}
    @objects.length = 0
    @background_image = null

# API経由でデータを開く
#
# @param {Number} id データのID
# @option {Number} id データのリビジョン(省略時は最新)
# @option {Function} success 成功時のコールバック関数
# @option {Function} error(message) エラー時のコールバック関数
#
  openFromApi: (id, revision = null, success = null, error = null) ->
    if @_dataId
      @close() #開いたデータがある場合は閉じる
    if @nowSaving
      error and error('保存処理中のため読み込めませんでした')
    $.ajax
      url: @_api_load_endpoint
      type: 'POST'
      cache: false
      dataType: 'json'
      data:
        id: id
        revision: revision
      error: ()=>
        error and error('データが読み込めませんでした')
      success: (json)=>
        if json.locked
          # TODO : Read Onlyモードに切り替える
          return error and error('データはロックされています')
        @_dataId = json.id
        @_revision = json.revision
        @_collision = json.collision
        @_geojson = json.data
        @loadFromGeoJson()
        $(@).trigger('haika:load')
        success and success()

# GeoJsonからデータを読み込む
#
# @param {Object} geojson
#
  loadFromGeoJson: (geojson=null)-> # GeoJsonからデータを読み込む
    if not geojson
      geojson=@_geojson
    @options.bgscale = if geojson.haika.bgscale then geojson.haika.bgscale else 4.425
    @options.bgopacity = geojson.haika.bgopacity
    if geojson.haika.bgurl?
      @options.bgurl = geojson.haika.bgurl
    else
      @options.bgurl = ''
    @options.angle = geojson.haika.angle
    if geojson.haika.geojson_scale?
      @options.geojson_scale = geojson.haika.geojson_scale
    if geojson.haika.lon? and geojson.haika.lat?
      @options.lon = parseFloat(geojson.haika.lon)
      @options.lat = parseFloat(geojson.haika.lat)
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
    @render()


# キャンバスのプロパティを取得
  getCanvasProperty: ->
    return {
    state: @state
    scale: @scale
    centerX: @centerX
    centerY: @centerY
    bgurl: @options.bgurl
    bgscale: @options.bgscale
    bgopacity: @options.bgopacity
    lon: @options.lon
    lat: @options.lat
    angle: @options.angle
    geojson_scale: @options.geojson_scale
    }
# 保存
  saveTimeout: null
  save: ->
    @prepareData()

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
      id: @_dataId
      revision: @_revision
      collision: @_collision
      data: param
    $.ajax
      url: @_api_save_endpoint
      type: 'POST'
      data: data
      dataType: 'text'
      success: (data)=>
#        log data
        json = JSON.parse(data)
        if json.success == false
          alert json.message
          location.reload()
        else
          @_revision = json.revision
          @_collision = json.collision
        @nowSaving = false
        if @saveTimeout
          clearTimeout(@saveTimeout)
          @saveTimeout = null
      error: ()=>
        @nowSaving = false
        if @saveTimeout
          clearTimeout(@saveTimeout)
          @saveTimeout = null
        alert 'エラーが発生しました'
    $(@).trigger('haika:save')
  saveDelay: ->
    @prepareData()
    if not @saveTimeout
      clearTimeout(@saveTimeout)
    @saveTimeout = setTimeout =>
      @save()
    , 2000
# オブジェクトのプロパティの保存
  prepareData: ()->
    for object in @canvas.getObjects()
      count = @getCountFindById(object.id)
      @objects[count].id = object.id
      @objects[count].type = object.type
      @objects[count].top_cm = @transformTopY_px2cm(object.top)
      object.top_cm = @objects[count].top_cm
      @objects[count].left_cm = @transformLeftX_px2cm(object.left)
      object.left_cm = @objects[count].left_cm
      @objects[count].scaleX = object.scaleX / @scale
      @objects[count].scaleY = object.scaleY / @scale
      @objects[count].angle = object.angle
      @objects[count].fill = object.fill
      @objects[count].stroke = object.stroke
      schema = object.constructor.prototype.getJsonSchema()
      for key of schema.properties
        @objects[count][key] = object[key]
# オブジェクトをgeojsonに変換
  toGeoJSON: ->
    features = []
    for object in @canvas.getObjects()
      geojson = object.toGeoJSON()
      features.push(geojson)
    data =
      "type": "FeatureCollection"
      "features": features
    return data
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