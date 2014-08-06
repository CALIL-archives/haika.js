log = (obj) ->
  try
    console.log obj

app = 
  id         : null
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
  bgimg_data: null
  bgimg_width: null
  bgimg_height: null
  fillColor: "#CFE2F3"
  strokeColor: "#000000"
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
      lon      : 0
      lat      : 0
      angle    : 0
      
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
      @load_bg_from_url(@options.bgurl)
    @render()
    setTimeout =>
      @load()
      if @options.callback?
        @options.callback()
    , 500
    @event()
  event : ->
    @canvas.on('object:selected', (e)=>
#        log 'selected'
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
      editor_change()
      @set_propety_panel()
    @canvas.on 'object:scaling', (e) =>
      object = e.target
      if object.__resizeShelf?
        object.__resizeShelf()
    @canvas.on 'object:modified', (e)=>
#        log 'modified'
        object = e.target
        if object.__modifiedShelf?
          object.__modifiedShelf()
        @set_propety_panel()
    $(window).on 'beforeunload', (event)=>
      @render()
      @save()
      return
  load_bg_from_url : (url) ->
    @options.bgurl = url
    fabric.Image.fromURL url, (img)=>
      log img
      @bgimg = img
      @bgimg_width  = img.width
      @bgimg_height = img.height
      @render()
  load_bg : (file) ->
    reader = new FileReader()
    reader.onload = (e) =>
#      log e.currentTarget.result
      @bgimg_data = e.currentTarget.result
      @set_bg()
      @save()
    reader.readAsDataURL file
  set_bg: ->
    if not @bgimg_data
      return
    img = new Image()
    img.src = @bgimg_data
    @bgimg = new fabric.Image(img)
    @bgimg_width = img.width
    @bgimg_height = img.width
    @render()
    if @options.callback?
      @options.callback()
    
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
    schema = object.constructor.prototype.getJsonSchema()
    for key of schema.properties
      props.push(key)
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
    else if object.type=='wall'
      state = 'wall'
    else if object.type=='floor'
      state = 'floor'
    else
      state = 'beacon'
    @state = state
    $('.nav a.'+@state).tab('show')
  bind : (func, do_active=true)->
    object = @canvas.getActiveObject()
    if object
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
      @__remove(object)
    , false)
  __remove : (object)->
    @canvas.remove(object)
    count = @findbyid(object.id)
    @objects.splice(count, 1)
    return object
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
  get_class : (classname)->
    if classname=='shelf'
      return fabric.Shelf
    else if classname=='curved_shelf'
      return fabric.curvedShelf
    else if classname=='beacon'
      return fabric.Beacon
    else if classname=='wall'
      return fabric.Wall
    else if classname=='floor'
      return fabric.Floor
    else
      return fabric.Shelf
  render : ->
