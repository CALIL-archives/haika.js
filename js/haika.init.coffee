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
  haika.canvas.setHeight(getHeight())
  $('.main_container, .canvas_panel').css('width', getWidth())
  $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', getHeight())
  $('.property_panel').css('height', getHeight()+scrollbar_height)
  haika.render()

haika.init(
  canvas : 'canvas'
  canvas_width : getWidth()
  canvas_height : getHeight()
  scale : 1
  max_width: 10000
  max_height: 10000
  #bgurl  : 'img/meidai2.png'
  #bgurl  : 'img/sample.png'
  bgopacity: 0.2
  bgscale  : 4.425
  callback : setScrollbar
)

# オブジェクトの追加
add = (val)->
  log val
  klass = haika.getClass(val.type)
  object = new klass(
    top: haika.transformTopY_cm2px(haika.centerY)
    left: haika.transformLeftX_cm2px(haika.centerX)
    fill: haika.fillColor
    stroke: haika.strokeColor
    angle: if val.angle? then val.angle else 0
    #lockScalingY: true
  )
  if val.count?
    object.count = val.count
  if val.side?
    object.side = val.side
  if val.type.match(/shelf$/)
    object.eachWidth = val.eachWidth
    object.eachHeight = val.eachHeight
  id = haika.add(object)
  haika.setState(object)
  haika.render()
  undo.add(id)
  $(haika.canvas.getObjects()).each (i, obj)=>
    if obj.id==object.id
      setTimeout ->
        haika.canvas.setActiveObject(haika.canvas.item(i))
        $('.add').blur()
      , 10
#setTimeout(->
  #addmany()
  #add(250, 250)
#, 500)

# テスト用
addmany = ->
  y = 0
  while y < 8
    x = 0
    while x < 22
      add 200 + 400 * y, 100 + 50 * x, 90
      x++
    y++
  haika.render()
  return

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

