haika.init()
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


