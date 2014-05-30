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
  stateProperties.push "rx", "ry", "x", "y"

  fabric.drawGridLines = (canvas) ->
    canvas.renderOnAddRemove = false
    width = canvas.width
    height = canvas.height
    line = null
    rect = []
    size = 50 # 50px = 1m = 100cm / 2 = 50px

    #格子線を描画する
    i = 1
    while i < Math.ceil(width / size)
      rect[0] = i * size
      rect[1] = 0
      rect[2] = i * size
      rect[3] = height
      line = new fabric.Line(rect,
        stroke: "#999"
        opacity: 0.5
        strokeWidth: 0.5
        strokeDashArray: [2, 2]
        selectable: false
        hasControls: false
        hasBorders: false
      )
      canvas.add line
      ++i
    i = 1
    while i < Math.ceil(height / size)
      rect[0] = 0
      rect[1] = i * size
      rect[2] = width
      rect[3] = i * size
      line = new fabric.Line(rect,
        stroke: "#999"
        opacity: 0.5
        strokeWidth: 0.5
        strokeDashArray: [2, 2]
        selectable: false
        hasControls: false
        hasBorders: false
      )
      canvas.add line
      ++i
    #縮尺を表示する
    canvas.renderOnAddRemove = true
    points = [{'x':0,'y':0},
      {'x':0,'y':size*0.1},
      {'x':size,'y':size*0.1},
      {'x':size,'y':0},
    ]

    line = new fabric.Polyline(points,
      stroke: "#000"
      opacity: 0.3
      top:size*0.2,
      left:size,
      fill:"#fff",
      strokeWidth:2,
      selectable: false
      hasControls: false
      hasBorders: false
    )
    canvas.add line
    text = new fabric.Text('1m',
      opacity: 0.3
      left: size*1.3
      top: size*0.35
      fontSize: 12
      selectable: false
      hasControls: false
      hasBorders: false
      fontWeight: 'bold'
      fontFamily:  'Open Sans'
      useNative: true
      fill: "#000"
    )
    canvas.add text
    #図面のサイズ
    text = new fabric.Text("SIZE = "+(width*2/100)+"m x "+(height*2/100)+"m",
      opacity: 0.3
      left: size+size*1.3
      top: size*0.2
      fontSize: 12
      selectable: false
      hasControls: false
      hasBorders: false
      fontWeight: 'bold'
      fontFamily:  'Open Sans'
      useNative: true
      fill: "#000"
    )
    canvas.add text


  fabric.Shelf = fabric.util.createClass(fabric.Object,
    stateProperties: stateProperties
    type: "shelf"
    rx: 0
    ry: 0
    x: 0
    y: 0
    width: 90
    height: 25
    count: 1
    strokeDashArray: null
    initialize: (options) ->
      options = options or {}
      @callSuper "initialize", options
      @_initRxRy()
      @x = options.x or 0
      @y = options.y or 0
      @width = @width * @count
      @_side = (if (@side is "one") then 1 else 2)
      @height = @height * @_side
      return

    _initRxRy: ->
      if @rx and not @ry
        @ry = @rx
      else @rx = @ry  if @ry and not @rx
      return

    _render: (ctx) ->
      if @width is 1 and @height is 1
        ctx.fillRect 0, 0, 1, 1
        return
      rx = (if @rx then Math.min(@rx, @width / 2) else 0)
      ry = (if @ry then Math.min(@ry, @height / 2) else 0)
      w = @width / @count
      h = @height / @_side
      x = -w / 2 * @count
      y = -h / 2 * @_side
      isInPathGroup = @group and @group.type is "path-group"
      isRounded = rx isnt 0 or ry isnt 0
      k = 1 - 0.5522847498
      ctx.beginPath()
      ctx.globalAlpha = (if isInPathGroup then (ctx.globalAlpha * @opacity) else @opacity)
      ctx.translate @width / 2 + @x, @height / 2 + @y  if @transformMatrix and isInPathGroup
      ctx.translate -@group.width / 2 + @width / 2 + @x, -@group.height / 2 + @height / 2 + @y  if not @transformMatrix and isInPathGroup
      i = 0

      while i < @count
        if @side is "one"
          @__renderShelf ctx, x + i * w, y, w, h
        else if @side is "both"
          @__renderShelf ctx, x + i * w, y, w, h
          @__renderShelf ctx, x + i * w, y + h, w, h
        i++
      @_renderFill ctx
      @_renderStroke ctx
      return

    __renderShelf: (ctx, x, y, w, h) ->
      ctx.moveTo x, y
      ctx.lineTo x + w, y
      ctx.lineTo x + w, y + h
      ctx.lineTo x, y + h
      ctx.lineTo x, y
      ctx.closePath()
      return

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
        rx: @get("rx") or 0
        ry: @get("ry") or 0
        x: @get("x")
        y: @get("y")
      )
      @_removeDefaultValues object  unless @includeDefaultValues
      object

    toSVG: (reviver) ->
      markup = @_createBaseSVGMarkup()
      markup.push("<g>")
      i = 0
      k = 0
      count = @get("count")
      row   = if @get("row")=='one' then 1 else 2
      while i < count
#        while k < row
        markup.push """<rect x="#{(-1 * @width / 2) + @width / count * i}" y="#{(-1 * @height / 2)}" rx="#{@get("rx")}" ry="#{@get("ry")}" width="#{@width / count}" height="#{@height}" style="#{@getSvgStyles()}" transform="#{@getSvgTransform()}"/>"""
        #  k++
        i++
      markup.push "</g>"
      
      (if reviver then reviver(markup.join("")) else markup.join(""))

    complexity: ->
      1
  )
  fabric.Shelf.ATTRIBUTE_NAMES = fabric.SHARED_ATTRIBUTES.concat("x y rx ry width height".split(" "))
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