scrollbar_width = $('#vertical-scroller').width()
scrollbar_height = $('#horizontal-scroller').height()
property_panel_width = $('.property_panel').width()

getWidth = ->
  return window.innerWidth - scrollbar_width - property_panel_width - 20

getHeight = ->
  return window.innerHeight - $('.header').height() - scrollbar_height



#背景画像ボタンクリック時
$('#bgimg').change (e)->
  files = e.target.files
  if files.length==0
    return
  if haika.isLocal()
    haika.loadBgFromFile files[0]
  else
    data = new FormData()
    data.append 'id', haika.id
    data.append 'userfile', files[0]
    $.ajax
      url: '/haika_store/upload.php'
      data: data
      cache: false
      contentType: false
      processData: false
      type: 'POST'
      success: (data) ->
#        log data
        url = '/haika_store/image/'+haika.id+'_'+files[0].name
        haika.loadBgFromUrl(url)

# スクロールバーの設定
setScrollbar = ->
  scroll_weight = 5000
  bgimg_width = if haika.bgimg then haika.bgimg_width else 2500
  bgimg_height = if haika.bgimg then haika.bgimg_height else 2500
  maxX = bgimg_width * haika.options.bgscale / 2
  maxY = bgimg_height * haika.options.bgscale / 2
  defaultX =  -((haika.centerX - scroll_weight) / 10000)
  defaultY =  -((haika.centerY - scroll_weight) / 10000)
  new Dragdealer 'horizontal-scroller',
    x: defaultX
    animationCallback: (x, y)->
#      log x
      haika.unselect()
      centerX = x * 10000 - scroll_weight
      if centerX > maxX - haika.canvas.getWidth() / 2
        centerX = maxX - haika.canvas.getWidth() / 2
      if centerX < -maxX + haika.canvas.getWidth() / 2
        centerX = -maxX + haika.canvas.getWidth() / 2
      haika.centerX = -centerX.toFixed(0)
      haika.render()
  new Dragdealer 'vertical-scroller',
    y: defaultY
    horizontal: false,
    vertical: true,
#    yPrecision: 500,
    animationCallback: (x, y)->
      haika.unselect()
      centerY = y * 10000 - scroll_weight
      if centerY > maxY - haika.canvas.getHeight() / 2
        centerY = maxY - haika.canvas.getHeight() / 2
      if centerY < -maxY + haika.canvas.getHeight() / 2
        centerY = -maxY + haika.canvas.getHeight() / 2
      haika.centerY = -centerY.toFixed(0)
      haika.render()
  
haika.init(
  canvas : 'canvas'
  canvas_width : getWidth()
  canvas_height : getHeight()
  scale : 1
  max_width: 10000
  max_height: 10000
  #bgurl  : 'img/meidai2.png'
  #bgurl  : 'img/sample.png'
  bgopacity: 0.2
  bgscale  : 4.425
  callback : setScrollbar
)


# 色の設定
bind = (func, do_active=true)->
  object = haika.canvas.getActiveObject()
  if object
    func(object)
  group = haika.canvas.getActiveGroup()
  if group
    for object in group.getObjects()
      func(object)
$('#fill-color').colorselector(
  callback: (value, color, title)->
    haika.fillColor = color
    bind (object)->
      object.fill = color
    haika.canvas.renderAll()
)
$('#stroke-color').colorselector(
  callback: (value, color, title)->
    haika.strokeColor = color
    bind (object)->
      object.stroke = color
    haika.canvas.renderAll()
)
    

$('.main_container, .canvas_panel').css('width', getWidth())


$('#vertical-scroller, #vertical-scroller .dragdealer').css('height', getHeight())
$('.property_panel').css('height', getHeight()+scrollbar_height)

$(window).resize ->
  haika.canvas.setWidth(getWidth())
  haika.canvas.setHeight(getHeight())
  $('.main_container, .canvas_panel').css('width', getWidth())
  $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', getHeight())
  $('.property_panel').css('height', getHeight()+scrollbar_height)
  haika.render()

