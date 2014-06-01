log = (obj) ->
  try
    console.log obj
SCALE_FACTOR = 2

app = 
  width      : 800
  height     : 800
  x          : 0
  y          : 0
  scale      : 1
  objects    : []
  object_id  : 1 
  canvas     : false
  drawguideline : true
  is_moving  : false
  is_scaling : false
  is_rotating: false
  bgimg: null
  bgimg_width: null
  bgimg_height: null
  options: {}
  init : (options)->
    default_options =
      canvas   : 'canvas'
      canvas_width : 800
      canvas_height: 600
      max_width    : 10000
      max_height   : 10000
      bgurl    : null
      bgopacity: 1
      bgscale  : 1
    @options = $.extend(default_options, options)
    @x = @options.max_width / 2 - @options.canvas_width
    @y = @options.max_height / 2 - @options.canvas_width
    canvas = new fabric.Canvas(@options.canvas)
    canvas.setWidth(@options.canvas_width)
    canvas.setHeight(@options.canvas_height)
    initAligningGuidelines(canvas)
#    initCenteringGuidelines(canvas)
    @canvas = canvas
    #@canvas.centeredRotation = true
    if @options.bgurl
      fabric.Image.fromURL @options.bgurl, (img)=>
        @bgimg = img
        @bgimg_width  = img.width
        @bgimg_height = img.height
    @canvas.on('object:selected', (e)=>
        object = e.target
    )
    @canvas.on('object:modified', (e)=>
        object = e.target
        log 'modified'
        if @is_moving
          @moving(object)
        if @is_scaling
          @scaling(object)
        if @is_rotating
          @rotating(object)
        @is_moving  = false
        @is_scaling = false
        @is_rotating= false
    )
    @canvas.on('object:moving', (e)=>
        object = e.target
        log 'moving'
        @is_moving  = true
    )
    @canvas.on('object:scaling', (e)=>
        object = e.target
        log 'scaling'
        @is_scaling = true
    )
    @canvas.on('object:rotating', (e)=>
        object = e.target
        log 'rotating'
        @is_rotating= true
    )
  add : (object)->
    object.__id = @object_id
    @object_id += 1
    o = 
      object : object 
    props = 'width height scaleX scaleY left top angle fill stroke'.split(' ')
    for prop in props
      o[prop] = object[prop]
    @objects.push(o)
    return o
  bind : (func, unselect=true)->
    object = @canvas.getActiveObject()
    if object
      return func(object)
    group = @canvas.getActiveGroup()
    if group
      objects = group._objects
      if unselect
        @canvas.deactivateAll().renderAll();
      for object in objects
        func(object)
    @render()
  remove : ->
    @bind (object)=>
      @canvas.remove(object)
      count = @match(object)
      if count!=null
        @objects.splice(count, 1)
  bringToFront : ->
    @bind (object)=>
      count = @match(object)
      if count!=null
        object.bringToFront()
        obj = @objects[count]
        @objects.splice(count, 1)
        @objects.push(obj) 
  match : (object)->
    count = 0
    for o in @objects
      if o['object'].__id==object.__id
        return count
      count += 1
    return null
  moving : (object)->
    log 'moving'
    @bind (object)=>
      count = @match(object)
      if count!=null
        @objects[count].top  = object.top / @scale + app.y
        @objects[count].left = object.left / @scale + app.x
  scaling : (object)->
    log 'scaling'
    @bind (object)=>
      log object
      count = @match(object)
      if count!=null
        log object.scaleX
        @objects[count].scaleX = object.scaleX / @scale
        @objects[count].scaleY = object.scaleY / @scale
        @objects[count].top    = object.top / @scale + app.y
        @objects[count].left   = object.left / @scale + app.x
  rotating : (object)->
    log 'rotating'
    @bind (object)=>
      count = @match(object)
      if count!=null
        @objects[count].angle = object.angle
        @objects[count].top   = object.top / @scale + app.y
        @objects[count].left  = object.left / @scale + app.x
  render : ->
    if @objects.length<=0
      return
    @canvas.clear()
    for o of @objects
      scaleX = @objects[o].scaleX
      scaleY = @objects[o].scaleY
      left   = @objects[o].left
      top    = @objects[o].top
      angle   = @objects[o].angle
      tempScaleX = scaleX * @scale
      tempScaleY = scaleY * @scale
      tempLeft   = left * @scale - app.x * @scale
      tempTop    = top * @scale - app.y * @scale
