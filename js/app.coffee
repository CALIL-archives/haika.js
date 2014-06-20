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
    @render()
    setTimeout =>
      @load()
      if options.callback?
        options.callback()
    , 10
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

#    @canvas.on 'selection:created', (e)=>
#      e.target.hasControls = false
    @canvas.on 'before:selection:cleared', (e)=>
#      log 'before:selection:cleared'
      object = e.target
      @canvas.deactivateAll().renderAll()
      @save()
      @set_propety_panel()
    @canvas.on 'object:scaling', (e) =>
      object = e.target
      if object.__resizeShelf?
        object.__resizeShelf()
    @canvas.on 'object:modified', (e)=>
        #log 'modified'
        object = e.target
        if object.__modifiedShelf?
          object.__modifiedShelf()
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
  findbyid : (id)->
    count = null
    $(@objects).each (i, obj)->
      if obj.id==id
        count = i
    return count
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
        o.top_cm = @transformTopY_px2cm(object.top)
        continue
      if prop=='left'
        o.left_cm = @transformLeftX_px2cm(object.left)
        continue
      o[prop] = object[prop]
    @objects.push(o)
    return o.id
  set_state : (object)->
    #layer tab
    if object.type.match(/shelf$/)
      state = 'shelf'
    else
      state = 'beacon'
    @state = state
    $('.nav a.'+@state).tab('show')
  bind : (func, do_active=true)->
    object = @canvas.getActiveObject()
    if object
      log object.top
      new_id = func(object)
      if new_id and do_active
        $(@canvas.getObjects()).each (i, obj)=>
          if obj.id==new_id
            @canvas.setActiveObject(obj)
    group = @canvas.getActiveGroup()
    if group
      new_ids = []
      for object in group.getObjects()
        new_id = func(object)
        new_ids.push(new_id)
      if do_active
        @active_group(new_ids)
      else
        @render()
  active_group : (new_ids)->
    new_objects = []
    for object in @canvas.getObjects()
      for new_id in new_ids
        if object.id==new_id
          new_objects.push(object)
    new_objects = new_objects.map((o) ->
      o.set "active", true
    )
    group = new fabric.Group(new_objects,
      originX: "center"
      originY: "center"
    )
    @canvas._activeObject = null
    @canvas.setActiveGroup(group.setCoords()).renderAll()
  remove : ->
    @bind((object)=>
      @canvas.remove(object)
      count = @findbyid(object.id)
      @objects.splice(count, 1)
    , false)
  bringToFront : ->
    @bind (object)=>
      count = @findbyid(object.id)
      object.bringToFront()
      obj = @objects[count]
      @objects.splice(count, 1)
      @objects.push(obj)
      return obj.id
  add_active : (object, top, left)->
    @save()
    object.id = @get_id()
    object.top  = top
    object.left = left
    new_id = @add(object)
    @render()
    return new_id
  duplicate : ->
    @bind (object)=>
      @canvas.discardActiveGroup()
      o = fabric.util.object.clone(object)
      new_id = @add_active(o, o.top+10,o.left+10)
      return new_id
  clipboard : []
  clipboard_count : 1
  copy  : ->
    @clipboard = []
    @clipboard_count = 1
    @bind (object)=>
      @clipboard.push(object)
    , false
  paste : ->
    if @clipboard.length<=0
      return
    if @clipboard.length==1
      new_id = @__paste(@clipboard[0])
      $(@canvas.getObjects()).each (i, obj)=>
        if obj.id==new_id
          @canvas.setActiveObject(obj)
    else
      new_ids = []
      for object in @clipboard
        new_id = @__paste(object)
        new_ids.push(new_id)
      @active_group(new_ids)
    @clipboard_count += 1
  __paste : (object)->
    o = fabric.util.object.clone(object)
    top = o.top+@clipboard_count*o.height/2
    left = o.left+@clipboard_count*o.width/10
    new_id = @add_active(o, top, left)
    return new_id
  select_all : ()->
    @canvas.discardActiveGroup()
    objects = @canvas.getObjects().map((o) ->
      o.set "active", true
    )
    group = new fabric.Group(objects,
      originX: "center"
      originY: "center"
    )
    @canvas._activeObject = null
    @canvas.setActiveGroup(group.setCoords()).renderAll()
  unselect_all : ()->
    @canvas.deactivateAll().renderAll()
  transformLeftX_cm2px : (cm)->
    return @canvas.getWidth()/2+(@centerX-cm)*@scale
  transformTopY_cm2px : (cm)->
    return @canvas.getHeight()/2+(@centerY-cm)*@scale
  transformLeftX_px2cm : (px)->
    return @centerX - (px - @canvas.getWidth() / 2) / @scale
  transformTopY_px2cm : (px)->
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
    #オブジェクトをクリア
    @canvas.renderOnAddRemove=false
    @unselect()
    @canvas._objects.length = 0;
    #@canvas.clear()
    beacons = []
    shelfs  = []
    for o in @objects
      if o.type=='beacon'
        beacons.push(o)
      if o.type.match(/shelf$/)
        shelfs.push(o)
    for o in shelfs
      @render_object(o)
    for o in beacons
      @render_object(o)
    @render_bg()
    @canvas.renderAll()
    @canvas.renderOnAddRemove=true
    @debug()
  render_object : (o)->
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
      object.scaleX = object.scaleY = 1
      object.width  = object.__width()
      object.height = object.__height()
      object.left   = @transformLeftX_cm2px(o.left_cm)
      object.top    = @transformTopY_cm2px(o.top_cm)
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
      @canvas.add(object)
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
  load : ()->
    canvas = JSON.parse(localStorage.getItem('canvas'))
    if canvas
