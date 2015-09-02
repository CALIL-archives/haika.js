# gulpでapp.haika.ioをプロキシーしてJSON取得
haikaId = 15
$(haika).on 'haika:initialized', ->
  haika.openFromApi(haikaId,{
    success: ->
      haika.render()
      haika.property.init()
      haika.zoomFull()
      if haika.readOnly
        haika.event.zoom()
      else
        haika.toolbar.init()
        haika.event.init()
        haika.undo.init()
        initScrollBar()
        #haika.colorpicker.init()
    error: (message) ->
      alert(message)
  })

# 初期設定
haika.init
  divId : 'haika-canvas'
