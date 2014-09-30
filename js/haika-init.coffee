# haikaの設定、ウィンドウサイズにあわせてサイズ変更
$.extend haika, 
  setting:
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

      haika.init
        canvasId : 'canvas_area'
        width : @getWidth()
        height : @getHeight()


$ ->
  # レイヤータブ
  $('.nav-tabs a').click (e)->
    e.preventDefault()
    tabName= $(e.target).attr('class')
    haika.addbuttons.showAddButtons(tabName)
    if tabName=='beacon'
        haika.layer=haika.CONST_LAYERS.BEACON
    if tabName=='wall'
        haika.layer=haika.CONST_LAYERS.WALL
    if tabName=='floor'
        haika.layer=haika.CONST_LAYERS.FLOOR
    if tabName=='shelf'
        haika.layer=haika.CONST_LAYERS.SHELF
    haika.render()
    $(this).tab('show')

# 初期設定
haika.setting.start()

