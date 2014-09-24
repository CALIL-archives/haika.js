# Initialize the editor
$.extend haika, 
  editor : new JSONEditor document.getElementById("editor"),
    theme: "bootstrap3"
    iconlib: "fontawesome4"
    disable_edit_json: true
    disable_properties: true
    schema:
      title: "基本情報"
      type: "object"
      properties:
        label:
          title: "ラベル"
          type: "string"
        count:
          title: "連数"
          type: "integer"
          default: 3
          minimum: 1
          maximum: 10

        side:
          title: "面数"
          type: "integer"
          default: 1
          minimum: 1
          maximum: 2

        angle:
          title: "角度"
          type: "integer"
          default: 0
          minimum: 0
          maximum: 360
        eachWidth:
          type: "integer"
          default: 90
          minimum: 1
        eachHeight:
          type: "integer"
          default: 25
          minimum: 1
        minor:
          type: "integer"
  #      width_scale:
  #        type: "number"
  #        default: 1

  #      shelfs:
  #        type: "array"
  #        uniqueItems: true
  #        items:
  #          type: "string"
  #          enum: [
  #            "value1"
  #            "value2"
  #          ]
  editor_change : ->
    errors = haika.editor.validate()
    if errors.length
      # Not valid
      log errors
  #    alert '入力値が正しくありません。'
    else
      data = haika.editor.getValue()
      log data
      object = haika.canvas.getActiveObject()
      log object
      if object
        changed = false
        for key of haika.editor.schema.properties
          log key
          log data[key]
          if object[key]!=data[key] 
            object[key] = data[key]
            changed = true
  #      haika.canvas.renderAll()
        if changed
          log 'change'
          haika.save()
  #      haika.render()
  #      $(haika.canvas.getObjects()).each (i, obj)=>
  #          if obj.id==object.id
  #            haika.canvas.setActiveObject(obj)
  #    console.log data
    return


# Get the value
#data = haika.editor.getValue()
#console.log data.name # "John Smith"


# Listen for changes
haika.editor.on "change", ->
  log 'onchange'
  # Do something...
  # Validate
