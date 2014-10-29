# オブジェクトのプロパティの表示・編集


# fabricオブジェクトを拡張する

# オブジェクトからプロパティパネルを作る
fabric.Object.prototype.createPropetyPanel = ->
  json = this.getJSONSchema()
  PropetyPanelHTML = '<form class="form-horizontal" role="form">'
  PropetyPanelHTML += """<input type="hidden" prop="id" value="#{this.id}">"""
  for prop, val of json.properties
    PropetyPanelHTML += """
<div class="form-group">
  <label for="haika-object-#{prop}" class="col-sm-5 control-label">#{prop}</label>
  <div class="col-sm-7">
    <input type="number" prop="#{prop}" value="#{this[prop]}" class="form-control #{val.type}">
  </div>
</div>
"""
  return PropetyPanelHTML
# JSONスキーマから該当プロパティを取得する
fabric.Object.prototype.getJSON = (name)->
  jsonSchema = this.getJSONSchema()
  for key, property of  jsonSchema.properties
    if key==name
      return property
  return {}
# プロパティパネルから保存
fabric.Object.prototype.savePropetyPanel = (propertyPanel)->
  json = {}
  for input in propertyPanel.find('input, select, option')
    name  = $(input).attr('prop')
    jsonSchema  = this.getJSON(name)
    value = parseInt($(input).val())
    if value
      if jsonSchema.minimum? and value<jsonSchema.minimum
        value = jsonSchema.minimum
      if jsonSchema.maximum? and value>jsonSchema.maximum
        value = jsonSchema.maximum
      json[name] = value
#    log json
  haika.changeObject(this.id, json)

$.extend haika,

  property:
  # 初期設定
    init: ->
      haika.canvas.on 'object:selected', (e)=>
        @setPropetyPanel()
      haika.canvas.on 'selection:cleared', (e)=>
        $('.haika-canvas-panel, .haika-object-panel, .haika-group-panel').hide()
        $('.haika-canvas-panel').show()
#      haika.canvas.on 'object:modified', (e)=>
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
