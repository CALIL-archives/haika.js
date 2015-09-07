# fabricObjectの追加
haika.addObject('shelf'       , 0, fabric.Shelf)
haika.addObject('curved_shelf', 0, fabric.curvedShelf)
haika.addObject('beacon'      , 1, fabric.Beacon)
haika.addObject('wall'        , 2, fabric.Wall)
haika.addObject('floor'       , 3, fabric.Floor)

# レイヤーの設定
hash = location.hash.split('#')[1]
if hash
  layer = hash*1
else
  0
haika.init(
  layer: layer
)

# ローカルストレージに保存
haika.save = ->
  # GeoJSONを保存
#  log(haika._geojson)
  localStorage.setItem('haika2', JSON.stringify(haika._geojson))
  log('save local storage')
  view_log(haika._geojson)


haikaStart = ->
  haika.loadFromGeoJson()
  $(haika).trigger('haika:load')
  haika.render()


# ローカルストレージから読み込み
if localStorage.getItem('haika2')
  log 'load local storage'
  haika._geojson = JSON.parse(localStorage.getItem('haika2'))
  haikaStart()
else
  $.ajax
      url: 'data/calil.json'
      type: 'GET'
      cache: false
      dataType: 'json'
      error: ()=>
        option.error and option.error('データが読み込めませんでした')
      success: (json)=>
        if json.locked
          @readOnly = true
          return option.error and option.error('データはロックされています')
        log 'load ajax'
        haika._dataId = json.id
        haika._revision = json.revision
        haika._collision = json.collision
        haika._geojson = json.data
        haikaStart()



