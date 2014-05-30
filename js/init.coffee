app.init(
  canvas : 'canvas'
  canvas_width : 800
  canvas_height : 600
  max_width: 10000
  max_height: 10000
  #bgurl  : 'http://office.nanzan-u.ac.jp/TOSHOKAN/publication/bulletin/kiyo7/03-01.jpg'
  bgurl  : 'meidai2.png'
  bgopacity: 0.5
  bgscale  : 4
)
app.scale = 1
add = (top=300, left=300, angle=0)->
  shelf = new fabric.Shelf(
    count: parseInt($('#count').val())
    side: $('#side').val()
    top: top
    left: left
    fill: "#CFE2F3"
    stroke: "#000000"
    angle: angle
  )
  app.add(shelf)
setTimeout(->
  addmany()
  #add()
  #app.render()
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
  $(".save").click ->
    app.save()
