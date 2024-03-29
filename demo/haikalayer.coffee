class Haikalayer extends ol.layer.Vector
  map: null
  origin: [0, 0]
  img: null
  rotation: 0
  constructor: (options) ->
    super(options)
    @on 'postcompose', @postcompose_, @
    @setSource(new ol.source.Vector())
#    @img = new Image()
#    @img.src = "demo.jpg"
  setRotation: (r) ->
    @rotation = r
    @changed()

  postcompose_: (event)->
    if not @map?
      return

    context = event.context
#    pixelRatio = event.frameState.pixelRatio
#
#    width = context.canvas.width
#    height = context.canvas.height
#
#    resolutionAtCoords = @map.getView().getProjection().getPointResolution(event.frameState.viewState.resolution,
#      @origin)
#    r = event.frameState.viewState.rotation
#    r2 = @rotation * Math.PI / 180
#
#
#    size = (1 / resolutionAtCoords) * pixelRatio
#
#    matrix = (x, y, cx, cy, r) ->
#      x_ = x - cx
#      y_ = y - cy
#      ax = x_ * Math.cos(r) - y_ * Math.sin(r) + cx
#      ay = x_ * Math.sin(r) + y_ * Math.cos(r) + cy
#      return {x: ax, y: ay}
#
#    cx = width / 2
#    cy = height / 2
#    origin_xy = @map.getPixelFromCoordinate(@origin)
#    origin = matrix(origin_xy[0], origin_xy[1], cx, cy, -r)
#
#    context.save()
#    a = matrix(origin.x, origin.y, cx, cy, r)
#    a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2)
#    context.translate(a.x, a.y)
#    context.rotate(r2)
#    context.rotate(r)
#
#    context.drawImage(@img, -((@img.width / 50 / resolutionAtCoords) * pixelRatio / 2),
#      -( (@img.height / 50 / resolutionAtCoords) * pixelRatio / 2), (@img.width / 50 / resolutionAtCoords) * pixelRatio,
#      (@img.height / 50 / resolutionAtCoords) * pixelRatio)
#    context.restore()
#    context.save()
#    if haika.canvas?
#      haika.render()
##      osm.changed()
##      @changed()
##      @map.updateSize()
#    else
#      # haika.jsの初期化処理
#      haika.init({
#        'divId'    : 'map'
#        'canvasId' : context.canvas
##        'readOnly' : true
#      })
#      haika.load()
##      haika.canvas.clearContext = =>
##        fabric.Canvas.prototype.clearContext()
##        osm.changed()
##      haika.canvas.on 'after:render', (e)=>
##        @changed()
##      haika.canvas.on 'mouse:up', (e)=>
##        if not haika.canvas.getActiveObject() and not haika.canvas.getActiveGroup()
##          @changed()
##      haika.canvas.on 'selection:cleared', (e)=>
##        @changed()
    log = (obj) ->
      try
        console.log obj
    # postrender changed postcompose
    if window.canvas?
    else
      window.canvas = new fabric.Canvas(context.canvas)
      canvas._renderAll = canvas.renderAll
      canvas.renderAll = =>
        @changed()
      canvas.renderTop = =>
        @changed()
      canvas._renderAllFix = ->
        canvasToDrawOn = this.contextTop
        activeGroup = this.getActiveGroup()

        this.clearContext(this.contextTop)

        this.fire('before:render')

        if this.clipTo
          fabric.util.clipContext(this, canvasToDrawOn)

        this._renderBackground(canvasToDrawOn)
        this._renderObjects(canvasToDrawOn, activeGroup)
        this._renderActiveGroup(canvasToDrawOn, activeGroup)


        # we render the top context - last object
        if this.selection and this._groupSelector
          this._drawSelection()

        if this.clipTo
          canvasToDrawOn.restore()

        this._renderOverlay(canvasToDrawOn);

        if this.controlsAboveOverlay && this.interactive
          this.drawControls(canvasToDrawOn)

        this.fire('after:render');

        return this;

      red = new fabric.Rect({
        left: 400,
        top: 100,
        fill: 'red',
        width: 400,
        height: 400,
        angle: 45
      });
      blue = new fabric.Rect({
        left: 800,
        top: 100,
        fill: 'blue',
        width: 400,
        height: 400,
        angle: 45
      });

      canvas.renderOnAddRemove = true
      canvas.add(red)
      canvas.add(blue)
    canvas._renderAllFix()

## fabricObjectの追加
#haika.addObject('shelf'       , 0, fabric.Shelf)
#haika.addObject('curved_shelf', 0, fabric.curvedShelf)
#haika.addObject('beacon'      , 1, fabric.Beacon)
#haika.addObject('wall'        , 2, fabric.Wall)
#haika.addObject('floor'       , 3, fabric.Floor)
#
## ローカルストレージに保存
#haika.save = ->
#  # GeoJSONを保存
##  log(haika._geojson)
#  localStorage.setItem('haika3', JSON.stringify(haika._geojson))
#  log('save local storage')
#
## ローカルストレージからロード
#haika.load = ->
#  # ローカルストレージから読み込み
#  if localStorage.getItem('haika3')
#    log 'load local storage'
#    haika._geojson = JSON.parse(localStorage.getItem('haika3'))
#    haika.loadFromGeoJson()
#    $(haika).trigger('haika:load')
#    haika.render()
#  else
#    $.ajax
#        url: 'data/calil.json'
#        type: 'GET'
#        cache: false
#        dataType: 'json'
#        error: ()=>
#          option.error and option.error('データが読み込めませんでした')
#        success: (json)=>
#          if json.locked
#            @readOnly = true
#            return option.error and option.error('データはロックされています')
#          haika._dataId = json.id
#          haika._revision = json.revision
#          haika._collision = json.collision
#          haika._geojson = json.data
#          haika.loadFromGeoJson()
#          $(haika).trigger('haika:load')
#          haikalayer.changed()
