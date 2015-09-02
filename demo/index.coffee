

# プロパティパネルの表示
$(haika).on 'haika:render', ->
    $('#haika-canvas-width').html(haika.canvas.getWidth())
    $('#haika-canvas-height').html(haika.canvas.getHeight())
    $('#haika-canvas-centerX').html(haika.centerX.toFixed(0))
    $('#haika-canvas-centerY').html(haika.centerY.toFixed(0))
    $('#haika-canvas-bgscale').val(haika.backgroundScaleFactor)
    $('#haika-canvas-bgopacity').val(haika.backgroundOpacity)


haika.html('.haika-container')
$(haika).on 'haika:initialized', ->
  $.ajax
      url: 'data/sabae.json'
      type: 'GET'
      cache: false
      dataType: 'json'
      error: ()=>
        option.error and option.error('データが読み込めませんでした')
      success: (json)=>
        if json.locked
          @readOnly = true
          return option.error and option.error('データはロックされています')
        haika._dataId = json.id
        haika._revision = json.revision
        haika._collision = json.collision
        haika._geojson = json.data
        haika.loadFromGeoJson()
        $(haika).trigger('haika:load')
        haika.render()
        if Property?
         new Property()
        if haika.zoomFull?
          haika.zoomFull()
        if haika.readOnly
          haika.event.zoom()
        else
          if haika.toolbar?
            haika.toolbar.init()
          if haika.event?
            haika.event.init()
          if haika.undo?
            haika.undo.init()
        if initScrollBar?
          initScrollBar()
          #haika.colorpicker.init()

# 初期設定
haika.init
  divId : 'haika-canvas'
#  readOnly: true



# フルスクリーンモードボタン
$('.fullscreen').click ->
  if $('.haika-container')[0].requestFullScreen
    $('.haika-container')[0].requestFullScreen()
  if $('.haika-container')[0].webkitRequestFullScreen
    $('.haika-container')[0].webkitRequestFullScreen()
  if $('.haika-container')[0].mozRequestFullScreen
    $('.haika-container')[0].mozRequestFullScreen()

# データのインポートボタン
$('#haika-import').click ->
  id = prompt('インポートするデータのIDを6桁で指定して下さい。')
  if id
    haika.import(id, {
      success: ->
        haika.render()
        haika.save()
      error: (message) ->
        alert(message)
    })