# オブジェクトの追加
add = (val)->
  log val
  klass = haika.getClass(val.type)
  object = new klass(
    top: haika.transformTopY_cm2px(haika.centerY)
    left: haika.transformLeftX_cm2px(haika.centerX)
    fill: haika.fillColor
    stroke: haika.strokeColor
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
  id = haika.add(object)
  haika.setState(object)
  haika.render()
  undo.add(id)
  $(haika.canvas.getObjects()).each (i, obj)=>
    if obj.id==object.id
      setTimeout ->
        haika.canvas.setActiveObject(haika.canvas.item(i))
        $('.add').blur()
      , 10
#setTimeout(->
  #addmany()
  #add(250, 250)
#, 500)

# テスト用
addmany = ->
  y = 0
  while y < 8
    x = 0
    while x < 22
      add 200 + 400 * y, 100 + 50 * x, 90
      x++
    y++
  haika.render()
  return

$ ->
  # レイヤータブ
  $('.nav-tabs a').click (e)->
    e.preventDefault()
    haika.state = $(e.target).attr('class')
    haika.render()
    $(this).tab('show')
  
#  $('.add').click ->
#    add()
#    haika.render()

  # オブジェクトツールバー
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
    wall :
      icon  : 'square'
      title : '壁'
    floor :
      icon  : 'square'
      title : '床'
  for key, val of toolbar
    html = """<li id="add_#{key}" key="#{key}"><i class="fa fa-#{val.icon}"></i> #{val.title}</li>"""
    $('.toolbar_container ul:first').append(html)
    $('#add_'+key).click (e)->
      key =  $(e.target).attr('key')
      object = toolbar[key]
      object.type = key
      add(object)
      haika.render()

# メニューのイベントバインド
$ ->
  $(".add_custom_shelf").click ->
    add('custom_shelf')
    haika.render()
  $(".add_beacon").click ->
    add('beacon')
    haika.render()
  $(".remove").click ->
    object = haika.canvas.getActiveObject()
    haika.remove()
    if object
      undo.remove(object)
  $(".zoomin").click ->
    haika.zoomIn()
  $(".zoomout").click ->
    haika.zoomOut()
  $(".zoomreset").click ->
    haika.zoomReset()
  $(".bringtofront").click ->
    haika.bringToFront()
  $(".duplicate").click ->
    haika.duplicate()
  $(".copy").click ->
    haika.copy()
  $(".paste").click ->
    haika.paste()
  $(".align-left").click ->
    haika.alignLeft()
  $(".align-center").click ->
    haika.alignCenter()
  $(".align-right").click ->
    haika.alignRight()
  $(".align-top").click ->
    haika.alignTop()
  $(".align-vcenter").click ->
    haika.alignVcenter()
  $(".align-bottom").click ->
    haika.alignBottom()
#  $(".toright").click ->
#    haika.toRight()
#  $(".toleft").click ->
#    haika.toLeft()
#  $(".totop").click ->
#    haika.toTop()
#  $(".tobottom").click ->
#    haika.toBottom()
#  $(".svg").click ->
#    haika.getSVG()
#  $(".loadsvg").click ->
#    loadSVG 'http://fabreasy.com/demo_front.svg', haika.canvas, ->
#      alert('done');
#  $(".geojson").click ->
#    haika.getGeoJSON()
#  $(".reset").click ->
#    haika.objects = []
#    localStorage.clear()
#    $(window).off 'beforeunload'
#    location.reload()
#  $(".rotate").slider
#    min: 0
#    max: 360
#    step: 10
#    value: 0
#    slide: (event, ui) ->
#      activeObject = haika.canvas.getActiveObject()
#      if activeObject
#        activeObject.angle = ui.value
#        activeObject.setCoords()
#        haika.canvas.renderAll()


# ボタン類のイベントバインド
$ ->

  # マウスホイール
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
      haika.zoomIn()
    if event.deltaY<0
      haika.zoomOut()

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
    haika.canvas.setWidth($(this).val())
  $('#canvas_height').change ->
    haika.canvas.setHeight($(this).val())
  $('#canvas_centerX').change ->
    haika.centerX = parseInt($(this).val())
  $('#canvas_centerY').change ->
    haika.centerY = parseInt($(this).val())
  $('#canvas_bgscale').change ->
    haika.options.bgscale = parseFloat($(this).val())
#    haika.save()
#  $('#canvas_bgopacity').change ->
#    haika.options.bgopacity = parseFloat($(this).val())
  $('#ex1').slider
    formater: (value)->
      value = parseFloat(value).toFixed(1)
      $('#canvas_bgopacity').val()
      haika.options.bgopacity = value
      haika.render()
#      haika.save()
      return value
  $('#canvas_render').click ->
    haika.render()

  $('#canvas_lat').change ->
    haika.options.lat = parseFloat($(this).val())
    haika.save()
  $('#canvas_lon').change ->
    haika.options.lon = parseFloat($(this).val())
    haika.save()
  
  $('#canvas_angle').change ->
    haika.options.angle = parseInt($(this).val())
    haika.save()

  map_created = false
  toggle_map = ->
    if $('.haika_container').css('display')=='block'
      if not map_created
        map_setting()
        map_created = true
      $('.haika_container').hide()
      $('.map_container').show()
      $('#map_query').focus()
    else
      $('.haika_container').show()
      $('.map_container').hide()
  $('.map_setting').click toggle_map
#  setTimeout ->
#    toggle_map()
#  , 1000
  
  $('.undo').click ->
    undo.undoManager.undo()

  # ショートカットキー
  cancel_default = (e)->
    if e.preventDefault
      e.preventDefault()
    else
      # internet explorer
      e.returnValue = false;
  Mousetrap.bind 'mod+o', ->
    $('#file').trigger('click')
    return false
  Mousetrap.bind 'mod+c', ->
    haika.copy()
    return false
  Mousetrap.bind 'mod+v', ->
    haika.paste()
    return false
  Mousetrap.bind 'mod+d', (e)->
    cancel_default(e)
    haika.duplicate()
    return false
  Mousetrap.bind 'mod+a', (e)->
    cancel_default(e)
    haika.selectAll()
    return false
  Mousetrap.bind 'mod+z', (e)->
    cancel_default(e)
    undo.undoManager.undo()
    return false
  Mousetrap.bind ['esc', 'escape'], (e)->
    cancel_default(e)
    haika.unselectAll()
    return false
  Mousetrap.bind ['up', 'shift+up'], (e)->
    cancel_default(e)
    haika.up(e)
    return false
  Mousetrap.bind ['down', 'shift+down'], (e)->
    cancel_default(e)
    haika.down(e)
    return false
  Mousetrap.bind ['left', 'shift+left'], (e)->
    cancel_default(e)
    haika.left(e)
    return false
  Mousetrap.bind ['right', 'shift+right'], (e)->
    cancel_default(e)
    haika.right(e)
    return false
#  Mousetrap.bind '=', (e)->
#    cancel_default(e)
#    haika.zoomIn()
#    return false
#  Mousetrap.bind '-', (e)->
#    cancel_default(e)
#    haika.zoomOut()
#    return false
#  Mousetrap.bind '0', (e)->
#    cancel_default(e)
#    haika.zoomReset()
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
      haika.remove()
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
        object = @getObject(id)
        log object
        haika.__remove(object)
#        haika.save()
#        haika.render()
      redo: =>
  remove : (object)->
    log 'remove set'
    @undoManager.add
      undo: =>
        log 'undo remove '+object.id
        log object
        haika.add(object)
        haika.render()
      redo: =>
  init : ->
    haika.canvas.on "object:selected", (e) =>
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

    haika.canvas.on "selection:cleared", (e) =>
      object = e.target
    #  console.log "selection:cleared"


    haika.canvas.on "object:modified", (e) =>
      object = e.target
    #  console.log "object:modified"
#      log object
#      group = haika.canvas.getActiveGroup()
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
            haika.canvas.deactivateAll()
            state = @states[@states.length-2]
            object = @getObject(state.id)
    #        log object
            if object
              @setState(object, state)
              @states.pop()
#              log @states[@states.length-1].state_type
              if @states[@states.length-1].state_type=='selected'
                @states.pop()
    #          haika.canvas.renderAll()
              @set_selected = false
              haika.canvas.setActiveObject(object)
            log @states
        redo: =>
    #      redo()
      return
  getObject : (id)->
    object = null
    for o in haika.canvas.getObjects()
      if o.id==id
        object = o
        break
    return object
  setState : (object, state)->
    object.setOptions state
    object.setCoords()

undo.init()


# 画像配架図変換
# 画像を読み込む
loadImg = (file) ->
  if not file.type.match(/image\/.+/)
    return  
  #NOTE:svgを渡すとchromeでcanvasのgetImageDataがエラーを発してしまう．
  if file.type is "image/svg+xml"
    return  
  reader = new FileReader()
  reader.onload = ->
    loadComplete(@result)
  reader.readAsDataURL file

#変換処理ボタンクリック時
$('#file').change (e)->
  files = e.target.files
  if files.length==0
    return
  loadImg files[0]

# 画像をwebworkerで処理
loadComplete = (data)->
  # 画像
  img = new Image()
  img.src = data
  # 色情報を取得するための canvas
  canvas = document.createElement('canvas')
  ctx = canvas.getContext('2d')
  canvas.width = img.width
  canvas.height = img.height
  ctx.translate(0,img.height);
  ctx.scale(1,-1);
  ctx.translate(img.width,0);
  ctx.scale(-1,1);
  ctx.drawImage(img, 0, 0)
  # 画像の色情報を取得
  w = canvas.width
  h = canvas.height
  data = ctx.getImageData(0, 0, w, h).data

  params =
    image : data
    w     : w
    h     : h
  worker = new Worker("js/worker.js")
  worker.onmessage = (e) ->
    log e.data
    switch e.data.status
      when "working"
        log e.data.count
      when "end"
        results = e.data.result
        for result in results
          addPixel(result.x, result.y, result.color)
        haika.render()

  worker.postMessage params

# ピクセル情報から棚を追加
addPixel = (x, y, color)->
  dot = 10
  klass = haika.getClass('shelf')
  object = new klass(
    top: haika.transformTopY_cm2px(y*dot)
    left: haika.transformLeftX_cm2px(x*dot)
    fill: color
    stroke: color
    angle: 0
    count: 1
    side : 1
    eachWidth: dot
    eachHeight: dot
  )
  haika.add(object)
