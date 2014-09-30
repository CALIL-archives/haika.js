# データの保存と読み込みに関する処理
# GeoJSONフォーマットに関する処理

$.extend haika,
  _api_load_endpoint: '/api/floor/load' #データ読み込みAPIのエンドポイント (定数)
  _api_save_endpoint: '/api/floor/save' #データ保存APIのエンドポイント (定数)

  _dataId: null #編集中のデータのID (外部参照禁止)
  _revision: null #編集中のデータのリビジョン (外部参照禁止)
  _collision: null #衝突検出キー (外部参照禁止)
  _geojson: {} #編集中のデータのGeoJSON (外部参照禁止)
  _nowSaving: false #保存処理中フラグ(true..保存処理中) (外部参照禁止)
  _autoSaveTimerId: null #自動保存用のタイマーID (外部参照禁止)


# API経由で開いたデータを閉じる
#
  close: ()->
    @_dataId = null
    @_revision = null
    @_collision = null
    @_geojson = {}
    @objects.length = 0
    @backgroundImage = null


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
    if @_nowSaving
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
# @param {Object} geojson 省略時は保持しているデータを読み込む
#
  loadFromGeoJson: (geojson = null)-> # GeoJsonからデータを読み込む
    if not geojson
      geojson = @_geojson
    @options.backgroundScaleFactor = if geojson.haika.backgroundScaleFactor then geojson.haika.backgroundScaleFactor else 1
    @options.backgroundOpacity = geojson.haika.backgroundOpacity
    if geojson.haika.backgroundUrl?
      @options.backgroundUrl = geojson.haika.backgroundUrl
    else
      @options.backgroundUrl = ''
    if geojson.haika.xyAngle?
      @options.xyAngle = geojson.haika.xyAngle
    if geojson.haika.xyScaleFactor?
      @options.xyScaleFactor = geojson.haika.xyScaleFactor
    if geojson.haika.xyLongitude? and geojson.haika.xyLatitude?
      @options.xyLongitude = parseFloat(geojson.haika.xyLongitude)
      @options.xyLatitude = parseFloat(geojson.haika.xyLatitude)
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


# API経由で開いたデータを保存
#
# @option {Function} success 成功時のコールバック関数
# @option {Function} error(message) エラー時のコールバック関数
#
  save: (success = null, error = null) ->
    @prepareData()

    log 'save'
    # 遅延タイマーより先に明示的な保存があった場合はタイマーを解除
    if @_autoSaveTimerId
      clearTimeout(@_autoSaveTimerId)
      @_autoSaveTimerId = null

    # 保存処理中の場合は500ms後に再実行
    if @_nowSaving
      setTimeout =>
        @save(success, error)
      , 500
      return

    @_nowSaving = true
    data =
      id: @_dataId
      revision: @_revision
      collision: @_collision
      data: JSON.stringify(@toGeoJSON())
    $.ajax
      url: @_api_save_endpoint
      type: 'POST'
      data: data
      dataType: 'json'
      success: (json)=>
        @_nowSaving = false
        if not json.success
          error and error(json.message)
          # Todo: コンポーネント内からのalertは撤去する方針
          alert json.message
          location.reload()
          return
        @_revision = json.revision
        @_collision = json.collision
        success and success()
        $(@).trigger('haika:save')
      error: ()=>
        @_nowSaving = false
        error and error('データが保存できませんでした')


# API経由で開いたデータを遅延して保存
#
# @option {Number} delay 遅延時間(ミリ秒)
# @option {Function} success 成功時のコールバック関数
# @option {Function} error(message) エラー時のコールバック関数
#
  saveDelay: (delay = 2000, success = null, error = null) ->
    log 'save-delay'
    @prepareData()
    if @_autoSaveTimerId
      clearTimeout(@_autoSaveTimerId)
      @_autoSaveTimerId = null
    @_autoSaveTimerId = setTimeout =>
      @_autoSaveTimerId = null
      @save(success, error)
    , delay


