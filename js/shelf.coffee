((global) ->
  "use strict"
  _setDefaultLeftTopValues = (attributes) ->
    attributes.left = attributes.left or 0
    attributes.top = attributes.top or 0
    attributes
  fabric = global.fabric or (global.fabric = {})
  extend = fabric.util.object.extend
  if fabric.Shelf
    console.warn "fabric.Shelf is already defined"
    return
  stateProperties = fabric.Object::stateProperties.concat()
  stateProperties.push "id", "count", "side"

  fabric.Shelf = fabric.util.createClass(fabric.Object,
    stateProperties: stateProperties
    type: "shelf"
    __const_width: 90
    __const_hegiht: 25
    __width: ->
      @__eachWidth() * @count
    __height: ->
      @__eachHeight() * @side
    __eachWidth: ->
      @__const_width * app.scale
    __eachHeight: ->
      @__const_hegiht * app.scale
    count: 1
    side: 1
    minScaleLimit: 1
    strokeDashArray: null
    initialize: (options) ->
      options = options or {}
      @callSuper "initialize", options
      @width = @__width()
      @height = @__height()
      return

    _render: (ctx) ->
      #log '_render'
      if @width is 1 and @height is 1
        ctx.fillRect 0, 0, 1, 1
        return
      ctx.scale 1 / @scaleX, 1 / @scaleY
      #スケール変更中は位置をドラックした反対側に寄せる
      sx=0
      if @scaleX != 0 && (@__corner=='mr' || @__corner=='tr' || @__corner=='br')
          sx=(@count*@__eachWidth()-@width*@scaleX)/2
      if @scaleX != 0 && (@__corner=='ml' || @__corner=='tl' || @__corner=='bl')
          sx=-1*(@count*@__eachWidth()-@width*@scaleX)/2
      w = @__eachWidth()
      h = @__eachHeight()
      x = -w / 2 * @count + sx
      y = -h / 2 * @side
      isInPathGroup = @group and @group.type is "path-group"
      ctx.globalAlpha = (if isInPathGroup then (ctx.globalAlpha * @opacity) else @opacity)
      if @transformMatrix and isInPathGroup
        ctx.translate @width / 2 + @x, @height / 2 + @y
      if not @transformMatrix and isInPathGroup
        ctx.translate -@group.width / 2 + @width / 2 + @x, -@group.height / 2 + @height / 2 + @y

      if @side is 1
        @__renderShelf ctx, x, y, w, h
        if app.scale > 0.5
          @__renderSide ctx, x, y, w, h
      if @side is 2
        @__renderShelf ctx, x, y, w, h

      if @active
        ctx.font = "13.5px Arial";
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"
        ctx.fillStyle = 'rgba(0, 0, 0,1)';

        label = if @side==1 then "単式" else "複式"
        label = "[" + @id + "] " + label + @count + "連"
        ctx.fillText(label,0,(@height*@scaleY)/2+15);

      #if app.scale > 0.5
      #  ctx.font = "30px FontAwesome";
      #  ctx.textAlign = "right"
      #  ctx.textBaseline = "middle"
      #  ctx.fillStyle = 'rgba(0, 0, 0, 0.4)';
      #  ctx.fillText("\uf177", @width - @width / 2 - 10, -@height / 2 + @height / 2 / @side);

      ctx.scale @scaleX, @scaleY
      return

    __renderShelf: (ctx, x, y, w, h) ->
      total_width = w * @count
      @__renderRect(ctx, x, y, total_width, h)
      @__renderPartitionLine(ctx, x, y, w, h)
      if @side==2
        @__renderRect(ctx, x, y+h, total_width, h)
        @__renderPartitionLine(ctx, x, y+h, w, h)

    __renderRect: (ctx, x, y, w, h) ->
      ctx.lineWidth = 1
      ctx.beginPath()
      ctx.moveTo x, y
      ctx.lineTo x + w, y
      ctx.lineTo x + w, y + h
      ctx.lineTo x, y + h
      ctx.lineTo x, y
      ctx.closePath()
      @_renderFill ctx
      @_renderStroke ctx

    __renderPartitionLine: (ctx, x, y, w, h) ->
      if @count<=1
        return
      ctx.lineWidth = 1
      ctx.beginPath()
      i = 1
      while i < @count
        ctx.moveTo x + w * i, y
        ctx.lineTo x + w * i, y + h
        i++
      ctx.closePath()
      #@_renderFill ctx
      @_renderStroke ctx

    __renderSide: (ctx, x, y, w, h) ->
      ctx.lineWidth = 5
      ctx.beginPath()
      ctx.moveTo x, y + h - 1
      ctx.lineTo x + w * @count, y + h - 1
      ctx.closePath()
      #@_renderFill ctx
      @_renderStroke ctx

    __resizeShelf: () ->
      actualWidth = @scaleX * @currentWidth
      actualHeight = @scaleY * @currentHeight
      count = Math.floor(actualWidth / @__eachWidth())
      if count < 1 then count = 1
      if count > 10 then count = 10
      side = Math.round(actualHeight / @__eachHeight())
      if side < 1 then side = 1
      if side > 2 then side = 2
      @set(count: count, side: side, minScaleLimit: 0.01, flipX: false, flipY: false)
      #console.log "width:" + (@width * @scaleX) + " height:" + (@height * @scaleY)

    __modifiedShelf: () ->
      #log '__modifiedShelf'
      @angle = @angle % 360
      if @angle >=350 || @angle <= 10 then @angle=0
      if @angle >=80  && @angle <= 100 then @angle=90
      if @angle >=170 && @angle <=190 then @angle=180
      if @angle >=260 && @angle <=280 then @angle=270

      if @scaleX != 0 && (@__corner=='mr' || @__corner=='tr' || @__corner=='br')
         th = @angle * (Math.PI / 180)
         @top = @top + Math.sin(th)*(@count*@__eachWidth()-@width*@scaleX)/2
         @left = @left + Math.cos(th)*(@count*@__eachWidth()-@width*@scaleX)/2
      if @scaleX != 0 && (@__corner=='ml' || @__corner=='tl' || @__corner=='bl')
         th = @angle * (Math.PI / 180)
         @top = @top - Math.sin(th)*(@count*@__eachWidth()-@width*@scaleX)/2
         @left = @left - Math.cos(th)*(@count*@__eachWidth()-@width*@scaleX)/2
      @scaleX = @scaleY = 1
      @width = @__width()
      @height = @__height()
      @setCoords()

    _renderDashedStroke: (ctx) ->
      x = -@width / 2
      y = -@height / 2
      w = @width
      h = @height
      ctx.beginPath()
      fabric.util.drawDashedLine ctx, x, y, x + w, y, @strokeDashArray
      fabric.util.drawDashedLine ctx, x + w, y, x + w, y + h, @strokeDashArray
      fabric.util.drawDashedLine ctx, x + w, y + h, x, y + h, @strokeDashArray
      fabric.util.drawDashedLine ctx, x, y + h, x, y, @strokeDashArray
      ctx.closePath()
      return

    _normalizeLeftTopProperties: (parsedAttributes) ->
      @set "left", parsedAttributes.left + @getWidth() / 2  if "left" of parsedAttributes
      @set "x", parsedAttributes.left or 0
      @set "top", parsedAttributes.top + @getHeight() / 2  if "top" of parsedAttributes
      @set "y", parsedAttributes.top or 0
      this

    toObject: (propertiesToInclude) ->
      object = extend(@callSuper("toObject", propertiesToInclude),
        count: @get("count")        
        side: @get("side")
      )
      if not @includeDefaultValues
        @_removeDefaultValues object  
      return object

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
      count = @get("count")
      side  = @get("side")
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
      if side==2
        i = 0
        while i < count
#          markup.push """<rect x="#{x}" y="#{y}" rx="#{@get("rx")}" ry="#{@get("ry")}" width="#{@w}" height="#{@h}" style="#{@getSvgStyles()}" transform="#{@getSvgTransform()}"/>"""
          markup.push """<rect x="#{(-1 * @width / 2) + @width / count * i}" y="#{(-1 * @height / 2) + @__const_hegiht}" rx="#{@get("rx")}" ry="#{@get("ry")}" width="#{@width / count}" height="#{@height / 2}" style="#{@getSvgStyles()}" transform="#{@getSvgTransform()}"/>"""
          i++
      markup.push "</g>"

      (if reviver then reviver(markup.join("")) else markup.join(""))

    getJsonSchema : () ->
      schema =
        title: "基本情報"
        type: "object"
        properties:
          count:
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
  fabric.Shelf.ATTRIBUTE_NAMES = fabric.SHARED_ATTRIBUTES.concat("width height count side".split(" "))
  fabric.Shelf.fromElement = (element, options) ->
    return null  unless element
    parsedAttributes = fabric.parseAttributes(element, fabric.Shelf.ATTRIBUTE_NAMES)
    parsedAttributes = _setDefaultLeftTopValues(parsedAttributes)
    shelf = new fabric.Shelf(extend(((if options then fabric.util.object.clone(options) else {})), parsedAttributes))
    shelf._normalizeLeftTopProperties parsedAttributes
    shelf
  fabric.Shelf.fromObject = (object) ->
    new fabric.Shelf(object)

  return) (if typeof exports isnt "undefined" then exports else this)

#    fabric.Shelf.async = true;