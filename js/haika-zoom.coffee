# ズーム機能

$.extend haika,

# オブジェクトの最大幅を計算してそれにキャンバスをフィットさせて表示する (これはUI側のため将来的に移動)
#
  zoomFull: ->
    if @objects.length<0
      return
    @setScale 1
    @render()
    for object in @canvas.getObjects()
      bound  = object.getBoundingRect()
      if not left?
        left = bound.left
        right = bound.left+bound.width
        top = bound.top
        bottom = bound.top+bound.height
        continue
      left   = Math.min(bound.left, left)
      right  = Math.max(bound.left+bound.width, right)
      top    = Math.min(bound.top, top)
      bottom = Math.max(bound.top+bound.height, bottom)
    # キャンバスの縦横を取得
    canvasWidth  = @canvas.getWidth()
    canvasHeight = @canvas.getHeight()

    width = right-left
    height = bottom-top

    log width
    log height

    widthScale = canvasWidth/width
    heightScale = canvasHeight/height

    log widthScale
    log heightScale
    return

#    if widthScale>=heightScale
#      scaleFactor = widthScale
#    else
#      scaleFactor = heightScale
    # 1より小さい、canvasに対して大きい→縮小=1以下
    # 1より大きい、canvasに対して小さい→拡大=1以上
    log scaleFactor
    newScale = 1  - (scaleFactor - 1)
    log newScale
    @setScale newScale

    # x canvasWidth/2 = 0
    # y canvasHeight/2 = 0

#    @centerX = width/2
#    @centerY = height/2
#    @render()

# 表示時の拡大率を1ステップ拡大する (これはUI側のため将来的に移動)
#
  zoomIn: ->
    prevScale = @scaleFactor
    newScale = prevScale + Math.pow(prevScale + 1, 2) / 20
    if newScale < 1 and prevScale > 1
      newScale = 1
    @setScale newScale

# 表示時の拡大率を1ステップ縮小する (これはUI側のため将来的に移動)
#
  zoomOut: ->
    prevScale = @scaleFactor
    newScale = prevScale - Math.pow(prevScale + 1, 2) / 20
    if prevScale > 1 and newScale < 1
      newScale = 1
    @setScale newScale
