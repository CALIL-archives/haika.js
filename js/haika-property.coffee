# オブジェクトのプロパティの表示・編集


# fabricオブジェクトを拡張する

# オブジェクトからプロパティパネルを作る
fabric.Object.prototype.createPropetyPanel = ->
  json = this.getJsonSchema()
  PropetyPanelHTML = '<form class="form-horizontal" role="form">'
  PropetyPanelHTML += """<input type="hidden" prop="id" value="#{this.id}">"""
  for prop, val of json.properties
    PropetyPanelHTML += """
<div class="form-group">
  <label for="haika-object-#{prop}" class="col-sm-5 control-label">#{prop}</label>
  <div class="col-sm-7">
    <input type="text" prop="#{prop}" value="#{this[prop]}" class="form-control #{val.type}">
  </div>
</div>
"""
  return PropetyPanelHTML
# プロパティパネルから保存
fabric.Object.prototype.savePropetyPanel = (propertyPanel)->
  json = {}
  for input in propertyPanel.find('input, select, option')
    json[$(input).attr('prop')] = parseInt($(input).val())
  log json
  haika.changeObject(json)

$.extend haika,

  property:
    init: ->
      haika.canvas.on 'object:selected', (e)=>
        @setPropetyPanel()
      haika.canvas.on 'selection:cleared', (e)=>
        $('.haika-canvas-panel, .haika-object-panel, .haika-group-panel').hide()
        $('.haika-canvas-panel').show()
      haika.canvas.on 'object:modified', (e)=>
        @setPropetyPanel()
    createPanel : (object)->
      log 'createPanel'
      $('#haika-object-property').html(object.createPropetyPanel())
      $('#haika-object-property').find('input, select, option').change =>
        @savePanel(object)
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
