# ズーム機能

$.extend haika,

# オブジェクトの最大幅を計算してそれにキャンバスをフィットさせて表示する (これはUI側のため将来的に移動)
#
  zoomFull: ->
    if @objects.length<0
      return
    geojson = @toGeoJSON()
    for object in geojson.features
      for point in object.geometry.coordinates[0]
#        log point[0]
        if not left?
          left   = point[0]
          right  = point[0]
          top    = point[1]
          bottom = point[1]
          continue
        left   = Math.min(point[0]*100, left)
        right  = Math.max(point[0]*100, right)
        top    = Math.min(point[1]*100, top)
        bottom = Math.max(point[1]*100, bottom)
    log left
    log right

    @centerX = -(right+left)/2
    @centerY = (bottom+top)/2
#    @render()
#    return

    width  = right-left
    height = bottom-top

    log width
    log height

    # キャンバスの縦横を取得
    canvasWidth  = @canvas.getWidth()
    canvasHeight = @canvas.getHeight()

    log canvasWidth
    log canvasHeight

    widthScale = canvasWidth/width
    heightScale = canvasHeight/height

    log widthScale
    log heightScale

    scale = if widthScale<heightScale then widthScale else heightScale
    log scale
    # 1より大きい、canvasに対して小さい→拡大=1以上
    # 1より小さい、canvasに対して大きい→縮小=1以下
    @setScale scale * 0.5


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
