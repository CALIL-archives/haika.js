class Haikagrid extends ol.layer.Vector
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
    pixelRatio = event.frameState.pixelRatio

    width = context.canvas.width
    height = context.canvas.height

    resolutionAtCoords = @map.getView().getProjection().getPointResolution(event.frameState.viewState.resolution,
      @origin)
    r = event.frameState.viewState.rotation
    r2 = @rotation * Math.PI / 180


    size = (1 / resolutionAtCoords) * pixelRatio

    matrix = (x, y, cx, cy, r) ->
      x_ = x - cx
      y_ = y - cy
      ax = x_ * Math.cos(r) - y_ * Math.sin(r) + cx
      ay = x_ * Math.sin(r) + y_ * Math.cos(r) + cy
      return {x: ax, y: ay}

    cx = width / 2
    cy = height / 2
    origin_xy = @map.getPixelFromCoordinate(@origin)
    origin = matrix(origin_xy[0], origin_xy[1], cx, cy, -r)

    context.save()
    a = matrix(origin.x, origin.y, cx, cy, r)
    a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2)
    context.translate(a.x, a.y)
    context.rotate(r2)
    context.rotate(r)

#    context.drawImage(@img, -((@img.width / 50 / resolutionAtCoords) * pixelRatio / 2),
#      -( (@img.height / 50 / resolutionAtCoords) * pixelRatio / 2), (@img.width / 50 / resolutionAtCoords) * pixelRatio,
#      (@img.height / 50 / resolutionAtCoords) * pixelRatio)
    context.restore()

    context.save()
    if size >= 10
      context.beginPath()
      context.lineWidth = 0.4
      context.strokeStyle = '#B8BFD4'
      for i in [-50..50]
        if i == 0
          continue
        a = matrix(origin.x + i * size, origin.y - 50 * size, cx, cy, r)
        a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2)
        b = matrix(origin.x + i * size, origin.y + 50 * size, cx, cy, r)
        b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2)
        context.moveTo(a.x, a.y)
        context.lineTo(b.x, b.y)
        a = matrix(origin.x - 50 * size, origin.y + i * size, cx, cy, r)
        a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2)
        b = matrix(origin.x + 50 * size, origin.y + i * size, cx, cy, r)
        b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2)
        context.moveTo(a.x, a.y)
        context.lineTo(b.x, b.y)
      context.stroke()

      i = 0
      context.lineWidth = 1
      context.beginPath()
      a = matrix(origin.x + i * size, origin.y - 50 * size, cx, cy, r)
      a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2)
      b = matrix(origin.x + i * size, origin.y + 50 * size, cx, cy, r)
      b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2)
      context.moveTo(a.x, a.y)
      context.lineTo(b.x, b.y)
      a = matrix(origin.x - 50 * size, origin.y + i * size, cx, cy, r)
      a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2)
      b = matrix(origin.x + 50 * size, origin.y + i * size, cx, cy, r)
      b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2)
      context.moveTo(a.x, a.y)
      context.lineTo(b.x, b.y)
      context.stroke()

    else
      a = matrix(origin.x - 50 * size, origin.y - 50 * size, cx, cy, r)
      a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2)
      b = matrix(origin.x - 50 * size, origin.y + 50 * size, cx, cy, r)
      b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2)
      c = matrix(origin.x + 50 * size, origin.y + 50 * size, cx, cy, r)
      c = matrix(c.x, c.y, origin_xy[0], origin_xy[1], r2)
      d = matrix(origin.x + 50 * size, origin.y - 50 * size, cx, cy, r)
      d = matrix(d.x, d.y, origin_xy[0], origin_xy[1], r2)
      context.beginPath()
      context.moveTo(a.x, a.y)
      context.lineTo(b.x, b.y)
      context.lineTo(c.x, c.y)
      context.lineTo(d.x, d.y)
      context.closePath()
      context.fillStyle = 'rgba(0,0,0,0.03)'
      context.fill()

    # 基準点の描画

    context.beginPath()
    context.strokeStyle = '#ff0000'
    context.lineWidth = 2
    context.arc(origin_xy[0], origin_xy[1], 5, 0, 2 * Math.PI, true)
    context.fillStyle = '#ffffff'
    context.fill()
    context.stroke()

    # 北矢印の描画

    context.beginPath()
    a = matrix(origin.x, origin.y - 7, cx, cy, r) # 基準点
    b = matrix(origin.x, origin.y - 150, cx, cy, r) # 北頂点
    c = matrix(origin.x - 8, origin.y - 140, cx, cy, r) # 北左
    d = matrix(origin.x + 8, origin.y - 140, cx, cy, r) # 北右
    context.moveTo(a.x, a.y)
    context.lineTo(b.x, b.y)
    context.moveTo(b.x, b.y)
    context.lineTo(c.x, c.y)
    context.moveTo(b.x, b.y)
    context.lineTo(d.x, d.y)
    context.strokeStyle = '#ffffff'
    context.lineWidth = 4
    context.stroke()
    context.strokeStyle = '#888888'
    context.lineWidth = 2
    context.stroke()

    context.fillStyle = "#555555"
    context.textAlign = "center"
    context.textBaseline = "middle"
    context.font = "13px 'Courier New'"
    context.lineWidth = 3
    context.strokeStyle = '#ffffff'
    b = matrix(origin.x, origin.y - 160, cx, cy, r) # 北頂点
    context.strokeText("北", b.x, b.y)
    context.fillText("北", b.x, b.y)
    context.restore()

    #
    context.beginPath()
    a = matrix(origin.x, origin.y - 5, cx, cy, r) # 基準点
    a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2)
    b = matrix(origin.x, origin.y - 100, cx, cy, r) # 北頂点
    b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2)
    c = matrix(origin.x - 8, origin.y - 90, cx, cy, r) # 北左
    c = matrix(c.x, c.y, origin_xy[0], origin_xy[1], r2)
    d = matrix(origin.x + 8, origin.y - 90, cx, cy, r) # 北右
    d = matrix(d.x, d.y, origin_xy[0], origin_xy[1], r2)
    context.moveTo(a.x, a.y)
    context.lineTo(b.x, b.y)
    context.moveTo(b.x, b.y)
    context.lineTo(c.x, c.y)
    context.moveTo(b.x, b.y)
    context.lineTo(d.x, d.y)
    context.strokeStyle = '#ffffff'
    context.lineWidth = 4
    context.stroke()
    context.strokeStyle = '#ff0000'
    context.lineWidth = 2
    context.stroke()


    context.fillStyle = "#555555"
    context.textAlign = "left"
    context.textBaseline = "middle"
    context.font = "13px 'Courier New'"
    context.lineWidth = 3
    context.strokeStyle = '#ffffff'
    context.strokeText("基準点", origin_xy[0] + 10, origin_xy[1])
    context.fillText("基準点", origin_xy[0] + 10, origin_xy[1])

    context.fillStyle = "#555555"
    context.textAlign = "center"
    context.textBaseline = "middle"
    context.font = "13px 'Courier New'"
    context.lineWidth = 3
    context.strokeStyle = '#ffffff'
    b = matrix(origin.x, origin.y - 110, cx, cy, r) # 北頂点
    b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2)
    context.strokeText("建物方向", b.x, b.y)
    context.fillText("建物方向", b.x, b.y)
    context.restore()

    """
    debugText = "[Gridlines]"
    context.save()
    context.fillStyle = "rgba(255, 255, 255, 0.6)"
    context.fillRect(0, context.canvas.height - 20, context.canvas.width, 20)
    context.font = "10px"
    context.fillStyle = "black"
    context.fillText(debugText, 10, context.canvas.height - 7)
    context.restore()
    """

    if haika.canvas?
      haika.render()
    else
      haika.init({
        'canvasId' : context.canvas
      })
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
