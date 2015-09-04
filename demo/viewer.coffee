#new fabric.StaticCanvas


log = (obj) ->
  try
    console.log obj

haika =
  CONST_LAYERS: #現在のステータス [オプション定数]
    SHELF: 0
    BEACON: 1
    WALL: 2
    FLOOR: 3

  INSTALLED_OBJECTS: # インストールされたオブジェクト
    'shelf':
      'layer': 0
      'class': fabric.Shelf
    'curved_shelf':
      'layer': 0
      'class': fabric.curvedShelf
    'beacon':
      'layer': 1
      'class': fabric.Beacon
    'wall':
      'layer': 2
      'class': fabric.Wall
    'floor':
      'layer': 3
      'class': fabric.Floor

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
    scaleFactor: 0.1
  init: (options)->
    # オプションのマージ
    options = $.extend(@options, options)
    @scaleFactor = options.scaleFactor
    $haikaDiv = $('#'+options.divId)
#    canvas = new fabric.Canvas(options.canvasId, {
    canvas = new fabric.StaticCanvas(options.canvasId, {
      width: $haikaDiv.width()
      height: $haikaDiv.height()
      rotationCursor: 'url("img/rotate.cur") 10 10, crosshair'
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
      throw '認識できないオブジェクトが含まれています'

# canvasの描画
  render: ->
    @canvas.renderOnAddRemove = false
    @canvas._objects.length = 0
    for o in @objects
      @addObjectToCanvas(o)

    @canvas.renderAll()
    @canvas.renderOnAddRemove = true
    $(@).trigger('haika:render')


# canvasにオブジェクトを追加
  addObjectToCanvas: (o)->
    klass = @getClass(o.type)
    object = new klass(o)
    #    log object.toObject()
    object.width = object.__width()
    object.height = object.__height()
    object.top = @cm2px_y(o.top_cm)
    object.left = @cm2px_x(o.left_cm)
    object.selectable = o.selectable

    @canvas.add(object)

haika.init()
$.ajax
    url: 'data/sabae.json'
    type: 'GET'
    cache: false
    dataType: 'json'
    error: ()=>
      option.error and option.error('データが読み込めませんでした')
    success: (json)=>
      if json.locked
        @readOnly = true
        return option.error and option.error('データはロックされています')
      haika._dataId = json.id
      haika._revision = json.revision
      haika._collision = json.collision
      haika._geojson = json.data
      haika.loadFromGeoJson()
      $(haika).trigger('haika:load')
      haika.render()


