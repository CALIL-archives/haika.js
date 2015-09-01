

# プロパティパネルの表示
$(haika).on 'haika:render', ->
    $('#haika-canvas-width').html(haika.canvas.getWidth())
    $('#haika-canvas-height').html(haika.canvas.getHeight())
    $('#haika-canvas-centerX').html(haika.centerX.toFixed(0))
    $('#haika-canvas-centerY').html(haika.centerY.toFixed(0))
    $('#haika-canvas-bgscale').val(haika.backgroundScaleFactor)
    $('#haika-canvas-bgopacity').val(haika.backgroundOpacity)



haikaId = 15
haika.html('.haika-container')
$(haika).on 'haika:initialized', ->
  haika.render()
  haika.property.init()
#  haika.zoomFull()
#  haika.openFromApi(haikaId,{
#    success: ->
#    error: (message) ->
#      alert(message)
#  })


# 初期設定
haika.init
  divId : 'haika-canvas'
#  readOnly: true

if haika.readOnly
  haika.event.zoom()
else
#  haika.toolbar.init()
#  haika.event.init()
#  haika.undo.init()
#  initScrollBar()
  #haika.colorpicker.init()


