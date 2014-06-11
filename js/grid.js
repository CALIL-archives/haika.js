// Generated by CoffeeScript 1.3.1

(function(global) {
  "use strict";

  var extend, fabric, _setDefaultLeftTopValues;
  _setDefaultLeftTopValues = function(attributes) {
    attributes.left = attributes.left || 0;
    attributes.top = attributes.top || 0;
    return attributes;
  };
  fabric = global.fabric || (global.fabric = {});
  extend = fabric.util.object.extend;
  if (fabric.drawGridLines) {
    console.warn("fabric.drawGridLines is already defined");
    return;
  }
  fabric.drawGridLines = function(canvas) {
    var height, i, line, points, rect, size, text, width;
    canvas.renderOnAddRemove = false;
    width = canvas.width;
    height = canvas.height;
    line = null;
    rect = [];
    size = 100 * app.scale;
    i = 1;
    while (i < Math.ceil(width / size)) {
      rect[0] = i * size;
      rect[1] = 0;
      rect[2] = i * size;
      rect[3] = height;
      line = new fabric.Line(rect, {
        stroke: "#999",
        opacity: 0.5,
        strokeWidth: 0.5,
        strokeDashArray: [2, 2],
        selectable: false,
        hasControls: false,
        hasBorders: false
      });
      canvas.add(line);
      ++i;
    }
    i = 1;
    while (i < Math.ceil(height / size)) {
      rect[0] = 0;
      rect[1] = i * size;
      rect[2] = width;
      rect[3] = i * size;
      line = new fabric.Line(rect, {
        stroke: "#999",
        opacity: 0.5,
        strokeWidth: 0.5,
        strokeDashArray: [2, 2],
        selectable: false,
        hasControls: false,
        hasBorders: false
      });
      canvas.add(line);
      ++i;
    }
    canvas.renderOnAddRemove = true;
    points = [
      {
        'x': 0,
        'y': 0
      }, {
        'x': 0,
        'y': size * 0.1
      }, {
        'x': size,
        'y': size * 0.1
      }, {
        'x': size,
        'y': 0
      }
    ];
    line = new fabric.Polyline(points, {
      stroke: "#000",
      opacity: 0.3,
      top: size * 0.2,
      left: size,
      fill: "#fff",
      strokeWidth: 2,
      selectable: false,
      hasControls: false,
      hasBorders: false
    });
    canvas.add(line);
    text = new fabric.Text('1m', {
      opacity: 0.3,
      left: size * 1.3,
      top: size * 0.35,
      fontSize: 12,
      selectable: false,
      hasControls: false,
      hasBorders: false,
      fontWeight: 'bold',
      fontFamily: 'Open Sans',
      useNative: true,
      fill: "#000"
    });
    canvas.add(text);
    text = new fabric.Text("SIZE = " + (width * 2 / 100) + "m x " + (height * 2 / 100) + "m", {
      opacity: 0.3,
      left: size + size * 1.3,
      top: size * 0.2,
      fontSize: 12,
      selectable: false,
      hasControls: false,
      hasBorders: false,
      fontWeight: 'bold',
      fontFamily: 'Open Sans',
      useNative: true,
      fill: "#000"
    });
    return canvas.add(text);
  };
  fabric.drawGridLines.fromElement = function(element, options) {
    var gridLines, parsedAttributes;
    if (!element) {
      return null;
    }
    parsedAttributes = fabric.parseAttributes(element, fabric.drawGridLines.ATTRIBUTE_NAMES);
    parsedAttributes = _setDefaultLeftTopValues(parsedAttributes);
    gridLines = new fabric.drawGridLines(extend((options ? fabric.util.object.clone(options) : {}), parsedAttributes));
    gridLines._normalizeLeftTopProperties(parsedAttributes);
    return gridLines;
  };
  fabric.drawGridLines.fromObject = function(object) {
    return new fabric.drawGridLines(object);
  };
})((typeof exports !== "undefined" ? exports : this));
