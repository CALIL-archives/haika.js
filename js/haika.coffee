log = (obj) ->
  try
    console.log obj

# fabricオブジェクトの共通設定
fabric.Object.prototype.scaleX = 1
fabric.Object.prototype.scaleY = 1
fabric.Object.prototype.originX = 'center'
fabric.Object.prototype.originY = 'center'
fabric.Object.prototype.transparentCorners = true
fabric.Object.prototype.cornerColor = "#488BD4"
fabric.Object.prototype.borderOpacityWhenMoving = 0.8
fabric.Object.prototype.cornerSize = 10

haika =
  CONST_LAYERS: #現在のステータス [オプション定数]
    SHELF: 0
    WALL: 1
    FLOOR: 2
    BEACON: 3

  INSTALLED_OBJECTS: # インストールされたオブジェクト
    'shelf': fabric.Shelf
    'curved_shelf': fabric.curvedShelf
    'beacon': fabric.Beacon
    'wall': fabric.Wall
    'floor': fabric.Floor

  canvas: null # fabricのCanvasオブジェクト

  centerX: 0 # 表示位置X(画面の中央が0) [エディタステータス系変数]
  centerY: 0 # 表示位置Y(画面の中央が0) [エディタステータス系変数]
  scaleFactor: 1 #表示倍率 [エディタステータス系変数] (このファイル外で使用禁止)
# 外部からこの値を変更する場合はsetScaleメソッドを使うこと
# Todo: fabricオブジェクトからの呼び出しについて検討の必要あり
  layer: null #現在のレイヤー(CONST_LAYERS) [エディタステータス系変数]

  objects: []
  _geojson: {} #編集中のデータのGeoJSON

  fillColor: "#CFE2F3"
  strokeColor: "#000000"

  backgroundUrl: null
  backgroundOpacity: 1
  backgroundScaleFactor: 1
  xyLongitude: null
  xyLatitude: null
  xyAngle: 0
  xyScaleFactor: 1

  clipboard: []

# 座標変換関数
  transformLeftX_cm2px: (cm)->
    return @canvas.getWidth() / 2 + (@centerX - cm) * @scaleFactor
  transformTopY_cm2px: (cm)->
    return @canvas.getHeight() / 2 + (@centerY - cm) * @scaleFactor
  transformLeftX_px2cm: (px)->
    return @centerX - (px - @canvas.getWidth() / 2) / @scaleFactor
  transformTopY_px2cm: (px)->
    return @centerY - (px - @canvas.getHeight() / 2) / @scaleFactor


#初期化
#
# @param [Object] options 初期化オプション
# @param options [String] canvasId HTML上のCanvasのID
# @option options [Number] width Canvasの幅
# @option options [Number] height Canvasの高さ
# @option options [Number] scaleFactor 表示倍率
#
  init: (options)->
    if not options.canvasId?
      throw 'CanvasのIDが未定義です'
    if canvas
      throw '既に初期化されています'
    @scaleFactor = if options.scaleFactor? then options.scaleFactor else 1
    @layer = @CONST_LAYERS.SHELF
    canvas = new fabric.Canvas(options.canvasId, {
      width: if options.width? then options.width else 500
      height: if options.height? then options.height else 500
      rotationCursor: 'url("img/rotate.cur") 10 10, crosshair'
    })

    canvas._getActionFromCorner = (target, corner) ->
      action = 'drag'
      if corner
        if corner == 'ml' || corner == 'mr' || corner == 'tr' || corner == 'tl' || corner == 'bl' || corner == 'br'
          action = 'scaleX'
        else if corner == 'mt' || corner == 'mb'
          action = 'scaleY'
        else if corner == 'mtr'
          action = 'rotate'
      return action

    #背景にグリッドラインを追加するためにオーバーライド
    canvas._renderBackground = (ctx) ->
      ctx.mozImageSmoothingEnabled = false
      if @backgroundImage
        @backgroundImage.left = Math.floor(@parentHaika.transformLeftX_cm2px(@backgroundImage._originalElement.width / 2 * @parentHaika.backgroundScaleFactor))
        @backgroundImage.top = Math.floor(@parentHaika.transformTopY_cm2px(@backgroundImage._originalElement.height / 2 * @parentHaika.backgroundScaleFactor))
        @backgroundImage.width = Math.floor(@backgroundImage._originalElement.width * @parentHaika.backgroundScaleFactor * @parentHaika.scaleFactor)
        @backgroundImage.height = Math.floor(@backgroundImage._originalElement.height * @parentHaika.backgroundScaleFactor * @parentHaika.scaleFactor)
        @backgroundImage.opacity = @parentHaika.backgroundOpacity
        @backgroundImage.render ctx
      ctx.mozImageSmoothingEnabled = true
      fabric.drawGridLines(ctx)

    initAligningGuidelines(canvas)
    @canvas = canvas
    @canvas.parentHaika = @
    @canvas.on('object:selected', (e)=>
      object = e.target
      if object._objects?
        object.lockScalingX = true
        object.lockScalingY = true
      @setPropetyPanel()
    )
    @canvas.on 'before:selection:cleared', (e)=>
      @canvas.discardActiveGroup()
      @editor_change()
      @setPropetyPanel()
    @canvas.on 'object:rotating', (e) =>
      object = e.target
      if object.__rotating?
        object.__rotating()
    @canvas.on 'object:moving', (e) =>
      if e.target.__moving?
        e.target.__moving()
    @canvas.on 'object:scaling', (e) =>
      object = e.target
      if object.__resizeShelf?
        object.__resizeShelf()
    @canvas.on 'object:modified', (e)=>
      object = e.target
      if object.__modifiedShelf?
        object.__modifiedShelf()
      object.top_cm = @transformTopY_px2cm(object.top)
      object.left_cm = @transformLeftX_px2cm(object.left)
      @saveDelay()
      @setPropetyPanel()
    $(@).trigger('haika:initialized')


