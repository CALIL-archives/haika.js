((global) ->
  "use strict"
  fabric = global.fabric or (global.fabric = {})
  if fabric.drawGridLines
    console.warn "fabric.drawGridLines is already defined"
    return
  fabric.drawGridLines = (ctx) ->
    width = ctx.canvas.width
    height = ctx.canvas.height

    size = 100 * app.scale
    if size < 50 then size=500 * app.scale
    if size < 50 then size=1000 * app.scale
    ctx.save()
    ctx.beginPath()
    ctx.setLineDash([2,2])
    ctx.lineWidth = 1
    ctx.strokeStyle = '#999999'
    ctx.opacity = 1
    sx = (app.transformX_cm2px(0)*1000 % Math.floor(size*1000))/1000
    sy = (app.transformY_cm2px(0)*1000 % Math.floor(size*1000))/1000
    i = 0
    while i < Math.ceil(width / size)+1
        ctx.moveTo(Math.floor(i * size+sx)+0.5, 0)
        ctx.lineTo(Math.floor(i * size+sx)+0.5, height)
        ++i
    i = 0
    while i < Math.ceil(height / size)+1
        ctx.moveTo(0, Math.floor(i * size+sy)+0.5)
        ctx.lineTo(width, Math.floor(i * size+sy)+0.5)
        ++i
    ctx.closePath()
    ctx.stroke()
    ctx.restore()
    return
    #縮尺を表示する
    #canvas.renderOnAddRemove = false
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

  return) (if typeof exports isnt "undefined" then exports else this)