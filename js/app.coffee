log = (obj) ->
  try
    console.log obj

app = 
  state      : 'shelf'
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


    canvas._getActionFromCorner = (target, corner) ->
      action = 'drag'
      if corner
        if corner == 'ml' || corner == 'mr' || corner == 'tr' || corner == 'tl' || corner == 'bl' || corner == 'br'
          action='scaleX'
        else if corner == 'mt' || corner == 'mb'
          action='scaleY'
        else if corner == 'mtr'
          action='rotate'
      return action

    #背景にグリッドラインを追加するためにオーバーライド
    canvas._renderBackground = (ctx) ->
      if @backgroundColor
        ctx.fillStyle = (if @backgroundColor.toLive then @backgroundColor.toLive(ctx) else @backgroundColor)
        ctx.fillRect @backgroundColor.offsetX or 0, @backgroundColor.offsetY or 0, @width, @height
      ctx.mozImageSmoothingEnabled = false
      if @backgroundImage
        @backgroundImage.render ctx
        #ctx.drawImage(@backgroundImage._element,0,0,@width,@height)
      ctx.mozImageSmoothingEnabled = true
      fabric.drawGridLines(ctx)

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
    @render()
    setTimeout =>
      @load()
    , 500
    @canvas.on('object:selected', (e)=>
        #log 'selected'
        object = e.target
        if object._objects?
          object.lockScalingX  = true
          object.lockScalingY  = true
        #else
        #  object.lockScalingY  = true
        @save()
        @set_propety_panel()
    )
    @canvas.on('before:selection:cleared', (e)=>
      #log 'before_unselect'
      object = e.target
      @canvas.deactivateAll().renderAll()
      @save()
      @set_propety_panel()
    )
    @canvas.on 'object:scaling', (e) =>
      object = e.target
      if object.__resizeShelf?
        object.__resizeShelf()

    @canvas.on('object:modified', (e)=>
        #log 'modified'
        object = e.target
        if object.__modifiedShelf?
          object.__modifiedShelf()
    )
    $(window).on 'beforeunload', (event)=>
      @render()
      @save()
      return
  last_id : 0
  get_id : ->
    if @objects.length==0
      return 0
    @last_id += 1
    return @last_id
  add : (object)->
    # new object
    if object.id==''
      object.id = @get_id()
    o =
      id : object.id
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
    if object.type.match(/shelf$/)
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
    #layer tab
    if object.type.match(/shelf$/)
      state = 'shelf'
    else
      state = 'beacon'
    @state = state
    $('.nav a.'+@state).tab('show')
    return o.id
  load : ()->
    objects = JSON.parse(localStorage.getItem('app_data'))
#    log objects
    if objects
      for object in objects
        if object.id>@last_id
          @last_id = object.id
        if object.type=='shelf'
          klass = fabric.Shelf
        else if object.type=='curved_shelf'
          klass = fabric.curvedShelf
        else if object.type=='beacon'
          klass = fabric.Beacon
        else
          continue
        shape = new klass(
          id: object.id
          count: object.count
          side: object.side
          top: app.transformX_cm2px(object.top_cm)
          left: app.transformY_cm2px(object.left_cm)
          fill: "#CFE2F3"
          stroke: "#000000"
          angle: object.angle
        )
        @add(shape)
    canvas = JSON.parse(localStorage.getItem('canvas'))
    if canvas
#      log canvas
      @scale   = canvas.scale
      $('.zoom').html((@scale*100).toFixed(0)+'%')
      @centerX = canvas.centerX
      @centerY = canvas.centerY
    @render()
  findbyid : (id)->
    count = null
    $(@objects).each (i, obj)->
      if obj.id==id
        count = i
    return count
  local_save : ->
    canvas = 
      scale : @scale
      centerX : @centerX
      centerY : @centerY
    localStorage.setItem('canvas', JSON.stringify(canvas))
    localStorage.setItem('app_data', JSON.stringify(@objects))
  save : ->
    for object in @canvas.getObjects()
      @save_prop(object)
    @local_save()
  save_prop : (object, group=false)->
    count = @findbyid(object.id)
    @objects[count].id      = object.id
    @objects[count].type    = object.type
    @objects[count].top_cm  = @transformY_px2cm(object.top)
    @objects[count].left_cm = @transformX_px2cm(object.left)
    @objects[count].scaleX  = object.scaleX / @scale
    @objects[count].scaleY  = object.scaleY / @scale
    @objects[count].angle   = object.angle

    if object.type.match(/shelf$/)
      @objects[count].count = object.count
      @objects[count].side  = object.side

  bind : (func)->
    object = @canvas.getActiveObject()
    if object
      func(object)
    group = @canvas.getActiveGroup()
    if group
      objects = group._objects
