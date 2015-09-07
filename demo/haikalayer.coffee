class Haikalayer extends ol.layer.Vector
  map: null
  origin: [0, 0]
  img: null
  rotation: 0
  constructor: (options) ->
    log options
    log super
    super(options)
    @on 'postcompose', @postcompose_, @
    @setSource(new ol.source.Vector())
#    @img = new Image()
#    @img.src = "demo.jpg"
  setRotation: (r) ->
    @rotation = r
    @changed()

  postcompose_: (event)->
#    if not @map?
#      return

    context = event.context
    pixelRatio = event.frameState.pixelRatio

    width = context.canvas.width
    height = context.canvas.height

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

#    context.drawImage(@img, -((@img.width / 50 / resolutionAtCoords) * pixelRatio / 2),
#      -( (@img.height / 50 / resolutionAtCoords) * pixelRatio / 2), (@img.width / 50 / resolutionAtCoords) * pixelRatio,
#      (@img.height / 50 / resolutionAtCoords) * pixelRatio)
#    context.restore()
#    context.save()
    if haika.canvas?
      haika.render()
    else
      haika.init({
        'canvasId' : context.canvas
      })
      $.ajax
          url: 'data/calil.json'
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


fabric.Object.prototype.globalCompositeOperation = 'darker';

# fabricObjectの追加
haika.addObject('shelf'       , 0, fabric.Shelf)
haika.addObject('curved_shelf', 0, fabric.curvedShelf)
haika.addObject('beacon'      , 1, fabric.Beacon)
haika.addObject('wall'        , 2, fabric.Wall)
haika.addObject('floor'       , 3, fabric.Floor)
