$(haika).on 'haika:render', ->
    $('#canvas_width').html(haika.canvas.getWidth())
    $('#canvas_height').html(haika.canvas.getHeight())
    $('#canvas_centerX').html(haika.centerX)
    $('#canvas_centerY').html(haika.centerY)
    $('#canvas_bgscale').val(haika.backgroundScaleFactor)
    $('#canvas_bgopacity').val(haika.backgroundOpacity)
    $('#canvas_lon').val(haika.xyLongitude)
    $('#canvas_lat').val(haika.xyLatitude)
    $('#canvas_angle').val(haika.canvas.angle)
    $('.zoom').html((haika.scaleFactor * 100).toFixed(0) + '%')

$('.fullscreen').click ->
  if $('.haika-container')[0].requestFullScreen
    $('.haika-container')[0].requestFullScreen()
  if $('.haika-container')[0].webkitRequestFullScreen
    $('.haika-container')[0].webkitRequestFullScreen()
  if $('.haika-container')[0].mozRequestFullScreen
    $('.haika-container')[0].mozRequestFullScreen()


haikaId = location.hash.split('#')[1]
if not haikaId
  alert('HaikaIDを指定して下さい')
else

  $(haika).on 'haika:initialized', ->
    haika.openFromApi(haikaId,{
      success: ->
        haika.render()
      error: (message) ->
        alert(message)
    })

  # 初期設定
  haika.init
    divId : 'haika-canvas'
  #  readOnly: true

  if haika.readOnly
    haika.event.zoom()
  else
    haika.toolbar.init()
    haika.event.init()
    haika.undo.init()
    initScrollBar()
    haika.colorpicker.init()
