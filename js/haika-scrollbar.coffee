# スクロールバーの設定
setScrollbar = ->
  scroll_weight = 5000
  bgimg_width = if haika.bgimg then haika.bgimg_width else 2500
  bgimg_height = if haika.bgimg then haika.bgimg_height else 2500
  maxX = bgimg_width * haika.options.bgscale / 2
  maxY = bgimg_height * haika.options.bgscale / 2
  defaultX =  -((haika.centerX - scroll_weight) / 10000)
  defaultY =  -((haika.centerY - scroll_weight) / 10000)
  new Dragdealer 'horizontal-scroller',
    x: defaultX
    animationCallback: (x, y)->
#      log x
      haika.unselect()
      centerX = x * 10000 - scroll_weight
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
      haika.unselect()
      centerY = y * 10000 - scroll_weight
      if centerY > maxY - haika.canvas.getHeight() / 2
        centerY = maxY - haika.canvas.getHeight() / 2
      if centerY < -maxY + haika.canvas.getHeight() / 2
        centerY = -maxY + haika.canvas.getHeight() / 2
      haika.centerY = -centerY.toFixed(0)
      haika.render()

$(haika).on 'haika:initialized', ->
  setScrollbar()