#    log 'render'
    #オブジェクトをクリア
    @canvas.renderOnAddRemove=false
    @unselect()
    @canvas._objects.length = 0;
    #@canvas.clear()
    beacons = []
    shelfs  = []
    walls = []
    floors = []
    for o in @objects
      if o.type=='beacon'
        beacons.push(o)
      if o.type=='wall'
        walls.push(o)
      if o.type=='floor'
        floors.push(o)
      if o.type.match(/shelf$/)
        shelfs.push(o)
    if app.state!='floor'
      for o in floors
        @render_object(o)
    for o in walls
      @render_object(o)
    if app.state=='floor'
      for o in floors
        @render_object(o)
    for o in shelfs
      @render_object(o)
    for o in beacons
      @render_object(o)
    @render_bg()
    @canvas.renderAll()
    @canvas.renderOnAddRemove=true
    @debug()
  render_object : (o)->
    klass = @get_class(o.type)
    object = new klass()
    if o.type.match(/shelf$/)
      object.side  = o.side
      object.count = o.count
      object.eachWidth = o.eachWidth
      object.eachHeight = o.eachHeight
    # layer
    object.selectable = (o.type.match(@state))
    if not o.type.match(@state)
      object.opacity = 0.5
    object.id     = o.id
    object.scaleX = object.scaleY = 1
    if o.type=='wall' or o.type=='floor'
      object.width_scale = o.width_scale
      object.height_scale = o.height_scale
    object.width  = object.__width()
    object.height = object.__height()
    object.top    = @transformTopY_cm2px(o.top_cm)
    object.left   = @transformLeftX_cm2px(o.left_cm)
    object.top_cm = o.top_cm
    object.left_cm= o.left_cm
    object.angle  = o.angle
    object.originX = 'center'
    object.originY = 'center'
    if o.type=='beacon'
      object.fill = "#000000"
      object.hasControls = false
      object.padding = 10
      object.borderColor = "#0000ee"
    else if o.type=='wall'
      object.fill = "#000000"
      object.borderColor = "#000000"
    else if o.type=='floor'
      object.fill = ""
      object.borderColor = "#000000"
    else
      object.borderColor = "#000000"
      object.fill = o.fill
      object.padding = 0
    object.stroke = o.stroke
    object.transparentCorners = false
    object.cornerColor = "#488BD4"
    object.borderOpacityWhenMoving = 0.8
    object.cornerSize = 10
    schema = object.constructor.prototype.getJsonSchema()
    for key of schema.properties
      object[key] = o[key]
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
    $('#canvas_bgopacity').val(@options.bgopacity)
    $('#canvas_lon').val(@options.lon)
    $('#canvas_lat').val(@options.lat)
    $('#canvas_angle').val(@options.angle)
  get_move : (event)->
    return if event.shiftKey then 10 else 1
  up : (event)->
    object = @canvas.getActiveObject()
    if object
      object.top = object.top - @get_move(event)
      @canvas.renderAll()
  down : (event)->
    object = @canvas.getActiveObject()
    if object
      object.top = object.top + @get_move(event)
      @canvas.renderAll()
  left : (event)->
    object = @canvas.getActiveObject()
    if object
      object.left = object.left - @get_move(event)
      @canvas.renderAll()
  right : (event)->
    object = @canvas.getActiveObject()
    if object
      object.left = object.left + @get_move(event)
      @canvas.renderAll()
  alignLeft : ()->
    group = @canvas.getActiveGroup()
    if group._objects
      left = 0
      for object in group._objects
        bound = object.getBoundingRect()
        left = Math.min(bound.left, left)
      for object in group._objects
        bound = object.getBoundingRect()
        object.left = left + bound.width/2
      @save()
      @canvas.renderAll()
  alignRight : ()->
    group = @canvas.getActiveGroup()
    if group._objects
      left = 0
      for object in group._objects
        bound = object.getBoundingRect()
        left = Math.max(bound.left+bound.width, left)
      for object in group._objects
        bound = object.getBoundingRect()
        object.left = left - bound.width/2
      @canvas.renderAll()
  alignCenter : ()->
    group = @canvas.getActiveGroup()
    if group._objects
      for object in group._objects
        object.left = 0
      @canvas.renderAll()
  alignTop : ()->
    group = @canvas.getActiveGroup()
    if group._objects
      top = 0
      for object in group._objects
        bound = object.getBoundingRect()
        top = Math.min(bound.top, top)
      for object in group._objects
        bound = object.getBoundingRect()
        object.top = top + bound.height/2
      @canvas.renderAll()
  alignBottom : ()->
    group = @canvas.getActiveGroup()
    if group._objects
      top = 0
      for object in group._objects
        bound = object.getBoundingRect()
        top = Math.max(bound.top+bound.height, top)
      for object in group._objects
        bound = object.getBoundingRect()
        object.top = top - bound.height/2
      @canvas.renderAll()
  alignVcenter : ()->
    group = @canvas.getActiveGroup()
    if group._objects
      for object in group._objects
        object.top = 0
      @canvas.renderAll()
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
  is_local : ->
    return location.protocol=='file:' or location.port!=''
  load : ()->
    if location.hash!='' and location.hash.length!=7
      location.hash = sprintf('%06d',location.hash.split('#')[1])
      return
    # ローカルか？
    if @is_local()
      data =
        canvas : JSON.parse(localStorage.getItem('canvas'))
        geojson : JSON.parse(localStorage.getItem('geojson'))
      log data
      @load_render(data)
      return
    # location.hashにIDはあるか？
    if location.hash!=''
      @id = location.hash.split('#')[1]
      # サーバーからロード
      @load_server()
    else
      # 新規IDの取得, ハッシュに設定
      @get_haika_id()
  set_hashchange : ()->
    # ハッシュ変更時に再読み込み
    $(window).bind "hashchange", ->
      location.reload()
  load_render : (data)->
    log data
    canvas = data.canvas
    geojson = data.geojson
    if canvas
      log canvas
      @state   = canvas.state
      $('.nav a.'+@state).tab('show')
      @scale   = canvas.scale
      $('.zoom').html((@scale*100).toFixed(0)+'%')
      @centerX = canvas.centerX
      @centerY = canvas.centerY
      @bgimg_data = canvas.bgimg_data
      @options.bgscale = if canvas.bgscale then canvas.bgscale else 4.425
      @options.bgopacity = canvas.bgopacity
      if @is_local()
        @set_bg()
      else
        if canvas.bgurl?
          @load_bg_from_url(canvas.bgurl)
      if canvas.lon?
        @options.lon = parseFloat(canvas.lon)
        @options.lat = parseFloat(canvas.lat)
        @options.angle = parseInt(canvas.angle)
    if geojson and geojson.features.length>0
      for object in geojson.features
        if object.properties.id>@last_id
          @last_id = object.properties.id
        klass = @get_class(object.properties.type)
        shape = new klass(
          id: object.properties.id
          top: @transformTopY_cm2px(object.properties.top_cm)
          left: @transformLeftX_cm2px(object.properties.left_cm)
          top_cm: object.properties.top_cm
          left_cm: object.properties.left_cm
          fill: object.properties.fill
          stroke: object.properties.stroke
          angle: object.properties.angle
        )
        schema = shape.constructor.prototype.getJsonSchema()
        for key of schema.properties
