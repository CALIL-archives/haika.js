log = (obj) ->
  try
    console.log obj

app = 
  width      : 800
  height     : 800
  centerX    : 0
  centerY    : 0
  scale      : 1
  objects    : []
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
      scale        : 1
      bgurl    : null
      bgopacity: 1
      bgscale  : 1
      
    @options = $.extend(default_options, options)
    canvas = new fabric.Canvas(@options.canvas, {
      rotationCursor: 'url("img/rotate.cur") 10 10, crosshair'
    })
    canvas.setWidth(@options.canvas_width)
    $('#canvas_width').val(@options.canvas_width)
    canvas.setHeight(@options.canvas_height)
    $('#canvas_height').val(@options.canvas_height)
    initAligningGuidelines(canvas)
    #initCenteringGuidelines(canvas)
    @canvas = canvas
    #@canvas.centeredRotation = true
    @scale = options.scale
    if @options.bgurl
      fabric.Image.fromURL @options.bgurl, (img)=>
        @bgimg = img
        @bgimg_width  = img.width
        @bgimg_height = img.height
    setTimeout =>
      @load()
    , 500
    @canvas.on('object:selected', (e)=>
        object = e.target
        log 'selected'
        if object._objects?
          object.lockScalingX  = true
          object.lockScalingY  = true
        #else
        #  object.lockScalingY  = true
        for object in @canvas.getObjects()
          if object.id?
            @save_prop(object)
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
    $(window).on 'beforeunload', (event)=>
      @render()
      @save()
      return

  add : (object)->
    id = @objects.length
    object.id = id
    o =
      id : id
    @object_id += 1
    props = [
      'type'
      'width'
      'height'
      'scaleX'
      'scaleY'
      'left'
      'top'
      'angle'
      'fill'
      'stroke'
    ]
    if object.type=='shelf'
      props.push('count')
      props.push('side')
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
  load : ()->
    objects = JSON.parse(localStorage.getItem('app_data'))
    log objects
    if objects
      for object in objects
        shelf = new fabric.Shelf(
          count: object.count
          side: object.side
          top: app.transformX_cm2px(object.top_cm)
          left: app.transformY_cm2px(object.left_cm)
          fill: "#CFE2F3"
          stroke: "#000000"
          angle: object.angle
        )
        @add(shelf)
    canvas = JSON.parse(localStorage.getItem('canvas'))
    if canvas
      log canvas
      @scale   = canvas.scale
      $('.zoom').html((@scale*100).toFixed(0)+'%')
      @centerX = canvas.centerX
      @centerY = canvas.centerY
    @render()
  save : ->
    canvas = 
      scale : @scale
      centerX : @centerX
      centerY : @centerY
    localStorage.setItem('canvas', JSON.stringify(canvas))
  save_prop : (object, group=false)->
    log 'object.top:'+object.top
    count = object.id
    @objects[count].type  = object.type
    @objects[count].top_cm  = @transformY_px2cm(object.top)
    @objects[count].left_cm = @transformX_px2cm(object.left)
    @objects[count].scaleX = object.scaleX / @scale
    @objects[count].scaleY = object.scaleY / @scale
    @objects[count].angle  = object.angle
    if object.type=='shelf'
      @objects[count].count = object.count
      @objects[count].side  = object.side
    localStorage.setItem('app_data', JSON.stringify(@objects))

  bind : (func)->
    object = @canvas.getActiveObject()
    if object
      func(object)
    group = @canvas.getActiveGroup()
    if group
      objects = group._objects
      #@canvas._activeObject = null
      #@canvas.setActiveGroup(group.setCoords()).renderAll()
  remove : ->
    @bind (object)=>
      @canvas.remove(object)
      count = object.id
      @objects.splice(count, 1)
  bringToFront : ->
    @bind (object)=>
      count = object.id
      object.bringToFront()
      obj = @objects[count]
      @objects.splice(count, 1)
      @objects.push(obj) 
  transformX_cm2px : (cm)->
    # centerX(cm) => px
    return @canvas.getWidth()/2+(@centerX-cm)*@scale
  transformY_cm2px : (cm)->
    return @canvas.getHeight()/2+(@centerY-cm)*@scale
  transformX_px2cm : (px)->
    # left(px) => x(cm)
    return @centerX - (px - @canvas.getWidth() / 2) / @scale
  transformY_px2cm : (px)->
    return @centerY - (px - @canvas.getHeight() / 2) / @scale
  unselect : ->
    object = app.canvas.getActiveObject()
    if not object
      object = app.canvas.getActiveGroup()
    if object
      @canvas.fire('before:selection:cleared', { target: object })
      @canvas.fire('selection:cleared', { target: object })
  render : ->
    log 'render'
    @unselect()
    @canvas.clear()
    for i of @objects
      log @objects[i].type
      if @objects[i].type=='shelf'
        object = new fabric.Shelf()
        log @objects[i].count
        object.side  = @objects[i].side
        object.count = @objects[i].count
      object.id     = @objects[i].id
      object.scaleX = 1
      object.scaleY = 1
      object.width  = object.__width()
      object.height = object.__height()
      object.left   = @transformX_cm2px(@objects[i].left_cm)
      object.top    = @transformY_cm2px(@objects[i].top_cm)
      if @objects[i].angle > 0
        object.angle  = @objects[i].angle
      object.originX = 'center'
      object.originY = 'center'
      object.fill = "#CFE2F3"
      object.stroke = "#000000"
      object.setCoords()
      @canvas.add(object)
    if @scale==1 and @drawguideline
      fabric.drawGridLines(@canvas)
    @canvas.renderAll()
    @render_bg()
    @debug()
  render_bg : ->
    if @bgimg
      @bgimg.left    = @canvas.getWidth()/2 + (-@bgimg_width*@options.bgscale/2 + @centerX) * @scale
      @bgimg.top     = @canvas.getHeight()/2 + (-@bgimg_height*@options.bgscale/2 + @centerY) * @scale
      @bgimg.width   = @bgimg_width*@options.bgscale*@scale
      @bgimg.height  = @bgimg_height*@options.bgscale*@scale
      @bgimg.opacity = @options.bgopacity
      @canvas.setBackgroundImage @bgimg, @canvas.renderAll.bind(@canvas)
  #debgu pannel
  debug : ->
    $('#canvas_width').val(@canvas.getWidth())
    $('#canvas_height').val(@canvas.getHeight())
    $('#canvas_centerX').val(@centerX)
    $('#canvas_centerY').val(@centerY)
    $('#canvas_bgscale').val(@options.bgscale)

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
    @unselect()
    @scale += 0.1
    @scale = (@scale*100).toFixed(0)/100
    @render()
    $('.zoom').html((@scale*100).toFixed(0)+'%')
  zoomOut : ->
    @unselect()
    if @scale<=0.1
      return
    @scale -= 0.1
    @scale = (@scale*100).toFixed(0)/100
    @render()
    $('.zoom').html((@scale*100).toFixed(0)+'%')
  zoomReset : ->
    @unselect()
    @scale = 1
    @render()
    $('.zoom').html('100%')
  toTop :(y=100) ->
    @unselect()
    @centerY += y
    @render()
  toBottom : (y=100)->
    @unselect()
    @centerY -= y
    @render()
  toRight : (x=100)->
    @unselect()
    @centerX -= x
    @render()
  toLeft : (x=100)->
    @unselect()
    @centerX += x
    @render()
  getSVG : ->
    @unselect()
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