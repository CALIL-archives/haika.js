# 画像配架図変換
# 画像を読み込む
loadImg = (file) ->
  if not file.type.match(/image\/.+/)
    return  
  #NOTE:svgを渡すとchromeでcanvasのgetImageDataがエラーを発してしまう．
  if file.type is "image/svg+xml"
    return  
  reader = new FileReader()
  reader.onload = ->
    loadComplete(@result)
  reader.readAsDataURL file

#変換処理ボタンクリック時
$('#file').change (e)->
  files = e.target.files
  if files.length==0
    return
  loadImg files[0]

# 画像をwebworkerで処理
loadComplete = (data)->
  # 画像
  img = new Image()
  img.src = data
  # 色情報を取得するための canvas
  canvas = document.createElement('canvas')
  ctx = canvas.getContext('2d')
  canvas.width = img.width
  canvas.height = img.height
  ctx.translate(0,img.height);
  ctx.scale(1,-1);
  ctx.translate(img.width,0);
  ctx.scale(-1,1);
  ctx.drawImage(img, 0, 0)
  # 画像の色情報を取得
  w = canvas.width
  h = canvas.height
  data = ctx.getImageData(0, 0, w, h).data

  params =
    image : data
    w     : w
    h     : h
  worker = new Worker("js/haika-image-worker.js")
  worker.onmessage = (e) ->
    log e.data
    switch e.data.status
      when "working"
        log e.data.count
      when "end"
        results = e.data.result
        for result in results
          addPixel(result.x, result.y, result.color)
        haika.render()

  worker.postMessage params

# ピクセル情報から棚を追加
addPixel = (x, y, color)->
  dot = 10
  klass = haika.getClass('shelf')
  object = new klass(
    top: haika.transformTopY_cm2px(y*dot)
    left: haika.transformLeftX_cm2px(x*dot)
    fill: color
    stroke: color
    angle: 0
    count: 1
    side : 1
    eachWidth: dot
    eachHeight: dot
  )
  haika.add(object)
