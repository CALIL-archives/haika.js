###
Should objects be aligned by a bounding box?
[Bug] Scaled objects sometimes can not be aligned by edges
###
initAligningGuidelines = (canvas) ->
  drawVerticalLine = (coords) ->
    drawLine coords.x + 0.5, (if coords.y1 > coords.y2 then coords.y2 else coords.y1), coords.x + 0.5, (if coords.y2 > coords.y1 then coords.y2 else coords.y1)
  drawHorizontalLine = (coords) ->
    drawLine (if coords.x1 > coords.x2 then coords.x2 else coords.x1), coords.y + 0.5, (if coords.x2 > coords.x1 then coords.x2 else coords.x1), coords.y + 0.5
  drawLine = (x1, y1, x2, y2) ->
    ctx.save()
    ctx.lineWidth = aligningLineWidth
    ctx.strokeStyle = aligningLineColor
    ctx.beginPath()
    ctx.moveTo x1 * viewportTransform[0], y1 * viewportTransform[3]
    ctx.lineTo x2 * viewportTransform[0], y2 * viewportTransform[3]
    ctx.stroke()
    ctx.restore()
  isInRange = (value1, value2) ->
    value1 = Math.round(value1)
    value2 = Math.round(value2)
    i = value1 - aligningLineMargin
    len = value1 + aligningLineMargin

    while i <= len
      return true  if i is value2
      i++
    false
  ctx = canvas.getSelectionContext()
  aligningLineOffset = 5
  aligningLineMargin = 4
  aligningLineWidth = 1
  aligningLineColor = "rgb(0,255,0)"
  viewportTransform = undefined
  verticalLines = []
  horizontalLines = []
  canvas.on "mouse:down", ->
    viewportTransform = canvas.viewportTransform

  canvas.on "object:moving", (e) ->
    activeObject = e.target
    canvasObjects = canvas.getObjects()
    activeObjectCenter = activeObject.getCenterPoint()
    activeObjectLeft = activeObjectCenter.x
    activeObjectTop = activeObjectCenter.y
    activeObjectHeight = activeObject.getBoundingRectHeight() / viewportTransform[3]
    activeObjectWidth = activeObject.getBoundingRectWidth() / viewportTransform[0]
    horizontalInTheRange = false
    verticalInTheRange = false
    transform = canvas._currentTransform
    return  unless transform
    
    # It should be trivial to DRY this up by encapsulating (repeating) creation of x1, x2, y1, and y2 into functions,
    # but we're not doing it here for perf. reasons -- as this a function that's invoked on every mouse move
    i = canvasObjects.length

    while i--
      continue  if canvasObjects[i] is activeObject
      if canvasObjects[i].type=='beacon'
        continue
      objectCenter = canvasObjects[i].getCenterPoint()
      objectLeft = objectCenter.x
      objectTop = objectCenter.y
      objectHeight = canvasObjects[i].getBoundingRectHeight() / viewportTransform[3]
      objectWidth = canvasObjects[i].getBoundingRectWidth() / viewportTransform[0]
      
      # snap by the left edge
      if isInRange(objectLeft - objectWidth / 2, activeObjectLeft - activeObjectWidth / 2)
        verticalInTheRange = true
        verticalLines.push
          x: objectLeft - objectWidth / 2
          y1: (if (objectTop < activeObjectTop) then (objectTop - objectHeight / 2 - aligningLineOffset) else (objectTop + objectHeight / 2 + aligningLineOffset))
          y2: (if (activeObjectTop > objectTop) then (activeObjectTop + activeObjectHeight / 2 + aligningLineOffset) else (activeObjectTop - activeObjectHeight / 2 - aligningLineOffset))
        activeObject.setPositionByOrigin new fabric.Point(objectLeft - objectWidth / 2 + activeObjectWidth / 2, activeObjectTop), "center", "center"
      
      # snap by the right edge
      if isInRange(objectLeft + objectWidth / 2, activeObjectLeft + activeObjectWidth / 2)
        verticalInTheRange = true
        verticalLines.push
          x: objectLeft + objectWidth / 2
          y1: (if (objectTop < activeObjectTop) then (objectTop - objectHeight / 2 - aligningLineOffset) else (objectTop + objectHeight / 2 + aligningLineOffset))
          y2: (if (activeObjectTop > objectTop) then (activeObjectTop + activeObjectHeight / 2 + aligningLineOffset) else (activeObjectTop - activeObjectHeight / 2 - aligningLineOffset))

        activeObject.setPositionByOrigin new fabric.Point(objectLeft + objectWidth / 2 - activeObjectWidth / 2, activeObjectTop), "center", "center"
      
      # snap by the top edge
      if isInRange(objectTop - objectHeight / 2, activeObjectTop - activeObjectHeight / 2)
        horizontalInTheRange = true
        horizontalLines.push
          y: objectTop - objectHeight / 2
          x1: (if (objectLeft < activeObjectLeft) then (objectLeft - objectWidth / 2 - aligningLineOffset) else (objectLeft + objectWidth / 2 + aligningLineOffset))
          x2: (if (activeObjectLeft > objectLeft) then (activeObjectLeft + activeObjectWidth / 2 + aligningLineOffset) else (activeObjectLeft - activeObjectWidth / 2 - aligningLineOffset))

        activeObject.setPositionByOrigin new fabric.Point(activeObjectLeft, objectTop - objectHeight / 2 + activeObjectHeight / 2), "center", "center"
      
      # snap by the bottom edge
      if isInRange(objectTop + objectHeight / 2, activeObjectTop + activeObjectHeight / 2)
        horizontalInTheRange = true
        horizontalLines.push
          y: objectTop + objectHeight / 2
          x1: (if (objectLeft < activeObjectLeft) then (objectLeft - objectWidth / 2 - aligningLineOffset) else (objectLeft + objectWidth / 2 + aligningLineOffset))
          x2: (if (activeObjectLeft > objectLeft) then (activeObjectLeft + activeObjectWidth / 2 + aligningLineOffset) else (activeObjectLeft - activeObjectWidth / 2 - aligningLineOffset))

        activeObject.setPositionByOrigin new fabric.Point(activeObjectLeft, objectTop + objectHeight / 2 - activeObjectHeight / 2), "center", "center"
    horizontalLines.length = 0  unless horizontalInTheRange
    verticalLines.length = 0  unless verticalInTheRange

  canvas.on "before:render", ->
    canvas.clearContext canvas.contextTop

  canvas.on "after:render", ->
    i = verticalLines.length

    while i--
      drawVerticalLine verticalLines[i]
    i = horizontalLines.length

    while i--
      drawHorizontalLine horizontalLines[i]
    verticalLines.length = horizontalLines.length = 0

  canvas.on "mouse:up", ->
    verticalLines.length = horizontalLines.length = 0
    canvas.renderAll()