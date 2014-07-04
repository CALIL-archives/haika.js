scrollbar_width = $('#vertical-scroller').width()
scrollbar_height = $('#horizontal-scroller').height()
property_panel_width = $('.property_panel').width()

get_width = ->
  return window.innerWidth - scrollbar_width - property_panel_width - 20

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
  callback : ->
    # scrollbar
    scroll_weight = 5000
    maxX = app.bgimg_width * app.options.bgscale / 2
    maxY = app.bgimg_height * app.options.bgscale / 2
    defaultX =  -((app.centerX - scroll_weight) / 10000)
    defaultY =  -((app.centerY - scroll_weight) / 10000)
    new Dragdealer 'horizontal-scroller',
      x: defaultX
      animationCallback: (x, y)->
  #      log x
        app.unselect()
        centerX = x * 10000 - scroll_weight
        if centerX > maxX - app.canvas.getWidth() / 2
          centerX = maxX - app.canvas.getWidth() / 2
        if centerX < -maxX + app.canvas.getWidth() / 2
          centerX = -maxX + app.canvas.getWidth() / 2
        app.centerX = -centerX.toFixed(0)
        app.render()
    new Dragdealer 'vertical-scroller',
      y: defaultY
      horizontal: false,
      vertical: true,
  #    yPrecision: 500,
      animationCallback: (x, y)->
        app.unselect()
        centerY = y * 10000 - scroll_weight
        if centerY > maxY - app.canvas.getHeight() / 2
          centerY = maxY - app.canvas.getHeight() / 2
        if centerY < -maxY + app.canvas.getHeight() / 2
          centerY = -maxY + app.canvas.getHeight() / 2
        app.centerY = -centerY.toFixed(0)
        app.render()

)

$('.main_container, .canvas_panel').css('width', get_width())


$('#vertical-scroller, #vertical-scroller .dragdealer').css('height', get_height())
$('.property_panel').css('height', get_height()+scrollbar_height)

$(window).resize ->
  app.canvas.setWidth(get_width())
  app.canvas.setHeight(get_height())
  $('.main_container, .canvas_panel').css('width', get_width())
  $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', get_height())
  $('.property_panel').css('height', get_height()+scrollbar_height)
  app.render()

add = (val)->
  log val
  klass = app.get_class(val.type)
  object = new klass(
    top: app.transformTopY_cm2px(app.centerY)
    left: app.transformLeftX_cm2px(app.centerX)
    fill: "#CFE2F3"
    stroke: "#000000"
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
  id = app.add(object)
  app.set_state(object)
  app.render()
  undo.add(id)
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
  $(".add").click ->
    add()
    app.render()

  toolbar = 
    shelf :
      icon  : 'square-o'
      title : '一般本棚'
      eachWidth: 90
      eachHeight: 26
      count : 5
      side  : 1
    big_shelf :
      icon  : 'square-o'
      title : '大型本棚'
      eachWidth: 90
      eachHeight: 33
      count : 5
      side  : 1
    magazine_shelf :
      icon  : 'square-o'
      title : '雑誌本棚'
      eachWidth: 90
      eachHeight: 45
      count : 5
      side  : 1
    kamishibai_shelf :
      icon  : 'square-o'
      title : '紙芝居'
      eachWidth: 90
      eachHeight: 90
      count : 1
      side  : 1
    booktrack_shelf :
      icon  : 'square-o'
      title : 'ブックトラック'
      eachWidth: 60
      eachHeight: 40
      count : 1
      side  : 1
      angle : 20
    curved_shelf :
      icon  : 'dot-circle-o'
      title : '円形本棚'
      count : 3
      side  : 2
    beacon :
      icon  : 'square'
      title : 'ビーコン'
  for key, val of toolbar
    html = """<li id="add_#{key}" key="#{key}"><i class="fa fa-#{val.icon}"></i> #{val.title}</li>"""
    $('.toolbar_container').append(html)
    $('#add_'+key).click (e)->
      key =  $(e.target).attr('key')
      object = toolbar[key]
      object.type = key
      add(object)
      app.render()
  # toolbar
  $(".add_custom_shelf").click ->
    add('custom_shelf')
    app.render()
  $(".add_beacon").click ->
    add('beacon')
    app.render()
  $(".remove").click ->
    object = app.canvas.getActiveObject()
    app.remove()
    if object
      undo.remove(object)
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
    undo.undoManager.undo()

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
    undo.undoManager.undo()
    return false
  Mousetrap.bind ['esc', 'escape'], (e)->
    cancel_default(e)
    app.unselect_all()
    return false
  Mousetrap.bind ['up', 'shift+up'], (e)->
    cancel_default(e)
    app.up(e)
    return false
  Mousetrap.bind ['down', 'shift+down'], (e)->
    cancel_default(e)
    app.down(e)
    return false
  Mousetrap.bind ['left', 'shift+left'], (e)->
    cancel_default(e)
    app.left(e)
    return false
  Mousetrap.bind ['right', 'shift+right'], (e)->
    cancel_default(e)
    app.right(e)
    return false
#  Mousetrap.bind '=', (e)->
#    cancel_default(e)
#    app.zoomIn()
#    return false
#  Mousetrap.bind '-', (e)->
#    cancel_default(e)
#    app.zoomOut()
#    return false
#  Mousetrap.bind '0', (e)->
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

# Undo
undo =
  undoManager : new UndoManager()
  states : []
  set_selected : true
  add : (id)->
    log 'add set'
    @undoManager.add
      undo: =>
        log 'undo add '+id
        object = @get_object(id)
        log object
        app.__remove(object)
#        app.save()
#        app.render()
      redo: =>
  remove : (object)->
    log 'remove set'
    @undoManager.add
      undo: =>
        log 'undo remove '+object.id
        log object
        app.add(object)
        app.render()
      redo: =>
  init : ->
    app.canvas.on "object:selected", (e) =>
      object = e.target
#      console.log "object:selected"
      if not @set_selected
        @set_selected = true
        return
      if @states.length==0 or object.id!=@states[@states.length-1].id
        object.saveState()
        originalState = $.extend(true, {}, object.originalState)
        originalState.state_type = 'selected'
        @states.push(originalState)
#        log @states

    app.canvas.on "selection:cleared", (e) =>
      object = e.target
    #  console.log "selection:cleared"


    app.canvas.on "object:modified", (e) =>
      object = e.target
    #  console.log "object:modified"
#      log object
#      group = app.canvas.getActiveGroup()
#      if group
#        objects = group.getObjects()
#        log group.top
#      else
#        log object.top
#        objects = [object]
#      for object in objects
      object.saveState()
      originalState = $.extend(true, {}, object.originalState)
      originalState.state_type = 'modified'
#        log originalState
#        if objects.length>1
#          originalState.top += group.top
#          originalState.left += group.left
      @states.push(originalState)
#      log @states
      @undoManager.add
        undo: =>
    #      log 'undo'
          if @states.length>0
            app.canvas.deactivateAll()
            state = @states[@states.length-2]
            object = @get_object(state.id)
    #        log object
            if object
              @set_state(object, state)
              @states.pop()
#              log @states[@states.length-1].state_type
              if @states[@states.length-1].state_type=='selected'
                @states.pop()
    #          app.canvas.renderAll()
              @set_selected = false
              app.canvas.setActiveObject(object)
            log @states
        redo: =>
    #      redo()
      return
  get_object : (id)->
    object = null
    for o in app.canvas.getObjects()
      if o.id==id
        object = o
        break
    return object
  set_state : (object, state)->
    object.setOptions state
    object.setCoords()

undo.init()