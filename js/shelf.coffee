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
    __width: 90
    __height: 25
    maxWidth : 900
    maxHeight : 50
    count: 1
    side : 1
    minScaleLimit: 1
    strokeDashArray: null
    initialize: (options) ->
      options = options or {}
      @callSuper "initialize", options
      @_initRxRy()
      @x = options.x or 0
      @y = options.y or 0
      @width = @__width * @count
      @height = @__height * @side
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
      rx = (if @rx then Math.min(@rx, @width / 2) else 0)
      ry = (if @ry then Math.min(@ry, @height / 2) else 0)
      #@count = Math.round(@currentWidth / 90)
      #@currentWidth = @count * @width
      #log @scaleX
      w = @width / @count
      h = @height / @side
      x = -w / 2 * @count
      y = -h / 2 * @side
      isInPathGroup = @group and @group.type is "path-group"
      isRounded = rx isnt 0 or ry isnt 0
      k = 1 - 0.5522847498
      ctx.globalAlpha = (if isInPathGroup then (ctx.globalAlpha * @opacity) else @opacity)
      if @transformMatrix and isInPathGroup
        ctx.translate @width / 2 + @x, @height / 2 + @y
      if not @transformMatrix and isInPathGroup
        ctx.translate -@group.width / 2 + @width / 2 + @x, -@group.height / 2 + @height / 2 + @y
      
      
      i = 0
      while i < @count
        if @side is 1
          @__renderShelf ctx, x + i * w, y, w, h
          @__renderSide  ctx, x + i * w, y, w, h
        else if @side is 2
          @__renderShelf ctx, x + i * w, y, w, h
          @__renderShelf ctx, x + i * w, y + h, w, h
        i++

#      ctx.lineWidth = 1
#      ctx.globalAlpha = 1 #塗りつぶしの透明度設定
#      ctx.fillStyle = '#000000'
#      ctx.beginPath()
#      #arc(x座標,y,直径,円弧の描き始めの位置,書き終わりの位置,円弧を描く方向(true:反時計回り))
#      ctx.arc(@width-@width/2-10,-@height/2+@height/2/@side,1,0,2*Math.PI,true)
#      @_renderFill ctx
#      @_renderStroke ctx

      ctx.font = "30px FontAwesome";
      ctx.textAlign = "right"
      ctx.textBaseline  = "middle"
      ctx.fillStyle = 'rgba(0, 0, 0, 0.4)';
      ctx.fillText( "\uf177", @width-@width/2-10, -@height/2+@height/2/@side);
      return

    __renderShelf: (ctx, x, y, w, h) ->
      ctx.beginPath()
      ctx.moveTo x, y
      ctx.lineWidth = 1
      ctx.lineTo x + w, y
      ctx.lineTo x + w, y + h
      ctx.lineTo x, y + h
      ctx.lineTo x, y
      ctx.closePath()
      @_renderFill ctx
      @_renderStroke ctx

    __renderSide: (ctx, x, y, w, h) ->
      ctx.beginPath()
      ctx.lineWidth = 5
      ctx.moveTo x, y + h - 1
      ctx.lineTo x + w, y + h - 1
      ctx.closePath()
      @_renderFill ctx
      @_renderStroke ctx

    __resizeShelf: () ->
      maxWidth = @maxWidth
      maxHeight = @maxHeight
      actualWidth = @scaleX * @width
      actualHeight = @scaleY * @height

      # dividing maxWidth by the @width gives us our 'max scale' 
      if not isNaN(maxWidth) and actualWidth >= maxWidth
        @set scaleX: maxWidth / @width
      if not isNaN(maxHeight) and actualHeight >= maxHeight 
        @set scaleY: maxHeight / @height
      #log @get("currentWidth") * @scaleX
      count = Math.round(@currentWidth * @scaleX / @__width)
      count = if count<1 then 1 else count
      side = Math.round(@currentHeight * @scaleY / @__height)
      side = if side<1 then 1 else side
#      if @flipY
#        @angle = @originalState.angle + 180
      @set(count: count, side: side, minScaleLimit: 1 / @count, flipX : false, flipY:false)
      #console.log "width:" + (@width * @scaleX) + " height:" + (@height * @scaleY)

    __modifiedShelf: () ->
      log '__modifiedShelf'
      log @scaleX
      #log @currentHeight
      @width = @currentWidth
      @scaleX = 1
      @height = @currentHeight
      @scaleY = 1

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