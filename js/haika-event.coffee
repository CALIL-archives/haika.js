
# 画面遷移時に保存
$(window).on 'beforeunload', (event)=>
  haika.render()
  haika.save()
  return

$('.nav-tabs a').click (e)->
  e.preventDefault()
  tabName= $(e.target).attr('class')
  haika.addbuttons.show(tabName)
  if tabName=='beacon'
      haika.layer=haika.CONST_LAYERS.BEACON
  if tabName=='wall'
      haika.layer=haika.CONST_LAYERS.WALL
  if tabName=='floor'
      haika.layer=haika.CONST_LAYERS.FLOOR
  if tabName=='shelf'
      haika.layer=haika.CONST_LAYERS.SHELF
  haika.render()
  $(this).tab('show')

#背景画像ボタンクリック時
$('#bgimg').change (e)->
  files = e.target.files
  if files.length==0
    return
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
      url = '/haika_store/image/'+haika.id+'_'+files[0].name
      haika.setBackgroundUrl(url)

# メニューのイベントバインド
# haikaのデータロード完了時に実行する
$(haika).on 'haika:load', ->
  $(".remove").click ->
    object = haika.canvas.getActiveObject()
    haika.remove()
    if object
      haika.undo.remove(object)
  $(".haika-zoomin").click ->
    haika.zoomIn()
  $(".haika-zoomout").click ->
    haika.zoomOut()
  $(".zoomreset").click ->
    haika.setScale 1
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


# ボタン類のイベントバインド
# haikaのデータロード完了時に実行する
$(haika).on 'haika:load', ->
  # マウスホイール
  timeout = false
  $('canvas').on 'mousewheel', (event)=>
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

  $('#canvas-bgscale').change ->
    haika.backgroundScaleFactor = parseFloat($(this).val())
    haika.render()
#    haika.save()

  $('#bgreset').click ->
    haika.setBackgroundUrl('')

  $('#bgopacity-slider').slider
    step: 1
    min: 1
    max: 100
    value: haika.backgroundOpacity * 100
    formatter: (value) ->
      haika.backgroundOpacity = value / 100
      haika.render()
#      haika.save()
      return value / 100

  
  $('.undo').click ->
    haika.undo.undoManager.undo()

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
    haika.undo.undoManager.undo()
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
