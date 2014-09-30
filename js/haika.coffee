log = (obj) ->
  try
    console.log obj

haika =
  CONST_LAYERS: #現在のステータス [オプション定数]
    SHELF: 0
    WALL: 1
    FLOOR: 2
    BEACON: 3

  canvas: null # fabricのCanvasオブジェクト

  centerX: 0 # 表示位置X(画面の中央が0) [エディタステータス系変数]
  centerY: 0 # 表示位置Y(画面の中央が0) [エディタステータス系変数]
# Todo: fabricオブジェクトからの呼び出しについて検討の必要あり
  scaleFactor: 1 #表示倍率 [エディタステータス系変数] (このファイル外で使用禁止)
  layer: null #現在のレイヤー(CONST_LAYERS) [エディタステータス系変数]
  backgroundImage: null #背景画像のキャッシュ [エディタ内部利用]

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
  xyScaleFactor: 1.5

  clipboard: []
  clipboard_scale: 0

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
    if not options.width?
      options.width = 500
    if not options.height?
      options.height = 500
    canvas = new fabric.Canvas(options.canvasId, {
      rotationCursor: 'url("img/rotate.cur") 10 10, crosshair'
      width: options.width
      height: options.height
    })
    if options.scaleFactor?
      @scaleFactor = options.scaleFactor

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
        @backgroundImage.render ctx
      ctx.mozImageSmoothingEnabled = true
      fabric.drawGridLines(ctx)

    initAligningGuidelines(canvas)
    @layer = @CONST_LAYERS.SHELF
    @canvas = canvas

    @canvas.on('object:selected', (e)=>
      object = e.target
      if object._objects?
        object.lockScalingX = true
        object.lockScalingY = true
      @setPropetyPanel()
    )
    @canvas.on 'before:selection:cleared', (e)=>
      @canvas.deactivateAll()
      @editor_change()
      @setPropetyPanel()
    @canvas.on 'object:scaling', (e) =>
      object = e.target
      if object.__resizeShelf?
        object.__resizeShelf()
    @canvas.on 'object:modified', (e)=>
      object = e.target
      if object.__modifiedShelf?
        object.__modifiedShelf()
      @saveDelay()
      @setPropetyPanel()
    haika.openFromApi(2,
      {
        succcess: (message)->
          alert(message)
        error: =>
          @render()
      }
    )
    $(@).trigger('haika:initialized')

# 拡大率の新しい値に設定する
#
# @param [Number] newScale 新しい拡大率(0.05~4=5~400%)
#
  setScale: (newScale) ->
    @canvas.deactivateAll()
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

# 表示時の拡大率を等倍にする (これはUI側のため将来的に移動)
#
  zoomReset: ->
    @setScale 1

  setBackgroundUrl: (url) ->
    @backgroundImage = null
    @backgroundUrl = url
    @render()

#(これはUI側のため将来的に移動)
  loadBgFromUrl: (url) ->
    @setBackgroundUrl url

#(これはUI側のため将来的に移動)
  resetBg: ->
    @setBackgroundUrl ''

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
# haikaオブジェクトの追加
  add: (object)->
    object.id = @_getLatestId()
    o =
      id: object.id
    props = [
      'type'
      'width'
      'height'
      'scaleX'
      'scaleY'
      'left'
      'top'
      'angle'
      'fill'
      'stroke'
    ]
    schema = object.constructor.prototype.getJsonSchema()
    for key of schema.properties
      props.push(key)
    for prop in props
      if prop == 'top'
        o.top_cm = @transformTopY_px2cm(object.top)
        continue
      if prop == 'left'
        o.left_cm = @transformLeftX_px2cm(object.left)
        continue
      o[prop] = object[prop]
    @objects.push(o)
    $(@).trigger('haika:add')
    return o.id

# fabric上のオブジェクトの取得 共通関数
  getObjects: (func, do_active = true)->
    object = @canvas.getActiveObject()
    if object
      new_id = func(object)
      if new_id and do_active
        $(@canvas.getObjects()).each (i, obj)=>
          if obj.id == new_id
            @canvas.setActiveObject(obj)
    group = @canvas.getActiveGroup()
    if group
      new_ids = []
      for object in group.getObjects()
        new_id = func(object)
        new_ids.push(new_id)
      if do_active
        @activeGroup(new_ids)
      else
        @render()
# アクティブなグループを設定
  activeGroup: (new_ids)->
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
    @canvas._activeObject = null
    @canvas.setActiveGroup(group.setCoords()).renderAll()
