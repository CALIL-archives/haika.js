# オブジェクトのプロパティの表示・編集
class Property
  # 初期設定
  constructor: ->
    #haika.canvas.on 'object:selected', (e)=>
    #  @setPropetyPanel(e)
    #haika.canvas.on 'selection:cleared', (e)=>
    #  $('.haika-canvas-panel, .haika-object-panel, .haika-group-panel').hide()
    #  $('.haika-canvas-panel').show()
    #haika.canvas.on 'object:modified', (e)=>
#        @setPropetyPanel()
# プロパティパネルの作成
  createPanel : (object)->
    log 'createPanel'
    $('#haika-object-property').html(object.createPropetyPanel())
    $('#haika-object-property').find('input, select, option').change =>
      @savePanel(object)
# プロパティパネルの値を保存
  savePanel : (object)->
    log 'savePanel'
    object.savePropetyPanel($('#haika-object-property'))
# プロパティパネルの設定
  setPropetyPanel: (object)->
    log 'setPropetyPanel'
    $('.haika-canvas-panel, .haika-object-panel, .haika-group-panel').hide()
    # 単体のオブジェクトを選択した場合
    object = haika.canvas.getActiveObject()
    if object
      $('.haika-object-panel').show()
      $('#haika-object-id').html(object.id)
      @createPanel(object)
      return
    # グループ選択の場合
    group = haika.canvas.getActiveGroup()
    if group
      objects = group._objects
      $('#haika-group-count').html(objects.length)
      $('.haika-group-panel').show()
      return
# pluginに登録
haika.plugins.push(Property)




# プロパティ用のHTML
haika.htmlStack.push("""
<div class="haika-property-panel">
  <div class="haika-canvas-panel">
      <h3>キャンバスのプロパティ</h3>
      <label for="haika-canvas-width">
          width: <span id="haika-canvas-width"></span>
      </label>
      <label for="haika-canvas-height">
          height: <span id="haika-canvas-height"></span>
      </label><br/>
      <label for="haika-canvas-centerX">
          centerX: <span id="haika-canvas-centerX"></span>
      </label>
      <label for="haika-canvas-centerY">
          centerY: <span id="haika-canvas-centerY"></span>
      </label><br/>
      <label for="haika-canvas-bgscale">
          bgscale:
          <input type="number" id="haika-canvas-bgscale" class="form-control" value="0" step="0.01"/>
      </label><br/>
      <label for="haika-canvas-bgopacity">
          bgopacity:
          <input type="number" id="haika-canvas-bgopacity" class="form-control" value="0" step="0.1"/>
          <input id="haika-bgopacity-slider" data-slider-id='haika-bgopacity-slider' type="text" data-slider-min="0" data-slider-max="1" data-slider-step="0.1" data-slider-value="0.2"/>
      </label><br/>
      <label for="haika-bgimg">
          背景画像:
          <input type="file" id="haika-bgimg" class="btn btn-default"/>
      </label>
      <br/>
      <br/>
      <span class="haika-map-setting btn btn-default">
        <i class="fa fa-map-marker"></i>
        地図設定
      </span>
      <br/>
      <br/>
      <br/>
      <br/>
      <span id="haika-bgreset" class="btn btn-default">
        <i class="fa fa-trash"></i>
        背景リセット
      </span>
      <br/>
      <br/>
      <br/>
      <br/>
      <span id="haika-import" class="btn btn-default">
        <i class="fa fa-download"></i>
        データのインポート
      </span>
    </div>
    <div class="haika-object-panel">
      <h3>オブジェクトのプロパティ</h3>

      <p>id: <span id="haika-object-id"></span></p>

      <i class="fa fa-trash-o haika-remove btn btn-default"> remove</i>
      <i class="fa fa-files-o haika-duplicate btn btn-default"> duplicate</i>
      <input type="button" class="haika-bringtofront btn btn-default" value="bringToFront "/>
      <div id="haika-object-property"></div>
    </div>
    <div class="haika-group-panel">
        <h3>グループのプロパティ</h3>

        <p><span id="haika-group-count"></span>個のオブジェクトを選択中。</p>

        <p><i class="fa fa-trash-o haika-remove btn btn-default"> remove</i></p>

        <p>

        <div class="btn-group">
            <i class="fa fa-align-left haika-align-left btn btn-default"></i>
            <i class="fa fa-align-center haika-align-center btn btn-default"></i>
            <i class="fa fa-align-right haika-align-right btn btn-default"></i>
        </div>
        </p>
        <p>

        <div class="btn-group">
            <i class="fa fa-align-left fa-rotate-90 haika-align-top btn btn-default"></i>
            <i class="fa fa-align-center fa-rotate-90 haika-align-vcenter btn btn-default"></i>
            <i class="fa fa-align-right fa-rotate-90 haika-align-bottom btn btn-default"></i>
        </div>
        </p>
    </div>
</div>
""")

