$.extend haika,
# 旧Haikaのデータをインポートする
#
# @param {Number} id データのID
# @option {Function} success 成功時のコールバック関数
# @option {Function} error(message) エラー時のコールバック関数
#
  import: (id, option) ->
    if id.length!=6
      alert('指定されたIDの形式が違います。6桁で指定して下さい。')
      return
    dataId = @_dataId
    collision = @_collision
    revision = @_revision
    if @_dataId
      @close() #開いたデータがある場合は閉じる
    $.ajax
#      url: 'http://lab.calil.jp/haika_store/data/'+id+'.json'
      url: 'https://app.haika.io/js/haika_json/'+id+'.json'
      type: 'POST'
      cache: false
      dataType: 'json'
      error: ()=>
        option.error and option.error('データが読み込めませんでした')
      success: (data)=>
        log data
        geojson = @changeFeatures(data.geojson,(x, y)->
          # 単位をmからcmに変換する
          return [x*100, y*100]
        )
        geojson.haika =
          backgroundScaleFactor : data.canvas.bgscale
          backgroundOpacity : parseFloat(data.canvas.bgopacity)
          backgroundUrl : 'http://lab.calil.jp' + data.canvas.bgurl
          backgroundScaleFactor : data.canvas.bgscale
          xyAngle : data.canvas.angle
          xyScaleFactor : data.canvas.scale
          xyLongitude : data.canvas.lon
          xyLatitude : data.canvas.lat
        log geojson
        @_dataId = dataId
        @_revision = revision
        @_collision = collision
        @_geojson = geojson
        @loadFromGeoJson()
        $(@).trigger('haika:load')
        option.success and option.success()
        $('#haika-canvas-bgscale').val(data.canvas.bgscale)
        $('#haika-canvas-bgopacity').val(data.canvas.bgopacity)


$(haika).on 'haika:render', ->
    $('#canvas_width').html(haika.canvas.getWidth())
    $('#canvas_height').html(haika.canvas.getHeight())
    $('#canvas_centerX').html(haika.centerX)
    $('#canvas_centerY').html(haika.centerY)
    $('#canvas_bgscale').val(haika.backgroundScaleFactor)
    $('#canvas_bgopacity').val(haika.backgroundOpacity)
    $('#canvas_lon').val(haika.xyLongitude)
    $('#canvas_lat').val(haika.xyLatitude)
    $('#canvas_angle').val(haika.canvas.angle)
    $('.zoom').html((haika.scaleFactor * 100).toFixed(0) + '%')



haikaId = location.hash.split('#')[1]
if not haikaId
  alert('HaikaIDを指定して下さい')
else
  haika.html('.haika-container')
  $(haika).on 'haika:initialized', ->
    haika.openFromApi(haikaId,{
      success: ->
        haika.render()
        haika.property.init()
      error: (message) ->
        alert(message)
    })

  # 初期設定
  haika.init
    divId : 'haika-canvas'
  #  readOnly: true

  if haika.readOnly
    haika.event.zoom()
  else
    haika.toolbar.init()
    haika.event.init()
    haika.undo.init()
    initScrollBar()
    haika.colorpicker.init()


# フルスクリーンモードボタン
$('.fullscreen').click ->
  if $('.haika-container')[0].requestFullScreen
    $('.haika-container')[0].requestFullScreen()
  if $('.haika-container')[0].webkitRequestFullScreen
    $('.haika-container')[0].webkitRequestFullScreen()
  if $('.haika-container')[0].mozRequestFullScreen
    $('.haika-container')[0].mozRequestFullScreen()

# データのインポートボタン
$('#haika-import').click ->
  id = prompt('インポートするデータのIDを6桁で指定して下さい。')
  if id
    haika.import(id, {
      success: ->
        haika.render()
        haika.save()
      error: (message) ->
        alert(message)
    })
