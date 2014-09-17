#背景画像ボタンクリック時
$('#bgimg').change (e)->
  files = e.target.files
  if files.length==0
    return
  if haika.isLocal()
    haika.loadBgFromFile files[0]
  else
    # IE10以降のみ対応
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
  # キャンバスパネル
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
    $('.canvas_angle').val($('#canvas_angle').val())

  
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