#      if tempLeft > @width 
#        continue
#      if tempTop > @height
#        continue
      object = @objects[o]['object']
      object.scaleX = tempScaleX
      object.scaleY = tempScaleY
      object.left   = tempLeft
      object.top    = tempTop
      if angle > 0
        object.angle  = angle
      object.originX = 'center'
      object.originY = 'center'
      object.setCoords()
      @canvas.add(object)
    if @scale==1 and @drawguideline
      fabric.drawGridLines(@canvas)
    @canvas.renderAll()
    if @bgimg
      @bgimg.left   = -(@x*@scale)
      @bgimg.top    = -(@y*@scale)
      @bgimg.width  = @bgimg_width*@options.bgscale*@scale
      @bgimg.height = @bgimg_height*@options.bgscale*@scale
      @bgimg.opacity= @options.bgopacity
      @canvas.setBackgroundImage @bgimg, @canvas.renderAll.bind(@canvas)

#    object.on(
#      modified: =>
#        @moving(object)
#        @scaling(object)
#        @rotating(object)
#      moving: =>
#        @moving(object)
#      scaling: =>
#        @scaling(object)
#      rotating: =>
#        @rotating(object)
#    )
  zoomIn : ->
    @scale += 0.1
    @scale = (@scale*100).toFixed(0)/100
    x = @x + @canvas.getWidth() / 2
    y = @y + @canvas.getHeight() / 2
    @x = x - (@canvas.getWidth() * @scale / 2)
    @y = y - (@canvas.getHeight() * @scale / 2)
    #@x += (@canvas.getWidth() * @scale - @canvas.getWidth()) / 2
    #@y += (@canvas.getHeight() * @scale - @canvas.getHeight()) / 2
    @render()
    $('.zoom').html((@scale*100).toFixed(0)+'%')
  zoomOut : ->
    if @scale<=0.1
      return
    @scale -= 0.1
    @scale = (@scale*100).toFixed(0)/100
    x = @x + @canvas.getWidth() / 2
    y = @y + @canvas.getHeight() / 2
    @x = x - (@canvas.getWidth() * @scale / 2)
    @y = y - (@canvas.getHeight() * @scale / 2)
    #@x -= (@canvas.getWidth() - @canvas.getWidth() * @scale) / 2
    if @x<0
      @x = 0
    #@y -= (@canvas.getHeight() - @canvas.getHeight() * @scale) / 2
    if @y<0
      @y = 0
    @render()
    $('.zoom').html((@scale*100).toFixed(0)+'%')
  zoomReset : ->
    @scale = 1
    @render()
    $('.zoom').html('100%')
  toTop :(y=100) ->
    if @y>0
      @y -= y
      @render()
  toBottom : (y=100)->
    @y += y
    @render()
  toRight : (x=100)->
    @x += x
    @render()
  toLeft : (x=100)->
    if @x>0
      @x -= x
      @render()
  save : ->
    canvas = document.createElement('canvas')
    canvas = new fabric.Canvas(canvas);
    canvas.setWidth @options.max_width
    canvas.setHeight @options.max_height
    tmp_canvas = @canvas
    @canvas = canvas
    @drawguideline = false
    @render()
    @drawguideline = true
    svg = @canvas.toSVG()
    @canvas = tmp_canvas
    a = document.createElement('a')
    a.download = 'sample.svg'
    a.type = 'image/svg+xml'
    blob = new Blob([svg], {"type": "image/svg+xml"})
    a.href = (window.URL || webkitURL).createObjectURL(blob)
    a.click()