#new fabric.StaticCanvas


log = (obj) ->
  try
    console.log obj

haika =
  INSTALLED_OBJECTS: {} # インストールされたオブジェクト
  # オブジェクト、レイヤーの追加
  addObject: (name, layer, klass)->
    @INSTALLED_OBJECTS[name] =
      'layer': layer
      'class': klass


  canvas: null # fabricのCanvasオブジェクト
  centerX: 0 # 表示位置X(画面の中央が0) [エディタステータス系変数]
  centerY: 0 # 表示位置Y(画面の中央が0) [エディタステータス系変数]
  layer: null # 現在のレイヤー(CONST_LAYERS) [エディタステータス系変数]
  scaleFactor: 1 # 表示倍率 [エディタステータス系変数] (このファイル外で使用禁止)
# 外部からこの値を変更する場合はsetScaleメソッドを使うこと
# Todo: fabricオブジェクトからの呼び出しについて検討の必要あり

  objects: []
  _geojson: {} # 編集中のデータのGeoJSON

  backgroundUrl: null
  backgroundOpacity: 1
  backgroundScaleFactor: 1
  xyLongitude: null
  xyLatitude: null
  xyAngle: 0
  xyScaleFactor: 1

  clipboard: []

# 座標変換関数
  cm2px: (cm)->
    return cm * @scaleFactor
  cm2px_x: (cm)->
    return @canvas.getWidth() / 2 + (cm + @centerX) * @scaleFactor
  cm2px_y: (cm)->
    return @canvas.getHeight() / 2 + (cm + @centerY) * @scaleFactor
  px2cm_x: (px)->
    return Math.floor((px - @canvas.getWidth() / 2) / @scaleFactor - @centerX)
  px2cm_y: (px)->
    return Math.floor((px - @canvas.getHeight() / 2) / @scaleFactor - @centerY)

# プラグインのクラスを格納する配列
  plugins: []

#初期化
#
# @param [Object] options 初期化オプション
# @param options [String] containerSelector 各プラグインのHTMLを流し込むDIVのセレクター
# @param options [String] divId HTML上のCanvasのID
# @param options [String] canvasId HTML上のCanvasのID
# @option options [Number] width Canvasの幅
# @option options [Number] height Canvasの高さ
# @option options [Number] scaleFactor 表示倍率
#
  options:
    containerSelector  : '.haika-container'
    divId      : 'haika-canvas'
    canvasId   : 'haika-canvas-area'
    scaleFactor: 1
    layer      : 0
  init: (options)->
    # オプションのマージ
    options = $.extend(@options, options)
    @scaleFactor = options.scaleFactor
    @layer = options.layer
    $haikaDiv = $('#'+options.divId)
    canvas = new fabric.Canvas(options.canvasId, {
#    canvas = new fabric.StaticCanvas(options.canvasId, {
      width: $haikaDiv.width()
      height: $haikaDiv.height()
#      rotationCursor: 'url("img/rotate.cur") 10 10, crosshair'
    })
    canvas.selectionBorderColor = 'black'
    canvas.selectionLineWidth = 1
    canvas.selectionDashArray = [2, 2]

    $(window).resize =>
      @canvas.setWidth($haikaDiv.width())
      @canvas.setHeight($haikaDiv.height())
      @render()

    # fabricオブジェクトの共通設定
    fabric.Object.prototype.scaleX = 1
    fabric.Object.prototype.scaleY = 1
    fabric.Object.prototype.originX = 'center'
    fabric.Object.prototype.originY = 'center'
    fabric.Object.prototype.transparentCorners = true
    fabric.Object.prototype.cornerColor = "#488BD4"
    fabric.Object.prototype.borderOpacityWhenMoving = 0.8
    fabric.Object.prototype.cornerSize = 10

    @canvas = canvas

    # オブジェクトのイベント設定
    # Todo: 複数選択して回転した場合が保存されない
    @canvas.on 'object:selected', (e)=>
      object = e.target
      if object._objects?
        object.lockScalingX = true
        object.lockScalingY = true

    @canvas.on 'object:rotating', (e) =>
      object = e.target
      if object.__rotating?
        object.__rotating()
    @canvas.on 'object:moving', (e) =>
      object = e.target
      if @readOnly
        return
      if object.__moving?
        object.__moving()
    @canvas.on 'object:scaling', (e) =>
      object = e.target
      if object.__resizeShelf?
        object.__resizeShelf()
    @canvas.on 'object:modified', (e)=>
      object = e.target
      if object.__modifiedShelf?
        object.__modifiedShelf()
      @_save()

  _save: (object)->
    log('save')
    object = @canvas.getActiveObject()
    group  = @canvas.getActiveGroup()
    if group
      # グループ選択の場合
      # グループで回転した場合、group.objectsには回転する前のオブジェクトが入っているため
      # objectを複製して、group._setObjectPositionを適用する
      for object in group.objects
        o = $.extend({}, object)
        group._setObjectPosition(o)
        @setGeoJSONFromObject(o)
    else
      # 単体選択の場合
      @setGeoJSONFromObject(object)
    if @save?
      @save()

  # GeoJSONを更新する
  setGeoJSONFromObject: (object)->
    object.top_cm = @px2cm_y(object.top)
    object.left_cm = @px2cm_x(object.left)
    o = @locateObjectFromId(object.id)
    # オブジェクトをGeoJSONに変換
    feature = object.toGeoJSON()
    # プロパティを更新
    $.extend(o.geometry, feature.geometry)
    $.extend(o.properties, feature.properties)

  # 該当するオブジェクトをJSONから探す
  locateObjectFromId: (id)->
    for o in @_geojson.features
      if o.properties.id==id
        log(o)
        return o
    return false

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


# クラス名の取得
  getClass: (type)->
    if @INSTALLED_OBJECTS[type]?
      return @INSTALLED_OBJECTS[type].class
    else
      return '認識できないオブジェクト('+type+')が含まれています'

# canvasの描画
  render: ->
    @canvas.renderOnAddRemove = false
    @canvas._objects.length = 0
    for o in @objects
      # 現在のレイヤーなら選択可能に
      if @layer == @INSTALLED_OBJECTS[o.type].layer
        o.selectable = true
      else
        o.selectable = false
      @addObjectToCanvas(o)

    @canvas.renderAll(true)
    @canvas.renderOnAddRemove = true
    $(@).trigger('haika:render')


# canvasにオブジェクトを追加
  addObjectToCanvas: (o)->
    klass = @getClass(o.type)
    if typeof(klass)!='function'
      return log(klass)
    object = new klass(o)
    #    log object.toObject()
    object.width = object.__width()
    object.height = object.__height()
    object.top = @cm2px_y(o.top_cm)
    object.left = @cm2px_x(o.left_cm)
    object.selectable = o.selectable

    @canvas.add(object)