haika.eventStack.push ->
  # プロパティパネルの表示
  $(haika).on 'haika:render', ->
      $('#haika-canvas-width').html(haika.canvas.getWidth())
      $('#haika-canvas-height').html(haika.canvas.getHeight())
      $('#haika-canvas-centerX').html(haika.centerX.toFixed(0))
      $('#haika-canvas-centerY').html(haika.centerY.toFixed(0))
      $('#haika-canvas-bgscale').val(haika.backgroundScaleFactor)
      $('#haika-canvas-bgopacity').val(haika.backgroundOpacity)

  $('.haika-map-setting').click ->
    location.href = 'map.html'+location.hash
  $('.haika-remove').click ->
    object = haika.canvas.getActiveObject()
    haika.remove()
    if object
      haika.undo.remove(object)
  $('.haika-bringtofront').click ->
    haika.bringToFront()
  $('.haika-duplicate').click ->
    haika.duplicate()
  $('.haika-align-left').click ->
    haika.alignLeft()
  $('.haika-align-center').click ->
    haika.alignCenter()
  $('.haika-align-right').click ->
    haika.alignRight()
  $('.haika-align-top').click ->
    haika.alignTop()
  $('.haika-align-vcenter').click ->
    haika.alignVcenter()
  $('.haika-align-bottom').click ->
    haika.alignBottom()

  $('#haika-canvas-bgscale').change ->
    haika.backgroundScaleFactor = parseFloat($(this).val())
    haika.render()
  #    haika.save()

  $('#haika-bgreset').click ->
    haika.setBackgroundUrl('')

  $('#haika-bgopacity-slider').slider
    step: 1
    min: 1
    max: 100
    value: haika.backgroundOpacity * 100
    formatter: (value) ->
      haika.backgroundOpacity = value / 100
      haika.render()
  #      haika.save()
      return value / 100

  #背景画像ボタンクリック時
  $('#haika-bgimg').change (e)->
    files = e.target.files
    if files.length==0
      return
    # IE10以降のみ対応
    data = new FormData()
    data.append 'id', haika._dataId
    data.append 'userfile', files[0]
    $.ajax
      url: 'http://lab.calil.jp/haika_store/upload.php'
      data: data
      cache: false
      contentType: false
      processData: false
      type: 'POST'
      success: (data) ->
        url = 'http://lab.calil.jp/haika_store/image/'+haika._dataId+'_'+files[0].name
        haika.setBackgroundUrl(url)


# fabricオブジェクトを拡張する

# オブジェクトからプロパティパネルを作る
fabric.Object.prototype.createPropetyPanel = ->
  json = this.getJSONSchema()
  PropetyPanelHTML = '<form class="form-horizontal" role="form">'
  PropetyPanelHTML += """<input type="hidden" prop="id" value="#{this.id}">"""
  for prop, val of json.properties
    if val.type=='string'
        PropetyPanelHTML += """
<div class="form-group">
  <label for="haika-object-#{prop}" class="col-sm-5 control-label">#{prop}</label>
  <div class="col-sm-7">
    <input type="text" prop="#{prop}" xtype="#{val.type}" value="#{this[prop]}" class="form-control #{val.type}">
  </div>
</div>
"""
    else
        PropetyPanelHTML += """
<div class="form-group">
  <label for="haika-object-#{prop}" class="col-sm-5 control-label">#{prop}</label>
  <div class="col-sm-7">
    <input type="number" prop="#{prop}" xtype="#{val.type}" value="#{this[prop]}" class="form-control #{val.type}">
  </div>
</div>
"""
  return PropetyPanelHTML
# JSONスキーマから該当プロパティを取得する
fabric.Object.prototype.getJSON = (name)->
  jsonSchema = this.getJSONSchema()
  for key, property of jsonSchema.properties
    if key==name
      return property
  return {}
# プロパティパネルから保存
fabric.Object.prototype.savePropetyPanel = (propertyPanel)->
  json = {}
  for input in propertyPanel.find('input, select, option')
    name  = $(input).attr('prop')
    xtype  = $(input).attr('xtype')

    jsonSchema  = this.getJSON(name)
    if xtype!='string'
      value = parseInt($(input).val())
      if value
        if jsonSchema.minimum? and value<jsonSchema.minimum
          value = jsonSchema.minimum
        if jsonSchema.maximum? and value>jsonSchema.maximum
          value = jsonSchema.maximum
        json[name] = value
    else
        json[name] = $(input).val()

#    log json
  haika.changeObject(this.id, json)
