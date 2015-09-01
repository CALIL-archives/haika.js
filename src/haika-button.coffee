# ズーム機能

$.extend haika,

# オブジェクトの最大幅を計算してそれにキャンバスをフィットさせて表示する (これはUI側のため将来的に移動)
#
  zoomFull: ->
    if @objects.length<=0
      return
    geojson = @toGeoJSON()
    for object in geojson.features
      if @layer!=@CONST_LAYERS.FLOOR and object.properties.type == 'floor' and object.properties.is_negative
        continue

      for point in object.geometry.coordinates[0]
        if not left?
          left   = point[0]
          right  = point[0]
          top    = point[1]
          bottom = point[1]
          continue
        left   = Math.min(point[0], left)
        right  = Math.max(point[0], right)
        top    = Math.min(point[1], top)
        bottom = Math.max(point[1], bottom)

    @centerX = -(right+left)/2
    @centerY = (bottom+top)/2

    width  = right-left
    height = bottom-top

    # キャンバスの縦横を取得
    canvasWidth  = @canvas.getWidth()
    canvasHeight = @canvas.getHeight()

    widthScale = canvasWidth/width
    heightScale = canvasHeight/height

    scale = if widthScale<heightScale then widthScale else heightScale
    # 1より大きい、canvasに対して小さい→拡大=1以上
    # 1より小さい、canvasに対して大きい→縮小=1以下
    @setScale scale * 0.8


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


haika.htmlStack.push """
<div class="haika-buttons">
  <span class="haika-button haika-full">
    <i class="fa fa-arrows"></i>
  </span>
  <span class="haika-button haika-zoomin">
    <i class="fa fa-plus"></i>
  </span>
  <span class="haika-button haika-zoomout">
    <i class="fa fa-minus"></i>
  </span>
</div>
"""

haika.eventStack.push ->
  $('.haika-full').click ->
    haika.zoomFull()
  $('.haika-zoomin').click ->
    haika.zoomIn()
  $('.haika-zoomout').click ->
    haika.zoomOut()
  $('.zoomreset').click ->
    haika.setScale 1
