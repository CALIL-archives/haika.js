app.init(
  canvas : 'canvas'
  #canvas_width : 800
  #canvas_height : 600
  canvas_width : $(window).width()
  canvas_height : $(window).height() - 100
  scale : 1
  max_width: 10000
  max_height: 10000
  #bgurl  : 'http://office.nanzan-u.ac.jp/TOSHOKAN/publication/bulletin/kiyo7/03-01.jpg'
  bgurl  : 'img/meidai2.png'
  bgopacity: 1
  bgscale  : 4
)
$(window).resize ->
  app.canvas.setWidth($(window).width())
  app.canvas.setHeight($(window).height() - 100)
  #app.canvas.setWidth(800)
  #app.canvas.setHeight(600)
  #app.centerX = -app.canvas.getWidth() / 2
  #app.centerY = -app.canvas.getHeight() / 2
  app.render()

add = (left=0, top=0, angle=0)->
  shelf = new fabric.Shelf(
    count: parseInt($('#count').val())
    side: parseInt($('#side').val())
    top: app.transformX_cm2px(top)
    left: app.transformY_cm2px(left)
    fill: "#CFE2F3"
    stroke: "#000000"
    angle: angle
    #lockScalingY: true
  )
  app.add(shelf)
setTimeout(->
  #addmany()
  #add(250, 250)
  #$('#count').val(5)
  #$('#side').val(2)
  #add(160, 200)
  #add(-10, -10)
  #add(0, 0)
  objects = JSON.parse(localStorage.getItem('app_data'))
  log objects
  if objects
    for object in objects
      log object.count
      log object.side
      #add(object.left_cm, object.top_cm, object.angle)
      shelf = new fabric.Shelf(
        count: object.count
        side: object.side
        top: app.transformX_cm2px(object.top_cm)
        left: app.transformY_cm2px(object.left_cm)
        fill: "#CFE2F3"
        stroke: "#000000"
        angle: object.angle
      )
      app.add(shelf)
  app.render()
, 500)


#    fabric.Shelf.async = true;
$ ->
  window.addmany = ->
    y = 0
    while y < 8
      x = 0
      while x < 22
        add 200 + 400 * y, 100 + 50 * x, 90
        x++
      y++
    app.render()
    return

  $(".add").click ->
    add()
    app.render()
  $(".remove").click ->
    app.remove()
  $(".zoomin").click ->
    app.zoomIn()
  $(".zoomout").click ->
    app.zoomOut()
  $(".zoomreset").click ->
    app.zoomReset()
  $(".bringtofront").click ->
    app.bringToFront()
  $(".toright").click ->
    app.toRight()
  $(".toleft").click ->
    app.toLeft()
  $(".totop").click ->
    app.toTop()
  $(".tobottom").click ->
    app.toBottom()
  $(".rotate").slider
    min: 0
    max: 360
    step: 10
    value: 0
    slide: (event, ui) ->
      activeObject = app.canvas.getActiveObject()
      if activeObject
        activeObject.angle = ui.value
        activeObject.setCoords()
        app.canvas.renderAll()
  $(".svg").click ->
    app.getSVG()
  $(".reset").click ->
    localStorage.clear()
    location.reload()
#  $('canvas').on 'mousewheel', (event)=>
#    #console.log(event.deltaX, event.deltaY, event.deltaFactor);
#    if event.deltaY==1
#      app.zoomIn()
#    if event.deltaY==-1
#      app.zoomOut()
#  @shiftKey = false
#  $(document.body).keydown (e)=>
#    @shiftKey = e.shiftKey

#  $('#canvas').on 'doubletap', (e)=>
#    if @shiftKey
#      @zoomOut()
#    else
#      @zoomIn()
  # デバッグパネル
  $('#canvas_width').change ->
    app.canvas.setWidth($(this).val())
  $('#canvas_height').change ->
    app.canvas.setHeight($(this).val())
  $('#canvas_centerX').change ->
    app.centerX = $(this).val()
  $('#canvas_centerY').change ->
    app.centerY = $(this).val()
  $('#canvas_render').click ->
    app.render()
