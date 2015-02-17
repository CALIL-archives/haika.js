((global) ->
  "use strict"
  haika_utils = global.haika_utils or (global.haika_utils = {})

  # 格子線を描画
  #
  haika_utils.drawGridLines = (haika, ctx) ->
    ctx.save()
    ctx.opacity = 1
    width = ctx.canvas.width
    height = ctx.canvas.height

    # 1mごとの格子線
    ctx.strokeStyle = '#cccccc'
    size = haika.cm2px(100)
    gapX = (haika.cm2px_x(0) * 1000 % Math.floor(size * 1000)) / 1000
    gapY = (haika.cm2px_y(0) * 1000 % Math.floor(size * 1000)) / 1000
    ctx.beginPath()
    ctx.lineWidth = Math.max(Math.min(haika.scaleFactor, 1), 0.3)
    i = 0
    while i < Math.ceil(width / size) + 1
      ctx.moveTo(Math.floor(size * i) + gapX + 0.5, 0)
      ctx.lineTo(Math.floor(size * i) + gapX + 0.5, height)
      ++i
    i = 0
    while i < Math.ceil(height / size) + 1
      ctx.moveTo(0, Math.floor(size * i) + gapY + 0.5)
      ctx.lineTo(width, Math.floor(size * i) + gapY + 0.5)
      ++i
    ctx.stroke()

    # 5mごとの格子線
    size = haika.cm2px(500)
    gapX = (haika.cm2px_x(0) * 1000 % Math.floor(size * 1000)) / 1000
    gapY = (haika.cm2px_y(0) * 1000 % Math.floor(size * 1000)) / 1000
    ctx.beginPath()
    ctx.lineWidth = Math.max(Math.min(haika.scaleFactor * 2, 2), 0.5)
    i = 0
    while i < Math.ceil(width / size) + 1
      ctx.moveTo(Math.floor(size * i) + gapX + 0.5, 0)
      ctx.lineTo(Math.floor(size * i) + gapX + 0.5, height)
      ++i
    i = 0
    while i < Math.ceil(height / size) + 1
      ctx.moveTo(0, Math.floor(size * i) + gapY + 0.5)
      ctx.lineTo(width, Math.floor(size * i) + gapY + 0.5)
      ++i
    ctx.stroke()

    # 中心線
    ctx.lineWidth = Math.max(Math.min(haika.scaleFactor * 2, 2), 0.5)
    ctx.strokeStyle = '#aaaaaa'
    ctx.beginPath()
    sx = haika.cm2px_x(0)
    sy = haika.cm2px_y(0)
    ctx.moveTo(Math.floor(sx), 0)
    ctx.lineTo(Math.floor(sx), height)
    ctx.moveTo(0, Math.floor(sy))
    ctx.lineTo(width, Math.floor(sy))
    ctx.stroke()
    ctx.restore()
    return

  # 左下にスケールを描画
  #
  haika_utils.drawScale = (haika, ctx) ->
    ctx.save()
    ctx.opacity = 1
    height = ctx.canvas.height
    posy = 20
    ctx.font = "10px Open Sans"
    if haika.cm2px(100) <= 50
      scale = 500
      text = "5m"
    else
      scale = 100
      text = "1m"

    ctx.lineWidth = 4.0
    ctx.strokeStyle = "rgba(255,255,255,0.8)"
    ctx.strokeText(text, 25, height - 66 + posy)
    ctx.fillText(text, 25, height - 66 + posy)

    ctx.lineWidth = 4
    ctx.strokeStyle = "rgba(255,255,255,0.8)"
    ctx.beginPath()
    ctx.moveTo(20, height - 65 + posy - 2)
    ctx.lineTo(20, height - 60 + posy)
    ctx.lineTo(20 + haika.cm2px(scale), height - 60 + posy)
    ctx.lineTo(20 + haika.cm2px(scale), height - 65 + posy - 2)
    ctx.stroke()

    ctx.lineWidth = 2
    ctx.strokeStyle = '#666666'
    ctx.beginPath()
    ctx.moveTo(20, height - 65 + posy)
    ctx.lineTo(20, height - 60 + posy)
    ctx.lineTo(20 + haika.cm2px(scale), height - 60 + posy)
    ctx.lineTo(20 + haika.cm2px(scale), height - 65 + posy)
    ctx.stroke()
    ctx.restore()
    return


  # 背景画像の描画
  #
  haika_utils.drawBackground = (haika, ctx) ->
    if haika.canvas.backgroundImage
      ctx.mozImageSmoothingEnabled = false
      haika.canvas.backgroundImage.left = Math.floor(haika.cm2px_x(haika.canvas.backgroundImage._originalElement.width / 2 * haika.backgroundScaleFactor))
      haika.canvas.backgroundImage.top = Math.floor(haika.cm2px_y(haika.canvas.backgroundImage._originalElement.height / 2 * haika.backgroundScaleFactor))
      haika.canvas.backgroundImage.width = Math.floor(haika.cm2px(haika.canvas.backgroundImage._originalElement.width * haika.backgroundScaleFactor))
      haika.canvas.backgroundImage.height = Math.floor(haika.cm2px(haika.canvas.backgroundImage._originalElement.height * haika.backgroundScaleFactor))
      haika.canvas.backgroundImage.opacity = haika.backgroundOpacity
      haika.canvas.backgroundImage.render ctx
      ctx.mozImageSmoothingEnabled = true
    return


  return) (if typeof exports isnt "undefined" then exports else this)