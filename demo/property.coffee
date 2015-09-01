$(haika).on 'haika:initialized', ->
  $.ajax
      url: 'sabae.json'
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
        new Property()
#        haika.zoomFull()


# 初期設定
haika.html('.haika-container')
haika.init
  divId : 'haika-canvas'
#  readOnly: true

if haika.readOnly
  haika.event.zoom()
else
#  haika.toolbar.init()
  haika.event.init()
#  haika.undo.init()
#  initScrollBar()
  #haika.colorpicker.init()


