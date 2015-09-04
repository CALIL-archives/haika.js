haika.addObject('shelf'       , 0, fabric.Shelf)
haika.addObject('curved_shelf', 0, fabric.curvedShelf)
haika.addObject('beacon'      , 1, fabric.Beacon)
haika.addObject('wall'        , 2, fabric.Wall)
haika.addObject('floor'       , 3, fabric.Floor)
haika.init(
  layer: 0
)

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


