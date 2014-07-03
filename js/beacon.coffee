((global) ->
  "use strict"
  fabric = global.fabric or (global.fabric = {})
  extend = fabric.util.object.extend
  if fabric.Beacon
    console.warn "fabric.Beacon is already defined"
    return
  fabric.Beacon = fabric.util.createClass(fabric.Object,
    type: "beacon"
    eachWidth: 10
    eachHeight: 10
    __width: ->
      @eachWidth * app.scale
    __height: ->
      @eachHeight * app.scale

    initialize: (options) ->
      options = options or {}
      @callSuper "initialize", options
      @width = @__width()
      @height = @__height()
      return

    _render: (ctx) ->
#      console.log @
      ctx.beginPath()
      if @width is 1 and @height is 1
        ctx.fillRect 0, 0, 1, 1
        return
      ctx.fillRect @width/2*(-1), @height/2*(-1), @width, @height
      @_renderFill ctx
      @_renderStroke ctx
      return

    __resizeShelf: () ->
      @set(flipX: false, flipY: false)

    __modifiedShelf: () ->
      #log '__modifiedShelf'
      @angle = @angle % 360
      if @angle >= 350 || @angle <= 10 then @angle = 0
      if @angle >= 80 && @angle <= 100 then @angle = 90
      if @angle >= 170 && @angle <= 190 then @angle = 180
      if @angle >= 260 && @angle <= 280 then @angle = 270
      @width = @__width()
      @height = @__height()
      @setCoords()

    _normalizeLeftTopProperties: (parsedAttributes) ->
      @set "left", parsedAttributes.left + @getWidth() / 2  if "left" of parsedAttributes
      @set "top", parsedAttributes.top + @getHeight() / 2  if "top" of parsedAttributes
      this

    toObject: (propertiesToInclude) ->
      object = extend(@callSuper("toObject", propertiesToInclude))
      if not @includeDefaultValues
        @_removeDefaultValues object
      return object

    toGeoJSON: ->
      w = @eachWidth
      h = @eachHeight
      center = @getCenterPoint()
#      log center
      x = -w / 2 + center.x
      y = -h / 2 + center.y
      x = app.transformLeftX_px2cm(x)
      y = app.transformTopY_px2cm(y)
      data =
        "type": "Feature"
        "geometry":
          "type": "Polygon",
          "coordinates": [
            [ [-x, y], [-(x + w), y], [-(x + w), y + h], [-x, y + h], [-x, y]]
          ]
        "properties":
          "type"  : @type
          "left_cm" : @left_cm
          "top_cm"  : @top_cm
          "id"    : @id
          "angle" : @angle
      return data

    toSVG: (reviver) ->
      ""
    getJsonSchema : () ->
      schema =
        title: "基本情報"
        type: "object"
        properties:
          angle:
            type: "integer"
            default: 0
            minimum: 0
            maximum: 360
#          eachWidth:
#            type: "integer"
#            default: 90
#            minimum: 1
#          eachHeight:
#            type: "integer"
#            default: 25
#            minimum: 1
      return schema

    complexity: ->
      1
  )
  return) (if typeof exports isnt "undefined" then exports else this)