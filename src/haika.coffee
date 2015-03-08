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
  readOnly: false # 表示専用モード オブジェクトの移動・変更、保存を行わない [エディタステータス系変数]
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
  cm2px_x: (cm)->
    return @canvas.getWidth() / 2 + (@centerX - cm) * @scaleFactor
  cm2px_y: (cm)->
    return @canvas.getHeight() / 2 + (@centerY - cm) * @scaleFactor
  cm2px: (cm)->
    return cm * @scaleFactor
  px2cm_x: (px)->
    return @centerX - (px - @canvas.getWidth() / 2) / @scaleFactor
  px2cm_y: (px)->
    return @centerY - (px - @canvas.getHeight() / 2) / @scaleFactor

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
    if not options.divId?
      throw 'CanvasのIDが未定義です'
    @divId = '#' + options.divId
    if not options.canvasId?
      options.canvasId = 'haika-canvas-area'
    if options.readOnly?
      @readOnly = options.readOnly
    $(@divId).prepend """<canvas id="#{options.canvasId}" unselectable="on"></canvas>"""
    @scaleFactor = if options.scaleFactor? then options.scaleFactor else 1
    @layer = @CONST_LAYERS.SHELF
    canvas = new fabric.Canvas(options.canvasId, {
      width: $(@divId).width()
      height: $(@divId).height()
      rotationCursor: 'url("img/rotate.cur") 10 10, crosshair'
    })

    #    canvas.selectionColor = 'rgba(0,0,0,0)'
    canvas.selectionBorderColor = 'black'
    canvas.selectionLineWidth = 1
    canvas.selectionDashArray = [2, 2]

    $(window).resize =>
      @canvas.setWidth($(@divId).width())
      @canvas.setHeight($(@divId).height())
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
    if @readOnly
      fabric.Object.prototype.padding = 5
      fabric.Object.prototype.borderColor = '#0000FF'
      fabric.Object.prototype.cornerColor = '#0000FF'

    # seletable=falseのオブジェクトの上で範囲選択ができない問題を修正するパッチ
    fabric.Canvas.prototype._shouldClearSelection = (e, target) ->
      activeGroup = @getActiveGroup()
      # activeObject = @getActiveObject()
      return not target or (target and activeGroup and not activeGroup.contains(target) and activeGroup isnt target and not e.shiftKey) or (target and not target.evented) or (target and not target.selectable)

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

    canvas._renderBackground = (ctx) =>
      convex = new ConvexHullGrahamScan()
      for object in @canvas.getObjects()
        geojson = object.toGeoJSON()
        if geojson.properties.type == 'floor' and geojson.properties.is_negative
          continue
        for item in geojson.geometry.coordinates[0]
          convex.addPoint(-1 * item[0], item[1])
      ret = convex.getHull()
      if ret.length > 0
        convex_path = []
        for i in ret
          p =
            X: i.x
            Y: i.y
          convex_path.push(p)
        clipper = new ClipperLib.Clipper()
        clipper.AddPaths [convex_path], ClipperLib.PolyType.ptSubject, true
        for object in @canvas.getObjects()
          geojson = object.toGeoJSON()
          if geojson.properties.type == 'floor' and geojson.properties.is_negative
            items = geojson.geometry.coordinates[0]
            clip_path = []
            for item in items
              clip_path.push {X: item[0] * -1, Y: item[1]}
            clipper.AddPaths [clip_path], ClipperLib.PolyType.ptClip, true

        result_paths = new ClipperLib.Paths()
        clipper.Execute ClipperLib.ClipType.ctDifference,
          result_paths,
          ClipperLib.PolyFillType.pftNonZero,
          ClipperLib.PolyFillType.pftNonZero
        @floor_cache=result_paths
      else
        @floor_cache=null

      if @floor_cache
        ctx.save()
        ctx.beginPath()
        ctx.lineWidth = Math.floor(Math.min(20,Math.max(3,200*@scaleFactor)))
        log Math.floor(Math.min(20,Math.max(5,20*@scaleFactor)))
        ctx.strokeStyle = "#525252"
        ctx.fillStyle = "#ffffff"
        for path in @floor_cache
          is_first = true
          for i in path
            if is_first
              ctx.moveTo(haika.cm2px_x(i.X), haika.cm2px_y(i.Y))
              is_first = false
            else
              ctx.lineTo(haika.cm2px_x(i.X), haika.cm2px_y(i.Y))
          ctx.lineTo(haika.cm2px_x(path[0].X), haika.cm2px_y(path[0].Y))
          ctx.closePath()
        ctx.stroke()
        ctx.fill()
        ctx.clip()
        haika_utils.drawBackground(@, ctx)
        haika_utils.drawGridLines(@, ctx)
        ctx.restore()

    canvas._renderOverlay = (ctx) =>
      haika_utils.drawScale(@, ctx)
      if @layer == @CONST_LAYERS.FLOOR
        if @floor_cache
          ctx.save()
          ctx.beginPath()
          ctx.lineWidth = 4
          ctx.strokeStyle = "#ff0000"
          for path in @floor_cache
            is_first = true
            for i in path
              if is_first
                ctx.moveTo(haika.cm2px_x(i.X), haika.cm2px_y(i.Y))
                is_first = false
              else
                ctx.lineTo(haika.cm2px_x(i.X), haika.cm2px_y(i.Y))
            ctx.lineTo(haika.cm2px_x(path[0].X), haika.cm2px_y(path[0].Y))
            ctx.closePath()
          ctx.stroke()
          ctx.restore()

    if not @readOnly
      initAligningGuidelines(canvas)
    @canvas = canvas
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
      object.top_cm = @transformTopY_px2cm(object.top)
      object.left_cm = @transformLeftX_px2cm(object.left)
      @saveDelay()
    # マウスホイール
    timeout = false
    $(@canvas.wrapperEl).on "mousewheel", (e) =>
      delta = e.originalEvent.wheelDelta / 120
      if timeout
        return
      else
        timeout = setTimeout ->
          timeout = false
        , 100
      if delta > 0
        @zoomIn()
      if delta < 0
        @zoomOut()

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

  setBackgroundUrl: (url) ->
    @canvas.backgroundImage = null
    @backgroundUrl = url
    @render()

