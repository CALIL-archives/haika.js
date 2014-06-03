log = (obj) ->
  try
    console.log obj
SCALE_FACTOR = 2

app = 
  width      : 800
  height     : 800
  centerX    : 0
  centerY    : 0
  scale      : 10
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
    canvas = new fabric.Canvas(@options.canvas)
    canvas.setWidth(@options.canvas_width)
    $('#canvas_width').val(@options.canvas_width)
    canvas.setHeight(@options.canvas_height)
    $('#canvas_height').val(@options.canvas_height)
    initAligningGuidelines(canvas)
    initCenteringGuidelines(canvas)
    @canvas = canvas
    #@canvas.centeredRotation = true
    if @options.bgurl
      fabric.Image.fromURL @options.bgurl, (img)=>
        @bgimg = img
        @bgimg_width  = img.width
        @bgimg_height = img.height
    @canvas.on('object:selected', (e)=>
        object = e.target
        if object._objects?
          object.lockScalingX  = true
          object.lockScalingY  = true
        #else
        #  object.lockScalingY  = true
    )
    @canvas.on('before:selection:cleared', (e)=>
      object = e.target
      log 'before_unselect'
      @canvas.deactivateAll().renderAll()
      if object._objects?
        group = object
        objects = object._objects
        for object in objects
          @save_prop(object, group)
      else
        @save_prop(object)
    )
    @canvas.on 'object:scaling', (e) =>
      object = e.target
      if object.__resizeShelf?
        object.__resizeShelf()

    @canvas.on('object:modified', (e)=>
        object = e.target
        log 'modified'
        if object.__modifiedShelf?
          object.__modifiedShelf()
    )

  save_prop : (object, group=false)->
      count = @match(object)
      if count!=null
        @objects[count].top_cm  = @transformY_px2cm(object.top)
        @objects[count].left_cm = @transformX_px2cm(object.left)
        scaleX = if group then group.scaleX else 0
        scaleY = if group then group.scaleY else 0
        @objects[count].scaleX = object.scaleX / @scale * scaleX
        @objects[count].scaleY = object.scaleY / @scale * scaleY
        @objects[count].angle  = object.angle
  add : (object)->
    object.__id = @object_id
    @object_id += 1
    o = 
      object : object 
    props = 'width height scaleX scaleY left top angle fill stroke'.split(' ')
    for prop in props
      if prop=='top'
        o.top_cm = @transformX_px2cm(object.top)
        continue
      if prop=='left'
        o.left_cm = @transformY_px2cm(object.left)
        continue
      o[prop] = object[prop]
    @objects.push(o)
    return o
  bind : (func)->
    object = @canvas.getActiveObject()
    if object
      func(object)
    group = @canvas.getActiveGroup()
    if group
      objects = group._objects
      @canvas._activeObject = null
      @canvas.setActiveGroup(group.setCoords()).renderAll()
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
  transformX_cm2px : (cm)->
    # centerX(cm) => px
    return @canvas.getWidth()/2+(@centerX-cm)*@scale
    #return @centerX * @scale + @canvas.getWidth()  / 2 - cm * @scale
  transformY_cm2px : (cm)->
    return @canvas.getHeight()/2+(@centerY-cm)*@scale
    #return @centerY * @scale + @canvas.getHeight() / 2 - cm * @scale
  transformX_px2cm : (px)->
    # left(px) => x(cm)
    #return (px+@centerX)/@scale-@canvas.getWidth()/2
    #return @canvas.getWidth() / 2 - (px + @centerX) * @scale
    return @centerX - (px - @canvas.getWidth() / 2) / @scale
  transformY_px2cm : (px)->
    #return (px+@centerY)/@scale-@canvas.getHeight()/2
    #return @canvas.getHeight() / 2 - (px + @centerY) * @scale 
    return @centerY - (px - @canvas.getHeight() / 2) / @scale
  render : ->
    object = app.canvas.getActiveObject()
    if not object
      object = app.canvas.getActiveGroup()
    if object
      @canvas.fire('before:selection:cleared', { target: object })
      @canvas.fire('selection:cleared', { target: object })
    if @objects.length<=0
      return
    @canvas.clear()
    for o of @objects
      scaleX  = @objects[o].scaleX
      scaleY  = @objects[o].scaleY
      left_cm = @objects[o].left_cm
      top_cm  = @objects[o].top_cm
      angle   = @objects[o].angle
      tempScaleX = scaleX * @scale
      tempScaleY = scaleY * @scale
      tempLeft   = @transformX_cm2px(left_cm)
      tempTop    = @transformY_cm2px(top_cm)
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
      @bgimg.left   = -(@centerX*@scale)
      @bgimg.top    = -(@centerY*@scale)
      @bgimg.width  = @bgimg_width*@options.bgscale*@scale
      @bgimg.height = @bgimg_height*@options.bgscale*@scale
      @bgimg.opacity= @options.bgopacity
      @canvas.setBackgroundImage @bgimg, @canvas.renderAll.bind(@canvas)
    @debug()
  #デバッグパネル
  debug : ->
    $('#canvas_width').val(@canvas.getWidth())
    $('#canvas_height').val(@canvas.getHeight())
    $('#canvas_centerX').val(@centerX)
    $('#canvas_centerY').val(@centerY)

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
    @render()
    $('.zoom').html((@scale*100).toFixed(0)+'%')
  zoomOut : ->
    if @scale<=0.1
      return
    @scale -= 0.1
    @scale = (@scale*100).toFixed(0)/100
    @render()
    $('.zoom').html((@scale*100).toFixed(0)+'%')
  zoomReset : ->
    @scale = 1
    @render()
    $('.zoom').html('100%')
  toTop :(y=100) ->
    @centerY += y
    @render()
  toBottom : (y=100)->
    @centerY -= y
    @render()
  toRight : (x=100)->
    @centerX -= x
    @render()
  toLeft : (x=100)->
    @centerX += x
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