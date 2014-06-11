app.init(
  canvas : 'canvas'
  #canvas_width : 800
  #canvas_height : 600
  canvas_width : window.innerWidth - 30
  canvas_height : window.innerHeight - $('.header').height() - 30
  scale : 1
  max_width: 10000
  max_height: 10000
  #bgurl  : 'http://office.nanzan-u.ac.jp/TOSHOKAN/publication/bulletin/kiyo7/03-01.jpg'
  bgurl  : 'img/meidai2.png'
  #bgurl  : 'img/sample.png'
  bgopacity: 0.2
  bgscale  : 4.425
)
$('#vertical-scroller, #vertical-scroller .dragdealer').css('height', window.innerHeight - $('.header').height() - $('.canvas_panel').height() - 30)
$(window).resize ->
  app.canvas.setWidth(window.innerWidth - 30)
  app.canvas.setHeight(window.innerHeight - $('.header').height() - 30)
  $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', window.innerHeight - $('.header').height() - $('.canvas_panel').height() - 30)
#  app.canvas.setWidth(800)
#  app.canvas.setHeight(600)
#  app.centerX = -app.canvas.getWidth() / 2
#  app.centerY = -app.canvas.getHeight() / 2
  app.render()

add = (left=0, top=0)->
  if $('#type').val()=='Shelf'
    klass = fabric.Shelf
  if $('#type').val()=='curvedShelf'
    klass = fabric.curvedShelf
  if $('#type').val()=='Beacon'
    klass = fabric.Beacon
  shape = new klass(
    count: parseInt($('#count').val())
    side: parseInt($('#side').val())
    top: app.transformX_cm2px(app.centerY)
    left: app.transformY_cm2px(app.centerX)
    fill: "#CFE2F3"
    stroke: "#000000"
    angle: parseInt($('#angle').val())
    #lockScalingY: true
  )
  app.add(shape)
  app.render()
#setTimeout(->
  #addmany()
  #add(250, 250)
#, 500)


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

  new Dragdealer 'horizontal-scroller',
    x: 0.5
    animationCallback: (x, y)->
#      log x
      centerX = x * 10000 - 5000
      if centerX > (5000 - app.canvas.getWidth())
        centerX = 5000 - app.canvas.getWidth()
      if centerX < (-5000 + app.canvas.getWidth())
        centerX = -5000 + app.canvas.getWidth()
      app.centerX = -centerX.toFixed(0)
      app.render()
  new Dragdealer 'vertical-scroller',
    y: 0.5
    horizontal: false,
    vertical: true,
#    yPrecision: 500,
    animationCallback: (x, y)->
      centerY = y * 10000 - 5000
      app.centerY = -centerY.toFixed(0)
      app.render()
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
  $(".duplicate").click ->
    app.duplicate()
#  $(".toright").click ->
#    app.toRight()
#  $(".toleft").click ->
#    app.toLeft()
#  $(".totop").click ->
#    app.toTop()
#  $(".tobottom").click ->
#    app.toBottom()
  $(".svg").click ->
    app.getSVG()
  $(".geojson").click ->
    app.getGeoJSON()
  $(".reset").click ->
    localStorage.clear()
    location.reload()
#  $(".rotate").slider
#    min: 0
#    max: 360
#    step: 10
#    value: 0
#    slide: (event, ui) ->
#      activeObject = app.canvas.getActiveObject()
#      if activeObject
#        activeObject.angle = ui.value
#        activeObject.setCoords()
#        app.canvas.renderAll()
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
    app.centerX = parseInt($(this).val())
  $('#canvas_centerY').change ->
    app.centerY = parseInt($(this).val())
  $('#canvas_bgscale').change ->
    app.options.bgscale = parseInt($(this).val())
  $('#canvas_render').click ->
    app.render()
