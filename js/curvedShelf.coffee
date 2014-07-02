((global) ->
  "use strict"
  _setDefaultLeftTopValues = (attributes) ->
    attributes.left = attributes.left or 0
    attributes.top = attributes.top or 0
    attributes
  fabric = global.fabric or (global.fabric = {})
  extend = fabric.util.object.extend
  if fabric.curvedShelf
    console.warn "fabric.curvedShelf is already defined"
    return
  stateProperties = fabric.Object::stateProperties.concat()
  stateProperties.push "rx", "ry", "x", "y"
  fabric.curvedShelf = fabric.util.createClass(fabric.Object,
    stateProperties: stateProperties
    type: "curved_shelf"
    rx: 0
    ry: 0
    x: 0
    y: 0
    __width: ->
      @__eachWidth() * @count
    __height: ->
      @__eachHeight() * @side
    __eachWidth: ->
      90 * app.scale
    __eachHeight: ->
      25 * app.scale
    count: 1
    side: 1
    minScaleLimit: 1
    strokeDashArray: null
    initialize: (options) ->
      options = options or {}
      @callSuper "initialize", options
      @_initRxRy()
      @x = options.x or 0
      @y = options.y or 0
      @width = @__width()
      @height = @__height()
      return

    _initRxRy: ->
      if @rx and not @ry
        @ry = @rx
      else @rx = @ry  if @ry and not @rx
      return

    _render: (ctx) ->
      #log '_render'
      if @width is 1 and @height is 1
        ctx.fillRect 0, 0, 1, 1
        return
      ctx.scale 1 / @scaleX, 1 / @scaleY

      arcStart = (180 - 30 * @count) / 2 * Math.PI / 180
      arcEnd = arcStart + 30 * @count * Math.PI / 180
      arcX = 0
      arcY = 0

      #天面を描画
      ctx.beginPath()
      ctx.arc(arcX, arcY, @height * @scaleY / 2, arcStart, arcEnd, false);
      rad = @height * @scaleY / 2 - @__eachHeight() * @side
      if rad <= 10 then rad = 10
      if  30 * @count < 360
        ctx.arc(arcX, arcY, rad, arcEnd, arcStart, true);
      ctx.closePath()
      @_renderFill ctx
      @_renderStroke ctx

      ctx.beginPath()
      rad = @height * @scaleY / 2 - @__eachHeight() * 1
      if rad <= 10 then rad = 10
      ctx.arc(arcX, arcY, rad, arcStart, arcEnd, false);
      ctx.stroke()

      if @active
        ctx.font = "13.5px Arial";
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"
        ctx.fillStyle = 'rgba(0, 0, 0,1)';
        label = if @side == 1 then "曲面単式" else "曲面複式"
        label = "[" + @id + "] " + label + @count + "連"
        ctx.fillText(label, 0, (@height * @scaleY) / 2 + 15);
      ctx.scale @scaleX, @scaleY
      return

    __resizeShelf: () ->
      actualWidth = @scaleX * @currentWidth
      actualHeight = @scaleY * @currentHeight
      count = Math.floor(actualWidth / @__eachWidth())
      if count < 1 then count = 1
      if count > 20 then count = 20
      side = Math.round(actualHeight / @__eachHeight())
      if side < 1 then side = 1
      if side > 2 then side = 2
      @set(count: count, side: side, minScaleLimit: 0.01, flipX: false, flipY: false)
  #console.log "width:" + (@width * @scaleX) + " height:" + (@height * @scaleY)

    __modifiedShelf: () ->
      #log '__modifiedShelf'
      @angle = @angle % 360
      if @angle >= 350 || @angle <= 10 then @angle = 0
      if @angle >= 80 && @angle <= 100 then @angle = 90
      if @angle >= 170 && @angle <= 190 then @angle = 180
      if @angle >= 260 && @angle <= 280 then @angle = 270
      @height = @height * @scaleY
      @scaleX = @scaleY = 1
      @width = @__width()
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
      )
      @_removeDefaultValues object  unless @includeDefaultValues
      object

    toGeoJSON: ->
      w = @__eachWidth() * @count # / 100
      h = @__eachHeight() * @side # / 100
      center = @getCenterPoint()
#      log center
      x = -w / 2 + center.x # / 100)
      y = -h / 2 + center.y # / 100)
      x = app.transformLeftX_px2cm(x)
      y = app.transformTopY_px2cm(y)
      data =
        "type": "Feature"
        "geometry":
          "type": "Polygon",
          "coordinates": [
            [ [x, y], [x + w, y], [x + w, y - h], [x, y - h], [x, y]]
          ]
        "properties":
          "type"  : @type
          "id"    : @id
          "count"    : @count
          "side"    : @side
          "angle" : @angle
      return data

    toSVG: (reviver) ->
      markup = @_createBaseSVGMarkup()
      markup.push("<g>")
      i = 0
      k = 0
      count = @get("count")
      row = if @get("row") == 'one' then 1 else 2
      while i < count
#        while k < row
        markup.push """<rect x="#{(-1 * @width / 2) + @width / count * i}" y="#{(-1 * @height / 2)}" rx="#{@get("rx")}" ry="#{@get("ry")}" width="#{@width / count}" height="#{@height}" style="#{@getSvgStyles()}" transform="#{@getSvgTransform()}"/>"""
        #  k++
        i++
      markup.push "</g>"

      (if reviver then reviver(markup.join("")) else markup.join(""))

    getJsonSchema : () ->
      schema =
        title: "基本情報"
        type: "object"
        properties:
          count:
            title: "連数"
            type: "integer"
            default: 3
            minimum: 1
            maximum: 10

          side:
            type: "integer"
            default: 1
            minimum: 1
            maximum: 2
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
#          shelfs:
#            type: "array"
#            uniqueItems: true
#            items:
#              type: "string"
#              enum: [
#                "value1"
#                "value2"
#              ]
      return schema

    complexity: ->
      1
  )
  fabric.curvedShelf.ATTRIBUTE_NAMES = fabric.SHARED_ATTRIBUTES.concat("x y rx ry width height count side".split(" "))
  fabric.curvedShelf.fromElement = (element, options) ->
    return null  unless element
    parsedAttributes = fabric.parseAttributes(element, fabric.Shelf.ATTRIBUTE_NAMES)
    parsedAttributes = _setDefaultLeftTopValues(parsedAttributes)
    shelf = new fabric.Shelf(extend(((if options then fabric.util.object.clone(options) else {})), parsedAttributes))
    shelf._normalizeLeftTopProperties parsedAttributes
    shelf
  fabric.curvedShelf.fromObject = (object) ->
    new fabric.curvedShelf(object)

  return) (if typeof exports isnt "undefined" then exports else this)
