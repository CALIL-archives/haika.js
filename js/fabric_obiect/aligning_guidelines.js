
/**
Should objects be aligned by a bounding box?
[Bug] Scaled objects sometimes can not be aligned by edges
 */
var initAligningGuidelines;

initAligningGuidelines = function(canvas) {
  var aligningLineColor, aligningLineMargin, aligningLineOffset, aligningLineWidth, ctx, drawHorizontalLine, drawLine, drawVerticalLine, horizontalLines, isInRange, verticalLines;
  drawVerticalLine = function(coords) {
    drawLine(coords.x + 0.5, (coords.y1 > coords.y2 ? coords.y2 : coords.y1), coords.x + 0.5, (coords.y2 > coords.y1 ? coords.y2 : coords.y1));
  };
  drawHorizontalLine = function(coords) {
    drawLine((coords.x1 > coords.x2 ? coords.x2 : coords.x1), coords.y + 0.5, (coords.x2 > coords.x1 ? coords.x2 : coords.x1), coords.y + 0.5);
  };
  drawLine = function(x1, y1, x2, y2) {
    ctx.save();
    ctx.setLineDash([4, 4]);
    ctx.lineWidth = aligningLineWidth;
    ctx.strokeStyle = aligningLineColor;
    ctx.beginPath();
    ctx.moveTo(Math.floor(x1) + 0.5, Math.floor(y1) + 0.5);
    ctx.lineTo(Math.floor(x2) + 0.5, Math.floor(y2) + 0.5);
    ctx.stroke();
    ctx.restore();
  };
  isInRange = function(value1, value2) {
    var i, len;
    value1 = Math.round(value1);
    value2 = Math.round(value2);
    i = value1 - aligningLineMargin;
    len = value1 + aligningLineMargin;
    while (i <= len) {
      if (i === value2) {
        return true;
      }
      i++;
    }
    return false;
  };
  ctx = canvas.getSelectionContext();
  aligningLineOffset = 5;
  aligningLineMargin = 4;
  aligningLineWidth = 1;
  aligningLineColor = "rgb(0,255,0)";
  verticalLines = [];
  horizontalLines = [];
  canvas.on("object:moving", function(e) {
    var activeObject, activeObjectCenter, activeObjectHeight, activeObjectLeft, activeObjectTop, activeObjectWidth, canvasObjects, enabled, horizontalInTheRange, hs, i, objectCenter, objectHeight, objectLeft, objectTop, objectWidth, transform, verticalInTheRange, x;
    activeObject = e.target;
    canvasObjects = canvas.getObjects();
    activeObjectCenter = activeObject.getCenterPoint();
    activeObjectLeft = activeObjectCenter.x;
    activeObjectTop = activeObjectCenter.y;
    activeObjectHeight = activeObject.getBoundingRectHeight();
    activeObjectWidth = activeObject.getBoundingRectWidth();
    horizontalInTheRange = false;
    verticalInTheRange = false;
    transform = canvas._currentTransform;
    if (!transform) {
      return;
    }
    horizontalLines.length = 0;
    verticalLines.length = 0;
    i = canvasObjects.length;
    while (i--) {
      if (canvasObjects[i] === activeObject) {
        continue;
      }
      objectCenter = canvasObjects[i].getCenterPoint();
      objectLeft = objectCenter.x;
      objectTop = objectCenter.y;
      objectHeight = canvasObjects[i].getBoundingRectHeight();
      objectWidth = canvasObjects[i].getBoundingRectWidth();
      if (isInRange(objectLeft - objectWidth / 2, activeObjectLeft - activeObjectWidth / 2)) {
        verticalInTheRange = true;
        verticalLines.push({
          x: objectLeft - objectWidth / 2,
          y1: (objectTop < activeObjectTop ? objectTop - objectHeight / 2 - aligningLineOffset : objectTop + objectHeight / 2 + aligningLineOffset),
          y2: (activeObjectTop > objectTop ? activeObjectTop + activeObjectHeight / 2 + aligningLineOffset : activeObjectTop - activeObjectHeight / 2 - aligningLineOffset)
        });
        activeObject.setPositionByOrigin(new fabric.Point(objectLeft - objectWidth / 2 + activeObjectWidth / 2, activeObjectTop), transform.originX, transform.originY);
      }
      if (isInRange(objectLeft + objectWidth / 2, activeObjectLeft + activeObjectWidth / 2)) {
        verticalInTheRange = true;
        verticalLines.push({
          x: objectLeft + objectWidth / 2,
          y1: (objectTop < activeObjectTop ? objectTop - objectHeight / 2 - aligningLineOffset : objectTop + objectHeight / 2 + aligningLineOffset),
          y2: (activeObjectTop > objectTop ? activeObjectTop + activeObjectHeight / 2 + aligningLineOffset : activeObjectTop - activeObjectHeight / 2 - aligningLineOffset)
        });
        activeObject.setPositionByOrigin(new fabric.Point(objectLeft + objectWidth / 2 - activeObjectWidth / 2, activeObjectTop), transform.originX, transform.originY);
      }
      if (isInRange(objectTop - objectHeight / 2, activeObjectTop - activeObjectHeight / 2)) {
        horizontalInTheRange = true;
        hs = {
          y: objectTop - objectHeight / 2,
          x1: (objectLeft < activeObjectLeft ? objectLeft - objectWidth / 2 - aligningLineOffset : objectLeft + objectWidth / 2 + aligningLineOffset),
          x2: (activeObjectLeft > objectLeft ? activeObjectLeft + activeObjectWidth / 2 + aligningLineOffset : activeObjectLeft - activeObjectWidth / 2 - aligningLineOffset)
        };
        enabled = true;
        x = horizontalLines.length;
        while (x--) {
          if (hs.y === horizontalLines[x].y) {
            if (Math.abs(horizontalLines[x].x2 - horizontalLines[x].x1) > Math.abs(hs.x2 - hs.x1)) {
              if (Math.abs(horizontalLines[x].x2 - horizontalLines[x].x1) - Math.abs(hs.x2 - hs.x1) > 5) {
                horizontalLines.splice(x, 1);
              }
            } else {
              enabled = false;
            }
          }
        }
        if (enabled) {
          horizontalLines.push(hs);
          activeObject.setPositionByOrigin(new fabric.Point(activeObjectLeft, objectTop - objectHeight / 2 + activeObjectHeight / 2), transform.originX, transform.originY);
        }
      }
      if (isInRange(objectTop + objectHeight / 2, activeObjectTop + activeObjectHeight / 2)) {
        horizontalInTheRange = true;
        horizontalLines.push({
          y: objectTop + objectHeight / 2,
          x1: (objectLeft < activeObjectLeft ? objectLeft - objectWidth / 2 - aligningLineOffset : objectLeft + objectWidth / 2 + aligningLineOffset),
          x2: (activeObjectLeft > objectLeft ? activeObjectLeft + activeObjectWidth / 2 + aligningLineOffset : activeObjectLeft - activeObjectWidth / 2 - aligningLineOffset)
        });
        activeObject.setPositionByOrigin(new fabric.Point(activeObjectLeft, objectTop + objectHeight / 2 - activeObjectHeight / 2), transform.originX, transform.originY);
      }
    }
    if (!horizontalInTheRange) {
      horizontalLines.length = 0;
    }
    if (!verticalInTheRange) {
      verticalLines.length = 0;
    }
  });
  canvas.on("before:render", function() {
    canvas.clearContext(canvas.contextTop);
  });
  canvas.on("after:render", function() {
    var i;
    i = verticalLines.length;
    while (i--) {
      drawVerticalLine(verticalLines[i]);
    }
    i = horizontalLines.length;
    while (i--) {
      drawHorizontalLine(horizontalLines[i]);
    }
  });
  canvas.on("mouse:up", function() {
    verticalLines.length = horizontalLines.length = 0;
    canvas.renderAll();
  });
};

//# sourceMappingURL=aligning_guidelines.js.map
