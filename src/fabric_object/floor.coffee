((global) ->
  "use strict"
  fabric = global.fabric or (global.fabric = {})
  degreesToRadians = fabric.util.degreesToRadians
  if fabric.Floor
    console.warn "fabric.Floor is already defined"
    return

  fabric.Floor = fabric.util.createClass(fabric.Rect,
    type: "floor"
    width_cm: 1000
    height_cm: 1000
    is_negative: false
    fill: '#ffffff'
    stroke: '#000000'
    strokeDashArray: [2, 2]

    __width: ->
      @width_cm * haika.scaleFactor
    __height: ->
      @height_cm * haika.scaleFactor

    initialize: (options = {}) ->
      @callSuper "initialize", options
      @width = @__width()
      @height = @__height()
      return

    _render: (ctx, noTransform) ->
      if not @selectable
        return
      rx = if @rx then Math.min(@rx, @width / 2) else 0
      ry = if @ry then Math.min(@ry, @height / 2) else 0
      w = @width
      h = @height
      x = if noTransform then @left else -@width / 2
      y = if noTransform then @top else -@height / 2
      ctx.save()
      if @is_negative
        ctx.fillStyle = '#353535'
      else
        ctx.fillStyle = 'rgba(255,0,0,0.3)'
      ctx.beginPath()
      ctx.moveTo x + rx, y
      ctx.lineTo x + w - rx, y
      ctx.lineTo x + w, y + h - ry
      ctx.lineTo x + rx, y + h
      ctx.lineTo x, y + ry
      ctx.closePath()
      @_renderFill ctx
      if @selectable
        @_renderStroke ctx
        ctx.scale 1 / @scaleX, 1 / @scaleY
        if @angle > 90 and @angle < 270
          ctx.rotate(degreesToRadians(180))
        if @is_negative
          ctx.fillStyle = '#999999'
          label = '吹き抜け'
        else
          ctx.fillStyle = '#000000'
          label = 'フロア指定'
        ctx.font = "12px Arial"
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"
        metrics = ctx.measureText(label)
        if metrics.width <= @__width()
          ctx.fillText(label, 0, 0)
        else if metrics.width <= @__height()
          ctx.rotate(degreesToRadians(90))
          ctx.fillText(label, 0, 0)
      ctx.restore()
      return

    __resizeShelf: () ->
      @set(flipX: false, flipY: false)

    __modifiedShelf: () ->
      #log '__modifiedShelf'
      @angle = Math.floor(@angle % 360)
      if @angle >= 350 || @angle <= 10 then @angle = 0
      if @angle >= 80 && @angle <= 100 then @angle = 90
      if @angle >= 170 && @angle <= 190 then @angle = 180
      if @angle >= 260 && @angle <= 280 then @angle = 270
      if @scaleX != 1
        @width = @width * @scaleX
        @width_cm = Math.floor(@width / haika.scaleFactor)
      if @scaleY != 1
        @height = @height * @scaleY
        @height_cm = Math.floor(@height / haika.scaleFactor)
      @scaleX = @scaleY = 1
      @setCoords()

    toGeoJSON: ->
      w = @width_cm
      h = @height_cm
      left_cm = @left_cm
      top_cm = @top_cm
      x = -w / 2 + left_cm
      y = -h / 2 + top_cm
      new_coordinates = []
      for coordinate in [[x, y], [x + w, y], [x + w, y + h], [x, y + h], [x, y]]
        new_coordinate = fabric.util.rotatePoint(new fabric.Point(coordinate[0], coordinate[1]),
          new fabric.Point(left_cm, top_cm), fabric.util.degreesToRadians(@angle))
        new_coordinates.push([new_coordinate.x, -new_coordinate.y])
      data =
        "type": "Feature"
        "geometry":
          "type": "Polygon",
          "coordinates": [new_coordinates]
        "properties":
          "id": @id
          "type": @type
          "left_cm": left_cm
          "top_cm": top_cm
          "width_cm": @width_cm
          "height_cm": @height_cm
          "angle": @angle
          "is_negative": @is_negative
      return data

    getJSONSchema: () ->
      schema =
        title: "基本情報"
        type: "object"
        properties:
          angle:
            type: "integer"
            default: 0
            minimum: 0
            maximum: 360
          width_cm:
            type: "number"
            default: 1
          height_cm:
            type: "number"
            default: 1
          is_negative:
            type: "boolean"
            default: false
      return schema

    complexity: ->
      1
  )
  return) (if typeof exports isnt "undefined" then exports else this)