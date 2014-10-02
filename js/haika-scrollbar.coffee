# スクロールバーの設定
# haikaの初期設定完了時に実行する  
initScrollBar = () ->
  scroll_weight = 5000
  bgimg_width = if haika.backgroundImage then haika.backgroundImage.width else 2500
  bgimg_height = if haika.backgroundImage then haika.backgroundImage.height else 2500
  maxX = bgimg_width * haika.backgroundScaleFactor / 2
  maxY = bgimg_height * haika.backgroundScaleFactor / 2
  defaultX =  -((haika.centerX - scroll_weight) / 10000)
  defaultY =  -((haika.centerY - scroll_weight) / 10000)
  new Dragdealer 'horizontal-scroller',
    x: defaultX
    animationCallback: (x, y)->
#      log x
      centerX = x * 10000 - scroll_weight * haika.scaleFactor
      if centerX > maxX - haika.canvas.getWidth() / 2
        centerX = maxX - haika.canvas.getWidth() / 2
      if centerX < -maxX + haika.canvas.getWidth() / 2
        centerX = -maxX + haika.canvas.getWidth() / 2
      haika.centerX = -centerX.toFixed(0)
      haika.render()
  new Dragdealer 'vertical-scroller',
    y: defaultY
    horizontal: false,
    vertical: true,
#    yPrecision: 500,
    animationCallback: (x, y)->
      centerY = y * 10000 - scroll_weight * haika.scaleFactor
      if centerY > maxY - haika.canvas.getHeight() / 2
        centerY = maxY - haika.canvas.getHeight() / 2
      if centerY < -maxY + haika.canvas.getHeight() / 2
        centerY = -maxY + haika.canvas.getHeight() / 2
      haika.centerY = -centerY.toFixed(0)
      haika.render()

