scrollbar_width = $('#vertical-scroller').width()
scrollbar_height = $('#horizontal-scroller').height()
property_panel_width = $('.property_panel').width()

# キャンバスの横幅計算
getWidth = ->
  return window.innerWidth - scrollbar_width - property_panel_width - 20

# キャンバスの縦幅計算
getHeight = ->
  return window.innerHeight - $('.header').height() - scrollbar_height

$('.main_container, .canvas_panel').css('width', getWidth())
$('#vertical-scroller, #vertical-scroller .dragdealer').css('height', getHeight())
$('.property_panel').css('height', getHeight()+scrollbar_height)

$(window).resize ->
  haika.canvas.setWidth(getWidth())
  log getWidth()
  haika.canvas.setHeight(getHeight())
  $('.main_container, .canvas_panel').css('width', getWidth())
  $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', getHeight())
  $('.property_panel').css('height', getHeight()+scrollbar_height)
  haika.render()

haika.init(
  canvas : 'canvas'
  canvas_width : getWidth()
  canvas_height : getHeight()
  max_width: 10000
  max_height: 10000
  #bgurl  : 'img/meidai2.png'
  #bgurl  : 'img/sample.png'
  bgopacity: 0.2
  bgscale  : 4
  callback : setScrollbar
)

$ ->
  # レイヤータブ
  $('.nav-tabs a').click (e)->
    e.preventDefault()
    haika.state = $(e.target).attr('class')
    haika.render()
    $(this).tab('show')
  
#  $('.add').click ->
#    add()
#    haika.render()