#          log key
#          log object.properties[key]
          shape[key] = object.properties[key]
        @add(shape)
    @render()
  get_haika_id : ->
    url = '/haika_store/index.php'
    $.ajax
      url: url
      type: "GET"
      cache : false
      dataType: "json"
      error: ()->
      success: (data)=>
        location.hash = data.id
        @id = data.id
        @set_hashchange()
  load_server : ->
    url = """/haika_store/data/#{@id}.json"""
    $.ajax
      url: url
      type: "GET"
      cache : false
      dataType: "text"
      error: ()=>
        alert 'load error'
      success: (data)=>
        log data
        try
          data = JSON.parse(data)
        catch
          alert 'parse error'
          $(window).off 'beforeunload'
          location.href = """/haika_store/data/#{@id}.json"""
        @load_render(data)
        @set_hashchange()
  get_canvas_data : ->
    return {
      state : @state
      scale : @scale
      centerX : @centerX
      centerY : @centerY
      bgimg_data: @bgimg_data
      bgurl: @options.bgurl
      bgscale : @options.bgscale
      bgopacity : @options.bgopacity
      lon : @options.lon
      lat : @options.lat
      angle: @options.angle
    }
  save_local : ->
    canvas = @get_canvas_data()
    localStorage.setItem('canvas', JSON.stringify(canvas))
#    localStorage.setItem('app_data', JSON.stringify(@objects))
    localStorage.setItem('geojson', JSON.stringify(@toGeoJSON(), null, 4))
  save_server : ->
    param = 
      canvas : @get_canvas_data()
      geojson: @toGeoJSON()
    param = JSON.stringify(param)
    log param
    data =
      ext: 'json'
      id  : @id
      data: param
#    log data
    url = '/haika_store/index.php'
    $.ajax
      url: url
      type: "POST"
      data: data
      dataType: "json"
      error: ()->
      success: (data)=>
        log data
    @save_geojson()
  # geojsonの保存
  save_geojson : ->
    geojson = @create_geojson()
    param = JSON.stringify(geojson)
    data =
      ext: 'geojson'
      id  : @id
      data: param
#    log data
    url = '/haika_store/index.php'
    $.ajax
      url: url
      type: "POST"
      data: data
      dataType: "json"
      error: ()->
      success: (data) >
        log data
        log 'geojson save'
  save : ->
    log 'save'
    for object in @canvas.getObjects()
      @save_prop(object)
    @save_local()
    if not @is_local()
      @save_server()
  save_prop : (object, group=false)->
#    log object.__proto__.getJsonSchema()
#    log object.constructor.prototype.getJsonSchema()
    count = @findbyid(object.id)
    @objects[count].id      = object.id
    @objects[count].type    = object.type
    @objects[count].top_cm  = @transformTopY_px2cm(object.top)
    object.top_cm           = @objects[count].top_cm
    @objects[count].left_cm = @transformLeftX_px2cm(object.left)
    object.left_cm          = @objects[count].left_cm
    @objects[count].scaleX  = object.scaleX / @scale
    @objects[count].scaleY  = object.scaleY / @scale
    @objects[count].angle   = object.angle
    @objects[count].fill    = object.fill
    @objects[count].stroke  = object.stroke
    schema = object.constructor.prototype.getJsonSchema()
    for key of schema.properties
