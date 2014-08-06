# Initialize the editor
editor = new JSONEditor(document.getElementById("editor"),
  theme: "bootstrap3"
  iconlib: "fontawesome4"
  disable_edit_json: true
  disable_properties: true
  schema:
    title: "基本情報"
    type: "object"
    properties:
#      name:
#        type: "string"
#        description: "First and Last name"
#        minLength: 4
#        default: "Jeremy Dorn"
#
#      age:
#        type: "integer"
#        default: 24
#        minimum: 18
#        maximum: 99
#
#      favorite_color:
#        type: "string"
#        format: "color"
#        title: "favorite color"
#        default: "#ffa500"
#
#      gender:
#        type: "string"
#        enum: [
#          "male"
#          "female"
#        ]
#
#      location:
#        type: "object"
#        title: "Location"
#        properties:
#          city:
#            type: "string"
#            default: "San Francisco"
#
#          state:
#            type: "string"
#            default: "CA"
#
#          citystate:
#            type: "string"
#            description: "This is generated automatically from the previous two fields"
#            template: "{{city}}, {{state}}"
#            watch:
#              city: "location.city"
#              state: "location.state"
#
#      pets:
#        type: "array"
#        format: "table"
#        title: "Pets"
#        uniqueItems: true
#        items:
#          type: "object"
#          title: "Pet"
#          properties:
#            type:
#              type: "string"
#              enum: [
#                "cat"
#                "dog"
#                "bird"
#                "reptile"
#                "other"
#              ]
#              default: "dog"
#
#            name:
#              type: "string"
#
#        default: [
#          type: "dog"
#          name: "Walter"
#        ]
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
)


# Get the value
#data = editor.getValue()
#console.log data.name # "John Smith"


# Listen for changes
editor.on "change", ->
  log 'onchange'
  # Do something...
  # Validate
  editor_change()

editor_change = ()->
  errors = editor.validate()
  if errors.length
    # Not valid
    log errors
#    alert '入力値が正しくありません。'
  else
    data = editor.getValue()
    log data
    object = app.canvas.getActiveObject()
    log object
    if object
      changed = false
      for key of editor.schema.properties
        log key
        log data[key]
        if object[key]!=data[key] 
          object[key] = data[key]
          changed = true
#      app.canvas.renderAll()
      if changed
        log 'change'
        app.save()
#      app.render()
#      $(app.canvas.getObjects()).each (i, obj)=>
#          if obj.id==object.id
#            app.canvas.setActiveObject(obj)
#    console.log data
  return
