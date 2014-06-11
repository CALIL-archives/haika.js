((global) ->
  "use strict"
  _setDefaultLeftTopValues = (attributes) ->
    attributes.left = attributes.left or 0
    attributes.top = attributes.top or 0
    attributes
  fabric = global.fabric or (global.fabric = {})
  extend = fabric.util.object.extend
  if fabric.drawGridLines
    console.warn "fabric.drawGridLines is already defined"
    return

  fabric.drawGridLines = (canvas) ->
    canvas.renderOnAddRemove = false
    width = canvas.width
    height = canvas.height
    line = null
    rect = []
    size = 100 * app.scale # 50px = 1m = 100cm / 2 = 50px

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
    points = [
      {'x': 0, 'y': 0},
      {'x': 0, 'y': size * 0.1},
      {'x': size, 'y': size * 0.1},
      {'x': size, 'y': 0},
    ]

    line = new fabric.Polyline(points,
      stroke: "#000"
      opacity: 0.3
      top: size * 0.2,
      left: size,
      fill: "#fff",
      strokeWidth: 2,
      selectable: false
      hasControls: false
      hasBorders: false
    )
    canvas.add line
    text = new fabric.Text('1m',
      opacity: 0.3
      left: size * 1.3
      top: size * 0.35
      fontSize: 12
      selectable: false
      hasControls: false
      hasBorders: false
      fontWeight: 'bold'
      fontFamily: 'Open Sans'
      useNative: true
      fill: "#000"
    )
    canvas.add text
    #図面のサイズ
    text = new fabric.Text("SIZE = " + (width * 2 / 100) + "m x " + (height * 2 / 100) + "m",
      opacity: 0.3
      left: size + size * 1.3
      top: size * 0.2
      fontSize: 12
      selectable: false
      hasControls: false
      hasBorders: false
      fontWeight: 'bold'
      fontFamily: 'Open Sans'
      useNative: true
      fill: "#000"
    )
    canvas.add text

  fabric.drawGridLines.fromElement = (element, options) ->
    return null  unless element
    parsedAttributes = fabric.parseAttributes(element, fabric.drawGridLines.ATTRIBUTE_NAMES)
    parsedAttributes = _setDefaultLeftTopValues(parsedAttributes)
    gridLines = new fabric.drawGridLines(extend(((if options then fabric.util.object.clone(options) else {})), parsedAttributes))
    gridLines._normalizeLeftTopProperties parsedAttributes
    gridLines
  fabric.drawGridLines.fromObject = (object) ->
    new fabric.drawGridLines(object)

  return) (if typeof exports isnt "undefined" then exports else this)

#    fabric.drawGridLines.async = true;