# 削除
  remove: ->
    @getObjects((object)=>
      @__remove(object)
    , false)
    $(@).trigger('haika:remove')
  __remove: (object)->
    @canvas.remove(object)
    count = @getCountFindById(object.id)
    @objects.splice(count, 1)
    return object
# 最前面に移動
  bringToFront: ->
    @getObjects((object)=>
      count = @getCountFindById(object.id)
      object.bringToFront()
      obj = @objects[count]
      @objects.splice(count, 1)
      @objects.push(obj)
      return obj.id
    )
# 複製
  duplicate: ->
    object = @canvas.getActiveObject()
    if object
      o = fabric.util.object.clone(object)
      o.top = @transformTopY_cm2px(@centerY)
      o.left = @transformLeftX_cm2px(@centerX)
      new_id = @add(o)
    group = @canvas.getActiveGroup()
    if group
      new_ids = []
      for object in group.getObjects()
        o = fabric.util.object.clone(object)
        o.top = @transformTopY_cm2px(@centerY) + object.top
        o.left = @transformLeftX_cm2px(@centerX) + object.left
        new_id = @add(o)
        new_ids.push(new_id)
    @saveDelay()
    @render()
    if object
      $(@canvas.getObjects()).each (i, obj)=>
        if obj.id == new_id
          @canvas.setActiveObject(obj)
    if group
      @activeGroup(new_ids)
    $(@).trigger('haika:duplicate')
# コピー
  copy: ->
    @clipboard = []
    object = @canvas.getActiveObject()
    if object
      @clipboard.push(fabric.util.object.clone(object))
    group = @canvas.getActiveGroup()
    if group
      for object in group.getObjects()
        @clipboard.push(fabric.util.object.clone(object))
    @clipboard_scale = @scaleFactor
    $(@).trigger('haika:copy')
# ペースト
  paste: ->
    # クリップボードになにもない
    if @clipboard.length <= 0
      return
    # クリップボードに１つ
    if @clipboard.length == 1
      object = @clipboard[0]
      o = fabric.util.object.clone(object)
      o.top = @transformTopY_cm2px(@centerY)
      o.left = @transformLeftX_cm2px(@centerX)
      new_id = @add(o)
      @saveDelay()
      @render()
      $(@canvas.getObjects()).each (i, obj)=>
        if obj.id == new_id
          @canvas.setActiveObject(obj)
      # クリップボードに複数
    else
      new_ids = []
      for object in @clipboard
        o = fabric.util.object.clone(object)
        o.top = @transformTopY_cm2px(@centerY) + object.top * @scaleFactor / @clipboard_scale
        o.left = @transformLeftX_cm2px(@centerX) + object.left * @scaleFactor / @clipboard_scale
        new_id = @add(o)
        new_ids.push(new_id)
      @saveDelay()
      log 'pre render' + @clipboard[0].top
      @render()
      log 'after render' + @clipboard[0].top
      @activeGroup(new_ids)
      $(@).trigger('haika:paste')
# すべてを選択(全レイヤー)
  selectAll: ()->
    @canvas.discardActiveGroup()
    objects = @canvas.getObjects().map((o) ->
      o.set "active", true
    )
    group = new fabric.Group(objects,
      originX: "center"
      originY: "center"
    )
    @canvas._activeObject = null
    @canvas.setActiveGroup(group.setCoords()).renderAll()
# すべての選択解除
  unselectAll: ()->
    @canvas.deactivateAll().renderAll()
# 選択解除
  unselect: ->
    object = @canvas.getActiveObject()
    if not object
      object = @canvas.getActiveGroup()
    if object
      @canvas.fire('before:selection:cleared', { target: object })
      @canvas.fire('selection:cleared', { target: object })
# クラス名の取得
  getClass: (classname)->
    if classname == 'shelf'
      return fabric.Shelf
    else if classname == 'curved_shelf'
      return fabric.curvedShelf
    else if classname == 'beacon'
      return fabric.Beacon
    else if classname == 'wall'
      return fabric.Wall
    else if classname == 'floor'
      return fabric.Floor
    else
      return fabric.Shelf
