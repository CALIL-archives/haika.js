###*
Should objects be aligned by a bounding box?
[Bug] Scaled objects sometimes can not be aligned by edges
###
initAligningGuidelines = (canvas) ->
  drawVerticalLine = (coords) ->
    drawLine coords.x + 0.5, (if coords.y1 > coords.y2 then coords.y2 else coords.y1), coords.x + 0.5, (if coords.y2 > coords.y1 then coords.y2 else coords.y1)
    return
  drawHorizontalLine = (coords) ->
    drawLine (if coords.x1 > coords.x2 then coords.x2 else coords.x1), coords.y + 0.5, (if coords.x2 > coords.x1 then coords.x2 else coords.x1), coords.y + 0.5
    return
  drawLine = (x1, y1, x2, y2) ->
    ctx.save()
    ctx.setLineDash [
      4
      4
    ]
    ctx.lineWidth = aligningLineWidth
    ctx.strokeStyle = aligningLineColor
    ctx.beginPath()
    ctx.moveTo Math.floor(x1) + 0.5, Math.floor(y1) + 0.5
    ctx.lineTo Math.floor(x2) + 0.5, Math.floor(y2) + 0.5
    ctx.stroke()
    ctx.restore()
    return
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
  verticalLines = []
  horizontalLines = []

  #  function getObjects(){
  #    var objects = [];
  #    $(haika.objects).each(function(i, object){
  #      objects.push(object);
  #    });
  #    return objects;
  #  }
  canvas.on "object:moving", (e) ->
    activeObject = e.target
    canvasObjects = canvas.getObjects()

    #        appObjects = getObjects(),
    activeObjectCenter = activeObject.getCenterPoint()
    activeObjectLeft = activeObjectCenter.x
    activeObjectTop = activeObjectCenter.y
    activeObjectHeight = activeObject.getBoundingRectHeight()
    activeObjectWidth = activeObject.getBoundingRectWidth()
    horizontalInTheRange = false
    verticalInTheRange = false
    transform = canvas._currentTransform
    return  unless transform
    horizontalLines.length = 0
    verticalLines.length = 0

    # It should be trivial to DRY this up by encapsulating (repeating) creation of x1, x2, y1, and y2 into functions,
    # but we're not doing it here for perf. reasons -- as this a function that's invoked on every mouse move
    i = canvasObjects.length

    while i--
      continue  if canvasObjects[i] is activeObject
      objectCenter = canvasObjects[i].getCenterPoint()
      objectLeft = objectCenter.x
      objectTop = objectCenter.y
      objectHeight = canvasObjects[i].getBoundingRectHeight()
      objectWidth = canvasObjects[i].getBoundingRectWidth()

      # snap by the horizontal center line
      #
      #      if (isInRange(objectLeft, activeObjectLeft)) {
      #        verticalInTheRange = true;
      #        verticalLines.push({
      #          x: objectLeft,
      #          y1: (objectTop < activeObjectTop)
      #            ? (objectTop - objectHeight / 2 - aligningLineOffset)
      #            : (objectTop + objectHeight / 2 + aligningLineOffset),
      #          y2: (activeObjectTop > objectTop)
      #            ? (activeObjectTop + activeObjectHeight / 2 + aligningLineOffset)
      #            : (activeObjectTop - activeObjectHeight / 2 - aligningLineOffset)
      #        });
      #        activeObject.setPositionByOrigin(new fabric.Point(objectLeft, activeObjectTop), transform.originX, transform.originY);
      #      }
      #

      # snap by the left edge
      if isInRange(objectLeft - objectWidth / 2, activeObjectLeft - activeObjectWidth / 2)
        verticalInTheRange = true
        verticalLines.push
          x: objectLeft - objectWidth / 2
          y1: (if (objectTop < activeObjectTop) then (objectTop - objectHeight / 2 - aligningLineOffset) else (objectTop + objectHeight / 2 + aligningLineOffset))
          y2: (if (activeObjectTop > objectTop) then (activeObjectTop + activeObjectHeight / 2 + aligningLineOffset) else (activeObjectTop - activeObjectHeight / 2 - aligningLineOffset))

        activeObject.setPositionByOrigin new fabric.Point(objectLeft - objectWidth / 2 + activeObjectWidth / 2, activeObjectTop), transform.originX, transform.originY

      # snap by the right edge
      if isInRange(objectLeft + objectWidth / 2, activeObjectLeft + activeObjectWidth / 2)
        verticalInTheRange = true
        verticalLines.push
          x: objectLeft + objectWidth / 2
          y1: (if (objectTop < activeObjectTop) then (objectTop - objectHeight / 2 - aligningLineOffset) else (objectTop + objectHeight / 2 + aligningLineOffset))
          y2: (if (activeObjectTop > objectTop) then (activeObjectTop + activeObjectHeight / 2 + aligningLineOffset) else (activeObjectTop - activeObjectHeight / 2 - aligningLineOffset))

        activeObject.setPositionByOrigin new fabric.Point(objectLeft + objectWidth / 2 - activeObjectWidth / 2, activeObjectTop), transform.originX, transform.originY

      # snap by the vertical center line
      #
      #      if (isInRange(objectTop, activeObjectTop)) {
      #        horizontalInTheRange = true;
      #        horizontalLines.push({
      #          y: objectTop,
      #          x1: (objectLeft < activeObjectLeft)
      #            ? (objectLeft - objectWidth / 2 - aligningLineOffset)
      #            : (objectLeft + objectWidth / 2 + aligningLineOffset),
      #          x2: (activeObjectLeft > objectLeft)
      #            ? (activeObjectLeft + activeObjectWidth / 2 + aligningLineOffset)
      #            : (activeObjectLeft - activeObjectWidth / 2 - aligningLineOffset)
      #        });
      #        activeObject.setPositionByOrigin(new fabric.Point(activeObjectLeft, objectTop), transform.originX, transform.originY);
      #      }
      #

      # snap by the top edge
      if isInRange(objectTop - objectHeight / 2, activeObjectTop - activeObjectHeight / 2)
        horizontalInTheRange = true
        hs =
          y: objectTop - objectHeight / 2
          x1: (if (objectLeft < activeObjectLeft) then (objectLeft - objectWidth / 2 - aligningLineOffset) else (objectLeft + objectWidth / 2 + aligningLineOffset))
          x2: (if (activeObjectLeft > objectLeft) then (activeObjectLeft + activeObjectWidth / 2 + aligningLineOffset) else (activeObjectLeft - activeObjectWidth / 2 - aligningLineOffset))

        enabled = true
        x = horizontalLines.length

        while x--
          if hs.y is horizontalLines[x].y
            if Math.abs(horizontalLines[x].x2 - horizontalLines[x].x1) > Math.abs(hs.x2 - hs.x1)
              horizontalLines.splice x, 1  if Math.abs(horizontalLines[x].x2 - horizontalLines[x].x1) - Math.abs(hs.x2 - hs.x1) > 5
            else
              enabled = false
        if enabled
          horizontalLines.push hs
          activeObject.setPositionByOrigin new fabric.Point(activeObjectLeft, objectTop - objectHeight / 2 + activeObjectHeight / 2), transform.originX, transform.originY

      # snap by the bottom edge
      if isInRange(objectTop + objectHeight / 2, activeObjectTop + activeObjectHeight / 2)
        horizontalInTheRange = true
        horizontalLines.push
          y: objectTop + objectHeight / 2
          x1: (if (objectLeft < activeObjectLeft) then (objectLeft - objectWidth / 2 - aligningLineOffset) else (objectLeft + objectWidth / 2 + aligningLineOffset))
          x2: (if (activeObjectLeft > objectLeft) then (activeObjectLeft + activeObjectWidth / 2 + aligningLineOffset) else (activeObjectLeft - activeObjectWidth / 2 - aligningLineOffset))

        activeObject.setPositionByOrigin new fabric.Point(activeObjectLeft, objectTop + objectHeight / 2 - activeObjectHeight / 2), transform.originX, transform.originY
    horizontalLines.length = 0  unless horizontalInTheRange
    verticalLines.length = 0  unless verticalInTheRange
    return

  canvas.on "before:render", ->
    canvas.clearContext canvas.contextTop
    return

  canvas.on "after:render", ->
    i = verticalLines.length

    while i--
      drawVerticalLine verticalLines[i]
    i = horizontalLines.length

    while i--
      drawHorizontalLine horizontalLines[i]
    return

  canvas.on "mouse:up", ->
    verticalLines.length = horizontalLines.length = 0
    canvas.renderAll()
    return

  return