#      for object in objects
#        func(object)
      #@canvas._activeObject = null
      #@canvas.setActiveGroup(group.setCoords()).renderAll()
  remove : ->
    @bind (object)=>
      @canvas.remove(object)
      count = @findbyid(object.id)
      @objects.splice(count, 1)
  bringToFront : ->
    @bind (object)=>
      count = @findbyid(object.id)
      object.bringToFront()
      obj = @objects[count]
      @objects.splice(count, 1)
      @objects.push(obj)
  add_active : (object, top, left)->
    @save()
    object.id = @get_id()
    id = @add(object)
    @render()
    $(@canvas.getObjects()).each (i, obj)=>
      if obj.id==id
        log id
        obj.set(
          top  : top
          left : left
        )
#        @canvas.renderAll();
#        @render()
        @canvas.setActiveObject(obj)
  duplicate : ->
    @bind (object)=>
      @add_active(object, object.top+10,object.left+10)
  clipboard : []
  clipboard_count : 1
  copy  : ->
    @clipboard = []
    @clipboard_count = 1
    @bind (object)=>
      object.top_cm = @transformY_px2cm(object.top)
      object.left_cm = @transformX_px2cm(object.left)
      @clipboard.push(object)
  paste : ->
    if @clipboard==[]
      return
    for object in @clipboard
      object.top = @transformY_cm2px(object.top_cm)
      object.left = @transformX_cm2px(object.left_cm)
      top = object.top+@clipboard_count*object.height/2
      left = object.left+@clipboard_count*object.width/10
      @add_active(object, top, left)
    @clipboard_count += 1
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
#    log 'render'
    @unselect()
    @canvas.renderOnAddRemove=false
    @canvas.clear()
    for o in @objects
      if o.type=='shelf'
        object = new fabric.Shelf()
        object.side  = o.side
        object.count = o.count
      if o.type=='curved_shelf'
        object = new fabric.curvedShelf()
        object.side  = o.side
        object.count = o.count
      if o.type=='beacon'
        object = new fabric.Beacon()
      # layer
      object.selectable = (o.type.match(@state))
      if not o.type.match(@state)
        object.opacity = 0.5
      object.id     = o.id
      object.scaleX = 1
      object.scaleY = 1
      object.width  = object.__width()
      object.height = object.__height()
      object.left   = @transformX_cm2px(o.left_cm)
      object.top    = @transformY_cm2px(o.top_cm)
      if o.angle > 0
        object.angle  = o.angle
      object.originX = 'center'
      object.originY = 'center'
      if o.type=='beacon'
        object.fill = "#000000"
        object.hasControls = false
        object.padding = 10
        object.borderColor = "#0000ee"
      else
        object.borderColor = "#000000"
        object.fill = "#CFE2F3"
        object.padding = 0
      object.stroke = "#000000"
      object.transparentCorners = false
      object.cornerColor = "#488BD4"
      object.borderOpacityWhenMoving = 0.8
      object.cornerSize = 10
      object.setCoords()
      @canvas.add(object)
    @render_bg()
    @canvas.renderAll()
    @canvas.renderOnAddRemove=true
    @debug()
  render_bg : ->
    if @bgimg
      @bgimg.left    = Math.floor( @canvas.getWidth()/2 + (-@bgimg_width*@options.bgscale/2 + @centerX) * @scale )
      @bgimg.top     = Math.floor( @canvas.getHeight()/2 + (-@bgimg_height*@options.bgscale/2 + @centerY) * @scale )
      @bgimg.width   = Math.floor( @bgimg_width*@options.bgscale*@scale  )
      @bgimg.height  = Math.floor( @bgimg_height*@options.bgscale*@scale )
      @bgimg.opacity = @options.bgopacity
      @canvas.setBackgroundImage @bgimg

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
#    @scale += 0.1
    prev_scale = @scale
    @scale = @scale+Math.pow(@scale+1, 2)/20
    if @scale>=4
      @scale = 4
    if prev_scale<1 and @scale > 1
      @scale = 1
    @scale = (@scale*100).toFixed(0)/100
    @render()
    $('.zoom').html((@scale*100).toFixed(0)+'%')
  zoomOut : ->
    @unselect()
