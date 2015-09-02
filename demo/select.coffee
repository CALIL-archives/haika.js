$(haika).on 'haika:initialized', ->
  $.ajax
      url: 'data/sabae.json'
      type: 'GET'
      cache: false
      dataType: 'json'
      error: ()=>
        option.error and option.error('データが読み込めませんでした')
      success: (json)=>
        if json.locked
          @readOnly = true
          return option.error and option.error('データはロックされています')
        haika._dataId = json.id
        haika._revision = json.revision
        haika._collision = json.collision
        haika._geojson = json.data
        haika.loadFromGeoJson()
        $(haika).trigger('haika:load')
        haika.render()
        if Property?
          new Property()
        if haika.zoomFull?
          haika.zoomFull()


# 初期設定
haika.html('.haika-container')
haika.init
  divId : 'haika-canvas'
#  readOnly: true

if haika.readOnly
  haika.event.zoom()
else
  haika.event.init()
  if haika.toolbar?
    haika.toolbar.init()
  if haika.undo?
    haika.undo.init()
  if initScrollBar?
    initScrollBar()
  #haika.colorpicker.init()


