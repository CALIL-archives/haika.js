# ウィンドウサイズにあわせてサイズ変更
windowSetting =
  navbar_height : ->
    return if $('#navbar').length>0 then $('#navbar').height()+45 else 0
  sidebar_width : ->
    return if $('.sidebar-collapse').length>0 then $('.sidebar-collapse').width()+45 else 0
  scrollbar_width      : $('#vertical-scroller').width()
  scrollbar_height     : $('#horizontal-scroller').height()
  toolbar_width        : $('.toolbar_container').width() + 14
  property_panel_width : $('.property_panel').width()
  # キャンバスの横幅計算
  getWidth : ->
    return window.innerWidth - @sidebar_width() - @toolbar_width - @scrollbar_width - @property_panel_width - 20
  # キャンバスの縦幅計算
  getHeight : ->
    return window.innerHeight - @navbar_height() - $('.header').height() - @scrollbar_height

  start : ->
    $('.main_container, .canvas_panel').css('width', @getWidth())
    $('.main_container').css('margin-left', @toolbar_width)
    $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', @getHeight())
    $('.toolbar_container,.property_panel').css('height', @getHeight()+@scrollbar_height)

    $(window).resize =>
      haika.canvas.setWidth(@getWidth())
      haika.canvas.setHeight(@getHeight())
      $('.main_container, .canvas_panel').css('width', @getWidth())
      $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', @getHeight())
      $('.toolbar_container,.property_panel').css('height', @getHeight()+@scrollbar_height)
      haika.render()

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

$(haika).on 'haika:initialized', ->
  haika.openFromApi(2,
    {
      succcess: =>
        @render()
      error: (message) ->
        alert(message)
    }
  )

# 初期設定
haika.init
  canvasId : 'canvas_area'
  width : windowSetting.getWidth()
  height : windowSetting.getHeight()

haika.undo.init()
windowSetting.start()
haika.addbuttons.showAddButtons(haika.state)
initScrollBar()
haika.map.initMap()
haika.colorpicker.init()