# canvasの描画
  render: ->
    #オブジェクトをクリア
    if not @backgroundImage and @backgroundUrl
      fabric.Image.fromURL @backgroundUrl, (img)=>
        @backgroundImage = img
        @render()
        return
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
      if o.type.match(/shelf$/)
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
    if @backgroundImage
      @canvas.setBackgroundImage @backgroundImage
      @backgroundImage.left = Math.floor(@transformLeftX_cm2px(@backgroundImage._originalElement.width / 2 * @backgroundScaleFactor))
      @backgroundImage.top = Math.floor(@transformTopY_cm2px(@backgroundImage._originalElement.height / 2 * @backgroundScaleFactor))
      @backgroundImage.width = Math.floor(@backgroundImage._originalElement.width * @backgroundScaleFactor * @scaleFactor)
      @backgroundImage.height = Math.floor(@backgroundImage._originalElement.height * @backgroundScaleFactor * @scaleFactor)
      @backgroundImage.opacity = @backgroundOpacity
    else
      @canvas.setBackgroundImage null
    @canvas.renderAll()
    @canvas.renderOnAddRemove = true
    @setCanvasProperty()
    $(@).trigger('haika:render')


# canvasにオブジェクトを追加
  addObjectToCanvas: (o)->
    klass = @getClass(o.type)
    object = new klass()
    if o.type.match(/shelf$/)
      object.side = o.side
      object.count = o.count
      object.eachWidth = o.eachWidth
      object.eachHeight = o.eachHeight

    object.id = o.id
    object.scaleX = object.scaleY = 1
    if o.type == 'wall' or o.type == 'floor'
      object.width_scale = o.width_scale
      object.height_scale = o.height_scale
    object.width = object.__width()
    object.height = object.__height()
    object.top = @transformTopY_cm2px(o.top_cm)
    object.left = @transformLeftX_cm2px(o.left_cm)
    object.top_cm = o.top_cm
    object.left_cm = o.left_cm
    object.angle = o.angle
    object.originX = 'center'
    object.originY = 'center'
    if o.type == 'beacon'
      object.fill = "#000000"
      object.hasControls = false
      object.padding = 10
      object.borderColor = "#0000ee"
    else if o.type == 'wall'
      object.fill = "#000000"
      object.borderColor = "#000000"
    else if o.type == 'floor'
      object.fill = ""
      object.borderColor = "#000000"
    else
      object.borderColor = "#000000"
      object.fill = o.fill
      object.padding = 0
    object.stroke = o.stroke
    object.transparentCorners = false
    object.cornerColor = "#488BD4"
    object.borderOpacityWhenMoving = 0.8
    object.cornerSize = 10
    schema = object.constructor.prototype.getJsonSchema()
    for key of schema.properties
      object[key] = o[key]

    #現在のレイヤーかどうか
    if ((o.type == 'shelf' or o.type == 'curvedShelf') and @layer == @CONST_LAYERS.SHELF) or (o.type == 'wall' and @layer == @CONST_LAYERS.WALL) or (o.type == 'beacon' and @layer == @CONST_LAYERS.BEACON) or (o.type == 'floor' and @layer == @CONST_LAYERS.FLOOR)
      object.selectable = true
    else
      object.selectable = false
      object.opacity = 0.5

    @canvas.add(object)

# キャンバスのプロパティを設定
  setCanvasProperty: ->
    $('#canvas_width').html(@canvas.getWidth())
    $('#canvas_height').html(@canvas.getHeight())
    $('#canvas_centerX').html(@centerX)
    $('#canvas_centerY').html(@centerY)
    $('#canvas_bgscale').val(@backgroundScaleFactor)
    $('#canvas_bgopacity').val(@backgroundOpacity)
    $('#canvas_lon').val(@xyLongitude)
    $('#canvas_lat').val(@xyLatitude)
    $('#canvas_angle').val(@canvas.angle)
    $('.zoom').html((@scaleFactor * 100).toFixed(0) + '%')
# 移動ピクセル数を取得
  getMovePixel: (event)->
    return if event.shiftKey then 10 else 1
# 上に移動
  up: (event)->
    object = @canvas.getActiveObject()
    if object
      object.top = object.top - @getMovePixel(event)
      @canvas.renderAll()
# 下に移動
  down: (event)->
    object = @canvas.getActiveObject()
    if object
      object.top = object.top + @getMovePixel(event)
      @canvas.renderAll()
# 左に移動
  left: (event)->
    object = @canvas.getActiveObject()
    if object
      object.left = object.left - @getMovePixel(event)
      @canvas.renderAll()
# 右に移動
  right: (event)->
    object = @canvas.getActiveObject()
    if object
      object.left = object.left + @getMovePixel(event)
      @canvas.renderAll()
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
      @canvas.renderAll()
# 横中央に整列
  alignCenter: ()->
    group = @canvas.getActiveGroup()
    if group._objects
      for object in group._objects
        object.left = 0
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
      @canvas.renderAll()
# 縦中央に整列
  alignVcenter: ()->
    group = @canvas.getActiveGroup()
    if group._objects
      for object in group._objects
        object.top = 0
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