# 拡大率の新しい値に設定する
#
# @param [Number] newScale 新しい拡大率(0.05~4=5~400%)
#
  setScale: (newScale) ->
    if newScale >= 4
      newScale = 4
    else if newScale <= 0.05
      newScale = 0.05
    @scaleFactor = (newScale * 100).toFixed(0) / 100
    @render()
    return newScale

# 表示時の拡大率を1ステップ拡大する (これはUI側のため将来的に移動)
#
  zoomIn: ->
    prevScale = @scaleFactor
    newScale = prevScale + Math.pow(prevScale + 1, 2) / 20
    if newScale < 1 and prevScale > 1
      newScale = 1
    @setScale newScale

# 表示時の拡大率を1ステップ縮小する (これはUI側のため将来的に移動)
#
  zoomOut: ->
    prevScale = @scaleFactor
    newScale = prevScale - Math.pow(prevScale + 1, 2) / 20
    if prevScale > 1 and newScale < 1
      newScale = 1
    @setScale newScale

  setBackgroundUrl: (url) ->
    @canvas.backgroundImage = null
    @backgroundUrl = url
    @render()

# 新しいオブジェクトのIDを取得
# [この関数は@objectsからデータを取得する]
# [この関数はaddから呼ばれる以外は使用しない]
#
  _getLatestId: ->
    if @objects.length == 0
      return 0
    lastId = 0
    for object in @objects
      if object.id > lastId
        lastId = object.id
    lastId += 1
    return lastId

# idからオブジェクトの配列番号を取得
  getCountFindById: (id)->
    count = null
    $(@objects).each (i, obj)->
      if obj.id == id
        count = i
    return count

# GeoJSONオブジェクトの追加
  addObject: (object)->
#    log object
    object.id = @_getLatestId()
    object.top_cm  = @centerY
    object.left_cm = @centerX
    if not object.fill?
      object.fill   = @fillColor
    if not object.stroke?
      object.stroke = @strokeColor
    if not object.angle?
      object.angle  = 0
    @objects.push(object)
    $(@).trigger('haika:add')
    @render()
    #追加したオブジェクトの選択 描画されるまでの遅延必須
    setTimeout =>
      o = @canvas.item(@getCountFindById(object.id))
      @canvas.setActiveObject(o)
    , 10
    @undo.add(object.id)

#選択中のオブジェクトに一括して処理を適用する
  applyActiveObjects: (func)->
    if @canvas.getActiveObject()
      target = @canvas.getActiveObject()
      func(target)
    else if @canvas.getActiveGroup()
      for target in @canvas.getActiveGroup().getObjects()
        func(target)