#      log key
#        log object[key]
      @objects[count][key] = object[key]
#      @objects[count].count = object.count
#      @objects[count].side  = object.side
#      @objects[count].eachWidth  = object.eachWidth
#      @objects[count].eachHeight = object.eachHeight
  toGeoJSON : ->
    features = []
    for object in @canvas.getObjects()
      geojson = object.toGeoJSON()
      features.push(geojson)
    data = 
      "type": "FeatureCollection"
      "features": features
    return data
  getGeoJSON : ->
    @unselect()
    @render()
    geojson = @translateGeoJSON()
    localStorage.setItem('geojson', JSON.stringify(geojson))
    log geojson
    $(window).off 'beforeunload'
    location.href = 'map2.html'
  # geojsonの作成 座標変換
  create_geojson : ->
    geojson = @translateGeoJSON()
    features = []
    if geojson and geojson.features.length>0
      for object in geojson.features
        # 結合前の床は省く
        if object.properties.type!='floor'
          coordinates = []
          for geometry in object.geometry.coordinates[0]
            x = geometry[0]
            y = geometry[1]
            coordinate = ol.proj.transform([x,y], "EPSG:3857", "EPSG:4326")
            coordinates.push(coordinate)
          # 結合した床面をfloorに戻す
          if object.properties.type=='merge_floor'
            object.properties.type='floor'
          data =
            "type": "Feature"
            "geometry":
              "type": "Polygon",
              "coordinates": [
                coordinates
              ]
            "properties": object.properties
          features.push(data)
    EPSG3857_geojson =
      "type": "FeatureCollection"
      "features": features
    return EPSG3857_geojson
  # geojsonの回転
  translateGeoJSON : ->
    geojson = @toGeoJSON()
    geojson = @mergeGeoJson(geojson)
    features = []
    for object in geojson.features
      mapCenter = proj4("EPSG:4326", "EPSG:3857", [@options.lon, @options.lat])
      if mapCenter
        coordinates = []
        for geometry in object.geometry.coordinates[0]
          x = geometry[0]
          y = geometry[1]
          # 回転の反映
          new_coordinate =  fabric.util.rotatePoint(new fabric.Point(x, y), new fabric.Point(0, 0), fabric.util.degreesToRadians(-@options.angle))
          coordinate = [mapCenter[0]+new_coordinate.x, mapCenter[1]+new_coordinate.y]
          coordinates.push(coordinate)
        object.geometry.coordinates = [coordinates]
      features.push(object)
    geojson.features = features
    return geojson
  # geojson床オブジェクトのマージ
  mergeGeoJson : (geojson) ->
    paths = []
    if geojson and geojson.features.length>0
      for object in geojson.features
        if object.properties.type=='floor'
          path = []
          log object.geometry.coordinates[0]
          for geometry in object.geometry.coordinates[0]
            p = {
              X: geometry[0]
              Y: geometry[1]
            }
            path.push(p)
          paths.push([path])
      log paths

      cpr = new ClipperLib.Clipper()
      for path in paths
        cpr.AddPaths path, ClipperLib.PolyType.ptSubject, true # true means closed path
      solution_paths = new ClipperLib.Paths()
      succeeded = cpr.Execute(ClipperLib.ClipType.ctUnion, solution_paths, ClipperLib.PolyFillType.pftNonZero, ClipperLib.PolyFillType.pftNonZero)

      log solution_paths
      for path in solution_paths
        coordinates = []
        first = true
        for p in path
          if first
            first_coordinates = [p.X, p.Y]
            first = false
          coordinates.push [p.X, p.Y]
        coordinates.push first_coordinates

        geojson.features.push(
          "type": "Feature"
          "geometry":
            "type": "Polygon",
            "coordinates": [coordinates]
          "properties":
            "type": "merge_floor"
        )

    return geojson
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
#    log 'set_propety_panel'
    $('.canvas_panel, .object_panel, .group_panel').hide()
    object = @canvas.getActiveObject()
    if object and object.getJsonSchema?
      editor.schema = object.getJsonSchema()
      # Set the value
      properties = {}
      for key of editor.schema.properties
        if editor.schema.properties[key].type=='integer'
          value = parseInt(object[key]).toFixed(0)
        else
          value = object[key]
        properties[key] = value
      editor.setValue properties
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