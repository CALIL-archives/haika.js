# スクロールバーの設定
# haikaの初期設定完了時に実行する
initScrollBar = () ->
  new Dragdealer 'horizontal-scroller',
    x: 0.5
    animationCallback: (x, y)->
      _max= if haika.canvas.backgroundImage then haika.canvas.backgroundImage.width else 2500
      haika.centerX = ((x-0.5)*_max).toFixed(0)*-1
      haika.render()
  new Dragdealer 'vertical-scroller',
    y: 0.5
    horizontal: false,
    vertical: true,
    animationCallback: (x, y)->
      _max= if haika.canvas.backgroundImage then haika.canvas.backgroundImage.height else 2500
      haika.centerY = ((y-0.5)*_max).toFixed(0)*-1
      haika.render()