# 削除
  remove: ->
    @applyActiveObjects((object)=>
      @canvas.remove(object)
      @objects.splice(@getCountFindById(object.id), 1)
    )
    @canvas.deactivateAll()
    @canvas.renderAll()
    @saveDelay()
    $(@).trigger('haika:remove')

# 最前面に移動
  bringToFront: ->
    @applyActiveObjects((object)=>
      object.bringToFront()
      count = @getCountFindById(object.id)
      obj = @objects[count]
      @objects.splice(count, 1)
      @objects.push(obj)
    )
    @canvas.renderAll()
    @saveDelay()

# コピー
  copy: ->
    @clipboard = []
    @applyActiveObjects((object)=>
      @clipboard.push(object.toGeoJSON().properties)
    )
    $(@).trigger('haika:copy')

# 複製
  duplicate: ->
    _clipboard = @clipboard
    @copy()
    @paste()
    @clipboard = _clipboard
    $(@).trigger('haika:duplicate')

# アクティブなグループを設定
  activeGroup: (new_ids)->
    if new_ids.length == 0
      return
    if new_ids.length == 1
      $(@canvas.getObjects()).each (i, obj)=>
        if obj.id == new_ids[0]
          @canvas.setActiveObject(obj)
      return
    new_objects = []
    for object in @canvas.getObjects()
      for new_id in new_ids
        if object.id == new_id
          new_objects.push(object)
    new_objects = new_objects.map((o) ->
      o.set "active", true
    )
    group = new fabric.Group(new_objects,
      originX: "center"
      originY: "center"
    )
    @canvas.setActiveGroup(group.setCoords()).renderAll()


# ペースト
  paste: ->
    if @clipboard.length > 0
      new_ids = []
      for object in @clipboard
        object.id = @_getLatestId()
        if @clipboard.length == 1
          @clipboard[0].top_cm = @centerY
          @clipboard[0].left_cm = @centerX
        new_ids.push(object.id)
        @objects.push(object)
      @render()
      @saveDelay()
      @activeGroup(new_ids)


    $(@).trigger('haika:paste')

  selectAll: ()->
    @canvas.discardActiveGroup()
    ids = []
    for object in @objects
      ids.push(object.id)
    @activeGroup(ids)

# すべての選択解除
  unselectAll: ()->
    @canvas.deactivateAll().renderAll()

# クラス名の取得
  getClass: (type)->
    if @INSTALLED_OBJECTS[type]?
      return @INSTALLED_OBJECTS[type]
    else
      throw '認識できないオブジェクトが含まれています'

# canvasの描画
  render: ->
    if not @canvas.backgroundImage and @backgroundUrl
      fabric.Image.fromURL @backgroundUrl, (img)=>
        @canvas.backgroundImage = img
        @canvas.renderAll()

    activeIds = []
    @applyActiveObjects((object)=>
      activeIds.push(object.id)
    )

    @canvas.renderOnAddRemove = false
    @canvas._objects.length = 0;
    beacons = []
    shelfs = []
    walls = []
    floors = []
    for o in @objects
      if o.type == 'beacon'
        beacons.push(o)
      if o.type == 'wall'
        walls.push(o)
      if o.type == 'floor'
        floors.push(o)
      if o.type == 'shelf' or o.type == 'curvedShelf'
        shelfs.push(o)
    if @layer != @CONST_LAYERS.FLOOR
      for o in floors
        @addObjectToCanvas(o)
    for o in walls
      @addObjectToCanvas(o)
    if @layer == @CONST_LAYERS.FLOOR
      for o in floors
        @addObjectToCanvas(o)
    for o in shelfs
      @addObjectToCanvas(o)
    for o in beacons
      @addObjectToCanvas(o)
    @activeGroup(activeIds)
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
    object.top = @transformTopY_cm2px(o.top_cm)
    object.left = @transformLeftX_cm2px(o.left_cm)
    #schema = object.constructor.prototype.getJsonSchema()
    #for key of schema.properties
    #  object[key] = o[key]
    #現在のレイヤーかどうか
    if ((o.type == 'shelf' or o.type == 'curvedShelf') and @layer == @CONST_LAYERS.SHELF) or (o.type == 'wall' and @layer == @CONST_LAYERS.WALL) or (o.type == 'beacon' and @layer == @CONST_LAYERS.BEACON) or (o.type == 'floor' and @layer == @CONST_LAYERS.FLOOR)
      object.selectable = true
    else
      object.selectable = false
      object.opacity = 0.5
    @canvas.add(object)