#    @scale -= 0.1
    prev_scale = @scale
    @scale = @scale-Math.pow(@scale+1, 2)/20
    if @scale<=0.05
      @scale = 0.05
    if prev_scale>1 and @scale < 1
      @scale = 1
    @scale = (@scale*100).toFixed(0)/100
    @render()
    $('.zoom').html((@scale*100).toFixed(0)+'%')
  zoomReset : ->
    @unselect()
    @scale = 1
    @render()
    $('.zoom').html('100%')
#  toTop :(y=100) ->
#    @unselect()
#    @centerY += y
#    @render()
#  toBottom : (y=100)->
#    @unselect()
#    @centerY -= y
#    @render()
#  toRight : (x=100)->
#    @unselect()
#    @centerX -= x
#    @render()
#  toLeft : (x=100)->
#    @unselect()
#    @centerX += x
#    @render()
  toGeoJSON : ->
    features = []
    for object in @canvas.getObjects()
      features.push(object.toGeoJSON())
    data = 
      "type": "FeatureCollection"
      "features": features
    return JSON.stringify(data, null, 4)
  getGeoJSON : ->
    @unselect()
#    canvas = document.createElement('canvas')
#    canvas = new fabric.Canvas(canvas);
#    canvas.setWidth @options.max_width
#    canvas.setHeight @options.max_height
#    tmp_canvas = @canvas
#    tmp_scale = @scale
#    @canvas = canvas
#    @scale = 1
    @drawguideline = false
    @render()
    @drawguideline = true
    geojson = @toGeoJSON()
#    @canvas = tmp_canvas
#    @scale = tmp_scale
    localStorage.setItem('geojson', JSON.stringify(geojson))
    location.href = 'map.html'
    return
    a = document.createElement('a')
    a.download = 'sample.geojson'
    a.type = 'application/json'
    blob = new Blob([geojson], {"type": "application/json"})
    a.href = (window.URL || webkitURL).createObjectURL(blob)
    a.click()
  getSVG : ->
    @unselect()
    canvas = document.createElement('canvas')
    canvas = new fabric.Canvas(canvas);
    canvas.setWidth @options.max_width
    canvas.setHeight @options.max_height
    tmp_canvas = @canvas
    tmp_scale = @scale
    @canvas = canvas
    @scale = 1
    @drawguideline = false
    @render()
    @drawguideline = true
    svg = @canvas.toSVG()
    @canvas = tmp_canvas
    @scale = tmp_scale
    a = document.createElement('a')
    a.download = 'sample.svg'
    a.type = 'image/svg+xml'
    blob = new Blob([svg], {"type": "image/svg+xml"})
    a.href = (window.URL || webkitURL).createObjectURL(blob)
    a.click()
  set_propety_panel : (object)->
    $('.canvas_panel, .object_panel, .group_panel').hide()
    object = @canvas.getActiveObject()
    if object
      if object.toGeoJSON?
        $('#geojson').val(JSON.stringify(object.toGeoJSON(), null, 4))
      $('.object_panel').show()
      $('#object_id').html(object.id)
      return
    group = @canvas.getActiveGroup()
    if group
      objects = group._objects
      $('#group_count').html(objects.length)
      $('.group_panel').show()
      return
    else
      $('.canvas_panel').show()      
