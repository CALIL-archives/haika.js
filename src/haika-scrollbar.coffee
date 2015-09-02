class ScrollBar
  # 初期設定
  constructor: ->
    new Dragdealer 'horizontal-scroller',
      x: 0.5
      animationCallback: (x, y)->
        maxWidth = 25000 #25mの範囲
        viewWidth = haika.canvas.getWidth() * haika.scaleFactor
        haika.centerX = ((x - 0.5) * ((maxWidth - viewWidth) / 2)).toFixed(0) * -1
        haika.render()
    new Dragdealer 'vertical-scroller',
      y: 0.5
      horizontal: false,
      vertical: true,
      animationCallback: (x, y)->
        maxHeight = 25000 #25mの範囲
        viewHeight = haika.canvas.getHeight() * haika.scaleFactor
        haika.centerY = ((y - 0.5) * ((maxHeight - viewHeight) / 2)).toFixed(0) * -1
        haika.render()
# pluginに登録
haika.plugins.push(ScrollBar)

haika.htmlStack.push """
<div  id="vertical-scroller" class="content-scroller">
  <div class="dragdealer">
    <div class="handle scroller-gray-bar">
    </div>
  </div>
</div>
<div id="horizontal-scroller" class="dragdealer">
  <div class="handle scroller-gray-bar">
  </div>
</div>
"""