((global) ->
  "use strict"
  fabric = global.fabric or (global.fabric = {})
  extend = fabric.util.object.extend
  if fabric.Beacon
    console.warn "fabric.Beacon is already defined"
    return
  stateProperties = fabric.Object::stateProperties.concat()
  stateProperties.push "x", "y"
  fabric.Beacon = fabric.util.createClass(fabric.Object,
    stateProperties: stateProperties
    type: "beacon"
    x: 0
    y: 0
    __const_width: 10
    __const_height: 10
    __width: ->
      @__const_width * app.scale
    __height: ->
      @__const_height * app.scale

    initialize: (options) ->
      options = options or {}
      @callSuper "initialize", options
      @x = options.x or 0
      @y = options.y or 0
      @width = @__width()
      @height = @__height()
      return

    _render: (ctx) ->
      console.log @
      ctx.beginPath()
      if @width is 1 and @height is 1
        ctx.fillRect 0, 0, 1, 1
        return
      ctx.fillRect 0, 0, @width, @height
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
      @set "x", parsedAttributes.left or 0
      @set "top", parsedAttributes.top + @getHeight() / 2  if "top" of parsedAttributes
      @set "y", parsedAttributes.top or 0
      this

    toObject: (propertiesToInclude) ->
      object = extend(@callSuper("toObject", propertiesToInclude),
        rx: @get("rx") or 0
        ry: @get("ry") or 0
        x: @get("x")
        y: @get("y")
        count: @get("count")
        side: @get("side")
      )
      if not @includeDefaultValues
        @_removeDefaultValues object
      return object

    toGeoJSON: ->
      w = @__eachWidth() * @count / 100
      h = @__eachHeight() * @side / 100
      center = @getCenterPoint()
      log center
      x = -w / 2 + (center.x / 100)
      y = -h / 2 + (center.y / 100)
      data =
        "type": "Feature"
        "geometry":
          "type": "Polygon",
          "coordinates": [
            [
              [x, y],
              [x + w, y],
              [x + w, y - h],
              [x, y - h],
              [x, y]
            ]
          ]
        "properties":
          "id": @id
          "count": @count
          "side": @side
          "center": @getCenterPoint()
      return data

    toSVG: (reviver) ->
      markup = @_createBaseSVGMarkup()
      markup.push("<g>")
      count = @get("count")
      side = @get("side")
      w = @__const_width
      h = @__const_hegiht
      x = -w / 2 * @count
      y = -h / 2 * @side
      i = 0
      k = 0
      while i < count
#        while k < row
#        markup.push """<rect x="#{x}" y="#{y}" rx="#{@get("rx")}" ry="#{@get("ry")}" width="#{@w}" height="#{@h}" style="#{@getSvgStyles()}" transform="#{@getSvgTransform()}"/>"""
        markup.push """<rect x="#{(-1 * @width / 2) + @width / count * i}" y="#{(-1 * @height / 2)}" rx="#{@get("rx")}" ry="#{@get("ry")}" width="#{@width / count}" height="#{@height / 2}" style="#{@getSvgStyles()}" transform="#{@getSvgTransform()}"/>"""
        i++
      if side == 2
        i = 0
        while i < count
#          markup.push """<rect x="#{x}" y="#{y}" rx="#{@get("rx")}" ry="#{@get("ry")}" width="#{@w}" height="#{@h}" style="#{@getSvgStyles()}" transform="#{@getSvgTransform()}"/>"""
          markup.push """<rect x="#{(-1 * @width / 2) + @width / count * i}" y="#{(-1 * @height / 2) + @__const_hegiht}" rx="#{@get("rx")}" ry="#{@get("ry")}" width="#{@width / count}" height="#{@height / 2}" style="#{@getSvgStyles()}" transform="#{@getSvgTransform()}"/>"""
          i++
      markup.push "</g>"

      (if reviver then reviver(markup.join("")) else markup.join(""))

    complexity: ->
      1
  )
  fabric.Beacon.ATTRIBUTE_NAMES = fabric.SHARED_ATTRIBUTES.concat("x y".split(" "))

  return) (if typeof exports isnt "undefined" then exports else this)