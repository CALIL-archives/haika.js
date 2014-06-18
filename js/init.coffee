scrollbar_width = $('#vertical-scroller').width()
scrollbar_height = $('#horizontal-scroller').height()
propery_panel_width = $('.propery_panel').width()

get_width = ->
  return window.innerWidth - scrollbar_width - propery_panel_width - 20

get_height = ->
  return window.innerHeight - $('.header').height() - scrollbar_height

app.init(
  canvas : 'canvas'
  canvas_width : get_width()
  canvas_height : get_height()
  scale : 1
  max_width: 10000
  max_height: 10000
  #bgurl  : 'http://office.nanzan-u.ac.jp/TOSHOKAN/publication/bulletin/kiyo7/03-01.jpg'
  bgurl  : 'img/meidai2.png'
  #bgurl  : 'img/sample.png'
  bgopacity: 0.2
  bgscale  : 4.425
)

$('.main_container, .canvas_panel').css('width', get_width())


$('#vertical-scroller, #vertical-scroller .dragdealer').css('height', get_height())
$('.propery_panel').css('height', get_height()+scrollbar_height)

$(window).resize ->
  app.canvas.setWidth(get_width())
  app.canvas.setHeight(get_height())
  $('.main_container, .canvas_panel').css('width', get_width())
  $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', get_height())
  $('.propery_panel').css('height', get_height()+scrollbar_height)
  app.render()

add = (left=0, top=0)->
  if $('#type').val()=='Shelf'
    klass = fabric.Shelf
  if $('#type').val()=='curvedShelf'
    klass = fabric.curvedShelf
  if $('#type').val()=='Beacon'
    klass = fabric.Beacon
  object = new klass(
    count: parseInt($('#count').val())
    side: parseInt($('#side').val())
    top: app.transformX_cm2px(app.centerY)
    left: app.transformY_cm2px(app.centerX)
    fill: "#CFE2F3"
    stroke: "#000000"
    angle: parseInt($('#angle').val())
    #lockScalingY: true
  )
  app.add(object)
  app.render()
  $(app.canvas.getObjects()).each (i, obj)=>
    if obj.id==object.id
      setTimeout ->
        app.canvas.setActiveObject(app.canvas.item(i))
        $('.add').blur()
      , 10
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

  $('.nav-tabs a').click (e)->
    e.preventDefault()
    app.state = $(e.target).attr('class')
    app.render()
    $(this).tab('show')
  new Dragdealer 'horizontal-scroller',
    x: 0.5
    animationCallback: (x, y)->
#      log x
      app.unselect()
      maxX = app.bgimg_width * app.options.bgscale / 2
      centerX = x * 10000 - 5000
      if centerX > maxX - app.canvas.getWidth() / 2
        centerX = maxX - app.canvas.getWidth() / 2
      if centerX < -maxX + app.canvas.getWidth() / 2
        centerX = -maxX + app.canvas.getWidth() / 2
      app.centerX = -centerX.toFixed(0)
      app.render()
  new Dragdealer 'vertical-scroller',
    y: 0.5
    horizontal: false,
    vertical: true,
#    yPrecision: 500,
    animationCallback: (x, y)->
      app.unselect()
      maxY = app.bgimg_height * app.options.bgscale / 2
      centerY = y * 10000 - 5000
      if centerY > maxY - app.canvas.getHeight() / 2
        centerY = maxY - app.canvas.getHeight() / 2
      if centerY < -maxY + app.canvas.getHeight() / 2
        centerY = -maxY + app.canvas.getHeight() / 2
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
  $(".copy").click ->
    app.copy()
  $(".paste").click ->
    app.paste()
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
  $(".loadsvg").click ->
    loadSVG 'http://fabreasy.com/demo_front.svg', app.canvas, ->
      alert('done');
  $(".geojson").click ->
    app.getGeoJSON()
  $(".reset").click ->
    app.objects = []
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

  timeout = false
  $('canvas').on 'mousewheel', (event)=>
    #console.log(event.deltaX, event.deltaY, event.deltaFactor);
  #    log 'event.deltaX:'+event.deltaX
  #    log 'event.deltaY:'+event.deltaY
  #    log 'event.deltaFactor'+event.deltaFactor
    if timeout
      return
    else
      timeout = setTimeout ->
          timeout = false
      , 100
    if event.deltaY>0
      app.zoomIn()
    if event.deltaY<0
      app.zoomOut()

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

    
  $('.undo').click ->
    undoManager.undo()

  # shortcut key
  cancel_default = (e)->
    if e.preventDefault
      e.preventDefault()
    else
      # internet explorer
      e.returnValue = false;
  Mousetrap.bind 'mod+c', ->
    app.copy()
    return false
  Mousetrap.bind 'mod+v', ->
    app.paste()
    return false
  Mousetrap.bind 'mod+d', (e)->
    cancel_default(e)
    app.duplicate()
    return false
  Mousetrap.bind 'mod+a', (e)->
    cancel_default(e)
    app.select_all()
    return false
  Mousetrap.bind 'mod+z', (e)->
    cancel_default(e)
    undoManager.undo()
    return false
  Mousetrap.bind ['esc', 'escape'], (e)->
    cancel_default(e)
    app.unselect_all()
    return false
#  Mousetrap.bind 'mod+=', (e)->
#    log e
#    cancel_default(e)
#    app.zoomIn()
#    return false
#  Mousetrap.bind 'mod+–', (e)->
#    log e.keyCode
#    cancel_default(e)
#    app.zoomOut()
#    return false
#  Mousetrap.bind 'mod+0', (e)->
#    cancel_default(e)
#    app.zoomReset()
#    return false
  # Prevent the backspace key from navigating back.
  $(document).unbind("keydown").bind "keydown", (event) ->
    doPrevent = false
    if event.keyCode is 8 or event.keyCode is 46
      d = event.srcElement or event.target
      if (d.tagName.toUpperCase() is "INPUT" and (d.type.toUpperCase() is "TEXT" or d.type.toUpperCase() is "PASSWORD" or d.type.toUpperCase() is "FILE" or d.type.toUpperCase() is "EMAIL")) or d.tagName.toUpperCase() is "TEXTAREA"
        doPrevent = d.readOnly or d.disabled
      else
        doPrevent = true
    if doPrevent
      event.preventDefault()
      app.remove()
    return

undoManager = new UndoManager()
states = []

app.canvas.on "object:added", (e) ->
  object = e.target
#  undoManager.add
#    undo: ->
#      app.remove(object)
#    redo: ->

app.canvas.on "object:selected", (e) ->
  object = e.target
#  console.log "object:selected"
  if states.length==0 or object.id!=states[states.length-1].id
    object.saveState()
    originalState = $.extend(true, {}, object.originalState)
    originalState.select = true
    states.push(originalState)
#    log states

app.canvas.on "selection:cleared", (e) ->
  object = e.target
#  console.log "selection:cleared"


app.canvas.on "object:modified", (e) ->
  object = e.target
#  console.log "object:modified"
  object.saveState()
  originalState = $.extend(true, {}, object.originalState)
  states.push(originalState)
#  log states
  undoManager.add
    undo: ->
#      log 'undo'
      if states.length>0
        state = states[states.length-2]
        object.setOptions state
        states.pop()
        object.setCoords()
        app.canvas.setActiveObject(object)
        app.render()
#        log states
    redo: ->
#      redo()
  return