# 新しいオブジェクトのIDを取得
# [この関数は@objectsからデータを取得する]
# [この関数はaddから呼ばれる以外は使用しない]
#
  _getLatestId: ->
    lastId = 0
    for object in @objects
      if object.id > lastId
        lastId = object.id
    return lastId + 1

# idからオブジェクトの配列番号を取得
  getCountFindById: (id)->
    count = null
    $(@objects).each (i, obj)->
      if obj.id == id
        count = i
    return count

# JSONでオブジェクトを変更する
# TODO: geojsonベースにする？
  changeObject: (id, json)->
    # オブエジェクトを検索
    count = @getCountFindById(id)
    object = @objects[count]
    changed = false
    for key, value of json
      if object[key] != value
        object[key] = value
        changed = true
    if changed
      @render()
      @saveDelay()

# GeoJSONオブジェクトの追加
  addObject: (object)->
#    log object
    object.id = @_getLatestId()
    object.top_cm = @centerY
    object.left_cm = @centerX
    if not object.angle?
      object.angle = 0
    @objects.push(object)
    $(@).trigger('haika:add')
    @render()
    @saveDelay()
    @activeGroup([object.id])
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
    for object in @canvas.getObjects()
      ids.push(object.id)
    @activeGroup(ids)

# すべての選択解除
  unselectAll: ()->
    @canvas.deactivateAll().renderAll()

# クラス名の取得
  getClass: (type)->
    if @INSTALLED_OBJECTS[type]?
      return @INSTALLED_OBJECTS[type].class
    else
      throw '認識できないオブジェクトが含まれています'

# canvasの描画
  render: ->
    if not @canvas.backgroundImage and @backgroundUrl
      fabric.Image.fromURL @backgroundUrl, (img)=>
        # 中心に表示
        img.set(
          originX: 'left'
          originY: 'top'
        )
        @canvas.backgroundImage = img
        @canvas.renderAll()

    activeIds = []
    @applyActiveObjects (object)=>
      activeIds.push(object.id)


    @canvas.renderOnAddRemove = false
    @canvas._objects.length = 0
    beacons = []
    shelfs = []
    walls = []
    floors = []
    # オブジェクトの種類ごとに仕分ける
    for o in @objects
      # 現在のレイヤーなら選択可能に
      if @layer == @INSTALLED_OBJECTS[o.type].layer
        o.selectable = true
      else
        o.selectable = false
      if o.type == 'beacon'
        beacons.push(o)
      if o.type == 'wall'
        walls.push(o)
      if o.type == 'floor'
        floors.push(o)
      if o.type == 'shelf' or o.type == 'curved_shelf'
        shelfs.push(o)

    if @layer == @CONST_LAYERS.FLOOR
      for o in walls
        @addObjectToCanvas(o)
      for o in shelfs
        @addObjectToCanvas(o)
      for o in beacons
        @addObjectToCanvas(o)
      for o in floors
        @addObjectToCanvas(o)
    else
      for o in floors
        @addObjectToCanvas(o)
      for o in walls
        @addObjectToCanvas(o)
      for o in shelfs
        @addObjectToCanvas(o)
      for o in beacons
        @addObjectToCanvas(o)

    if activeIds.length > 0
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
    object.selectable = o.selectable

    #if not object.selectable
    #  object.opacity = 0.5
    # オブジェクトのロック
    if @readOnly
      object.lockMovementX = true
      object.lockMovementY = true
      object.lockRotation = true
      object.lockScalingX = true
      object.lockScalingY = true
      object.lockUniScaling = true
      object.hasControls = false
      object.hoverCursor = 'pointer'
    #      object.hasRotatingPoint = false
    #      object.hasBorders = false
    #schema = object.constructor.prototype.getJsonSchema()
    #for key of schema.properties
    #  object[key] = o[key]
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