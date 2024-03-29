((global) ->
  fabric = global.fabric or (global.fabric = {})
  extend = fabric.util.object.extend
  if fabric.Wall
    console.warn "fabric.Wall is already defined"
    return
  fabric.Wall = fabric.util.createClass(fabric.Rect,
    type: "wall"
    eachWidth: 100
    eachHeight: 100
    width_scale : 1
    height_scale : 1
    __width: ->
      @eachWidth * @width_scale * haika.scaleFactor
    __height: ->
      @eachHeight * @height_scale* haika.scaleFactor

    initialize: (options) ->
      options = options or {}
      @callSuper "initialize", options
      @width = @__width()
      @height = @__height()
      return

    __resizeShelf: () ->
      @set(flipX: false, flipY: false)

    __modifiedShelf: () ->
      #log '__modifiedShelf'
      @angle = @angle % 360
      if @angle >=350 || @angle <= 10 then @angle=0
      if @angle >=80  && @angle <= 100 then @angle=90
      if @angle >=170 && @angle <=190 then @angle=180
      if @angle >=260 && @angle <=280 then @angle=270

      if @sacleX!=1
        @width = @width * @scaleX
        @width_scale = @width / (@eachWidth * haika.scaleFactor)
      if @sacleY!=1
        @height = @height * @scaleY
        @height_scale = @height / (@eachHeight * haika.scaleFactor)
      @scaleX = @scaleY = 1
      @setCoords()

    toGeoJSON: ->
      w = @eachWidth * @width_scale
      h = @eachHeight * @height_scale
      x = -w / 2 + @left_cm
      y = -h / 2 + @top_cm
      coordinates = [
        [ [x, y], [x + w, y], [x + w, y + h], [x, y + h], [x, y]]
      ]
      new_coordinates = []
      for c in coordinates
        for coordinate in c
          # 回転の反映
          new_coordinate =  fabric.util.rotatePoint(new fabric.Point(coordinate[0], coordinate[1]), new fabric.Point(@left_cm, @top_cm), fabric.util.degreesToRadians(@angle));
          new_coordinates.push([new_coordinate.x, -new_coordinate.y])
      data =
        "type": "Feature"
        "geometry":
          "type": "Polygon",
          "coordinates": [new_coordinates]
        "properties":
          "type"  : @type
          "left_cm" : @left_cm
          "top_cm"  : @top_cm
          "id"    : @id
          "angle" : @angle
          "fill" : @fill
          "stroke" : @stroke
          "width_scale" : @width_scale
          "height_scale" : @height_scale
#          "height": @height
      return data
    getJSONSchema : () ->
      schema =
        title: "基本情報"
        type: "object"
        properties: 
          angle:
            type: "integer"
            default: 0
            minimum: 0
            maximum: 360
          width_scale:
            type: "number"
            default: 1
          height_scale:
            type: "number"
            default: 1
      return schema

    complexity: ->
      1
  )
  return) (if typeof exports isnt "undefined" then exports else this)