#      log canvas
      @state   = canvas.state
      $('.nav a.'+@state).tab('show')
      @scale   = canvas.scale
      $('.zoom').html((@scale*100).toFixed(0)+'%')
      @centerX = canvas.centerX
      @centerY = canvas.centerY
    geojson = JSON.parse(localStorage.getItem('geojson'))
#    log geojson
    if geojson and geojson.features.length>0
      for object in geojson.features
        if object.properties.id>@last_id
          @last_id = object.properties.id
        if object.properties.type=='shelf'
          klass = fabric.Shelf
        else if object.properties.type=='curved_shelf'
          klass = fabric.curvedShelf
        else if object.properties.type=='beacon'
          klass = fabric.Beacon
        else
          continue
        if object.properties.type.match(/shelf$/)
          w = klass.prototype.__eachWidth() * object.properties.count
          h = klass.prototype.__eachHeight() * object.properties.side
        if object.properties.type=='beacon'
          w = klass.prototype.__width()
          h = klass.prototype.__height()
        x = object.geometry.coordinates[0][0][0]
        y = object.geometry.coordinates[0][0][1]
        x = @transformLeftX_cm2px(x)
        y = @transformTopY_cm2px(y)
        top = y + h / 2
        left = x + w / 2
        shape = new klass(
          id: object.properties.id
          count: object.properties.count
          side: object.properties.side
          top: top
          left: left
          fill: "#CFE2F3"
          stroke: "#000000"
          angle: object.properties.angle
        )
        @add(shape)
    @render()
  local_save : ->
    canvas =
      state : @state
      scale : @scale
      centerX : @centerX
      centerY : @centerY
    localStorage.setItem('canvas', JSON.stringify(canvas))
#    localStorage.setItem('app_data', JSON.stringify(@objects))
    localStorage.setItem('geojson', @toGeoJSON())
  save : ->
    for object in @canvas.getObjects()
      @save_prop(object)
    @local_save()
  save_prop : (object, group=false)->
    count = @findbyid(object.id)
    @objects[count].id      = object.id
    @objects[count].type    = object.type
    @objects[count].top_cm  = @transformTopY_px2cm(object.top)
    @objects[count].left_cm = @transformLeftX_px2cm(object.left)
    @objects[count].scaleX  = object.scaleX / @scale
    @objects[count].scaleY  = object.scaleY / @scale
    @objects[count].angle   = object.angle

    if object.type.match(/shelf$/)
      @objects[count].count = object.count
      @objects[count].side  = object.side
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
    @render()
    geojson = @toGeoJSON()
    localStorage.setItem('geojson', geojson)
    location.href = 'map.html'
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
    @render()
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