# 移動ピクセル数を取得
  getMovePixel: (event)->
    return if event.shiftKey then 10 else 1
# 上に移動
  up: (event)->
    object = if @canvas.getActiveObject() then @canvas.getActiveObject() else @canvas.getActiveGroup()
    if object
      object.top = object.top - @getMovePixel(event)
      @canvas.renderAll()
      @saveDelay()
# 下に移動
  down: (event)->
    object = if @canvas.getActiveObject() then @canvas.getActiveObject() else @canvas.getActiveGroup()
    if object
      object.top = object.top + @getMovePixel(event)
      @canvas.renderAll()
      @saveDelay()
# 左に移動
  left: (event)->
    object = if @canvas.getActiveObject() then @canvas.getActiveObject() else @canvas.getActiveGroup()
    if object
      object.left = object.left - @getMovePixel(event)
      @canvas.renderAll()
      @saveDelay()
# 右に移動
  right: (event)->
    object = if @canvas.getActiveObject() then @canvas.getActiveObject() else @canvas.getActiveGroup()
    if object
      object.left = object.left + @getMovePixel(event)
      @canvas.renderAll()
      @saveDelay()
# 左に整列
  alignLeft: ()->
    group = @canvas.getActiveGroup()
    if group._objects
      left = 0
      for object in group._objects
        bound = object.getBoundingRect()
        left = Math.min(bound.left, left)
      for object in group._objects
        bound = object.getBoundingRect()
        object.left = left + bound.width / 2
      @saveDelay()
      @canvas.renderAll()
# 右に整列
  alignRight: ()->
    group = @canvas.getActiveGroup()
    if group._objects
      left = 0
      for object in group._objects
        bound = object.getBoundingRect()
        left = Math.max(bound.left + bound.width, left)
      for object in group._objects
        bound = object.getBoundingRect()
        object.left = left - bound.width / 2
      @saveDelay()
      @canvas.renderAll()
# 横中央に整列
  alignCenter: ()->
    group = @canvas.getActiveGroup()
    if group._objects
      for object in group._objects
        object.left = 0
      @saveDelay()
      @canvas.renderAll()
# 上に整列
  alignTop: ()->
    group = @canvas.getActiveGroup()
    if group._objects
      top = 0
      for object in group._objects
        bound = object.getBoundingRect()
        top = Math.min(bound.top, top)
      for object in group._objects
        bound = object.getBoundingRect()
        object.top = top + bound.height / 2
      @saveDelay()
      @canvas.renderAll()
# 下に整列
  alignBottom: ()->
    group = @canvas.getActiveGroup()
    if group._objects
      top = 0
      for object in group._objects
        bound = object.getBoundingRect()
        top = Math.max(bound.top + bound.height, top)
      for object in group._objects
        bound = object.getBoundingRect()
        object.top = top - bound.height / 2
      @saveDelay()
      @canvas.renderAll()
# 縦中央に整列
  alignVcenter: ()->
    group = @canvas.getActiveGroup()
    if group._objects
      for object in group._objects
        object.top = 0
      @saveDelay()
      @canvas.renderAll()

# プロパティパネルの設定
  setPropetyPanel: (object)->
#    log 'setPropetyPanel'
    $('.canvas_panel, .object_panel, .group_panel').hide()
    object = @canvas.getActiveObject()
    if object and object.getJsonSchema?
      @editor.schema = object.getJsonSchema()
      # Set the value
      properties = {}
      for key of @editor.schema.properties
        if @editor.schema.properties[key].type == 'integer'
          value = parseInt(object[key]).toFixed(0)
        else
          value = object[key]
        properties[key] = value
      @editor.setValue properties
      if object.toGeoJSON?
        $('#geojson').val(JSON.stringify(object.toGeoJSON(), null, 4))
      $('.object_panel').show()
      $('#object_id').html(object.id)
      return
    group = @canvas.getActiveGroup()
    if group
      objects = group._objects
      $('#group_count').html(objects.length)
      $('.group_panel').show()
      return
    else
      $('.canvas_panel').show()