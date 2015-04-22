((global) ->
  "use strict"
  fabric = global.fabric or (global.fabric = {})
  extend = fabric.util.object.extend
  if fabric.Beacon
    console.warn "fabric.Beacon is already defined"
    return

  stateProperties = fabric.Object::stateProperties.concat()
  stateProperties.push "id", "top_cm", "left_cm", "lane", "index"

  fabric.Beacon = fabric.util.createClass(fabric.Object,
    stateProperties: stateProperties
    type: "beacon"
    eachWidth: 10
    eachHeight: 10
    hasControls: false
    padding : 10
    lane : "main"
    index : 0
    minor: 0
    __width: ->
      @eachWidth * haika.scaleFactor
    __height: ->
      @eachHeight * haika.scaleFactor

    initialize: (options) ->
      options = options or {}
      @callSuper "initialize", options
      @width = @__width()
      @height = @__height()
      return

    _render: (ctx) ->
#      console.log @
      ctx.beginPath()
      ctx.fillRect @width / 2 * (-1), @height / 2 * (-1), @width, @height
      @_renderFill ctx
      @_renderStroke ctx
      #ctx.save()

      """
      ctx.fillStyle='rgba(255,0,0,0.02)'
      ctx.beginPath()
      ctx.arc(0,0, 2000*haika.scaleFactor, 0, Math.PI*2, false);
      ctx.fill()


      ctx.fillStyle='rgba(255,0,0,0.08)'
      ctx.beginPath()
      ctx.arc(0,0, 500*haika.scaleFactor, 0, Math.PI*2, false);
      ctx.fill()
      """

      ctx.font = "12px Arial";
      ctx.textAlign = "center"
      ctx.textBaseline = "middle"
      ctx.fillStyle = 'rgba(0, 0, 0,1)'
      label = @minor + '(' + @lane + ')'
      ctx.fillText(label, 0, (@height * @scaleY) / 2 + 15)
      #ctx.restore()
      return

    __resizeShelf: () ->
      @set(flipX: false, flipY: false)

    __modifiedShelf: () ->
      @angle = 0
      @width = @__width()
      @height = @__height()
      @setCoords()
      @__is_into()

    __is_into: () ->
      objects = haika.canvas.getObjects()
      for object in objects
        if object.type.match(/shelf$/)
          half_width = object.__width() / 2
          left = object.left - half_width
          right = object.left + half_width
          half_height = object.__height() / 2
          top = object.top - half_height
          bottom = object.top + half_height
          if (@left > left and @left < right) and (@top > top and @top < bottom)
            log 'into:' + object.id

    _normalizeLeftTopProperties: (parsedAttributes) ->
      @set "left", parsedAttributes.left + @getWidth() / 2  if "left" of parsedAttributes
      @set "top", parsedAttributes.top + @getHeight() / 2  if "top" of parsedAttributes
      this

    toObject: (propertiesToInclude) ->
      object = extend(@callSuper("toObject", propertiesToInclude))
      if not @includeDefaultValues
        @_removeDefaultValues object
      return object

    toGeoJSON: ->
      data =
        "type": "Feature"
        "geometry":
          "type": "Point",
          "coordinates": [-@left_cm,@top_cm]
        "properties":
          "type": @type
          "id": @id
          "left_cm": @left_cm
          "top_cm": @top_cm
          "minor": @minor
          "lane": @lane
          "index": @index
      return data

    toSVG: (reviver) ->
      ""

    getJSONSchema: () ->
      schema =
        title: "基本情報"
        type: "object"
        properties:
          minor:
            description: "minor"
            type: "integer"
          lane:
            description: "レーン名"
            type: "string"
          index:
            description: "レーンの順番"
            type: "integer"
      return schema

    complexity: ->
      1
  )
  return) (if typeof exports isnt "undefined" then exports else this)