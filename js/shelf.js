// Generated by CoffeeScript 1.3.1

(function(global) {
  "use strict";

  var extend, fabric, stateProperties, _setDefaultLeftTopValues;
  _setDefaultLeftTopValues = function(attributes) {
    attributes.left = attributes.left || 0;
    attributes.top = attributes.top || 0;
    return attributes;
  };
  fabric = global.fabric || (global.fabric = {});
  extend = fabric.util.object.extend;
  if (fabric.Shelf) {
    console.warn("fabric.Shelf is already defined");
    return;
  }
  stateProperties = fabric.Object.prototype.stateProperties.concat();
  stateProperties.push("rx", "ry", "x", "y");
  fabric.drawGridLines = function(canvas) {
    var height, i, line, points, rect, size, text, width;
    canvas.renderOnAddRemove = false;
    width = canvas.width;
    height = canvas.height;
    line = null;
    rect = [];
    size = 50;
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
  fabric.Shelf = fabric.util.createClass(fabric.Object, {
    stateProperties: stateProperties,
    type: "shelf",
    rx: 0,
    ry: 0,
    x: 0,
    y: 0,
    __width: 90,
    __height: 25,
    maxWidth: 900,
    maxHeight: 50,
    count: 1,
    side: 1,
    minScaleLimit: 1,
    strokeDashArray: null,
    initialize: function(options) {
      options = options || {};
      this.callSuper("initialize", options);
      this._initRxRy();
      this.x = options.x || 0;
      this.y = options.y || 0;
      this.width = this.__width * this.count;
      this.height = this.__height * this.side;
    },
    _initRxRy: function() {
      if (this.rx && !this.ry) {
        this.ry = this.rx;
      } else {
        if (this.ry && !this.rx) {
          this.rx = this.ry;
        }
      }
    },
    _render: function(ctx) {
      var h, i, isInPathGroup, isRounded, k, rx, ry, w, x, y;
      if (this.width === 1 && this.height === 1) {
        ctx.fillRect(0, 0, 1, 1);
        return;
      }
      rx = (this.rx ? Math.min(this.rx, this.width / 2) : 0);
      ry = (this.ry ? Math.min(this.ry, this.height / 2) : 0);
      w = this.width / this.count;
      h = this.height / this.side;
      x = -w / 2 * this.count;
      y = -h / 2 * this.side;
      isInPathGroup = this.group && this.group.type === "path-group";
      isRounded = rx !== 0 || ry !== 0;
      k = 1 - 0.5522847498;
      ctx.beginPath();
      ctx.globalAlpha = (isInPathGroup ? ctx.globalAlpha * this.opacity : this.opacity);
      if (this.transformMatrix && isInPathGroup) {
        ctx.translate(this.width / 2 + this.x, this.height / 2 + this.y);
      }
      if (!this.transformMatrix && isInPathGroup) {
        ctx.translate(-this.group.width / 2 + this.width / 2 + this.x, -this.group.height / 2 + this.height / 2 + this.y);
      }
      i = 0;
      while (i < this.count) {
        if (this.side === 1) {
          this.__renderShelf(ctx, x + i * w, y, w, h);
          this.__renderSide(ctx, x + i * w, y, w, h);
        } else if (this.side === 2) {
          this.__renderShelf(ctx, x + i * w, y, w, h);
          this.__renderShelf(ctx, x + i * w, y + h, w, h);
        }
        i++;
      }
      ctx.font = "30px FontAwesome";
      ctx.textAlign = "right";
      ctx.textBaseline = "middle";
      ctx.fillStyle = 'rgba(0, 0, 0, 0.4)';
      ctx.fillText("\uf177", this.width - this.width / 2 - 10, -this.height / 2 + this.height / 2 / this.side);
    },
    __renderShelf: function(ctx, x, y, w, h) {
      ctx.moveTo(x, y);
      ctx.lineWidth = 1;
      ctx.lineTo(x + w, y);
      ctx.lineTo(x + w, y + h);
      ctx.lineTo(x, y + h);
      ctx.lineTo(x, y);
      ctx.closePath();
      this._renderFill(ctx);
      return this._renderStroke(ctx);
    },
    __renderSide: function(ctx, x, y, w, h) {
      ctx.beginPath();
      ctx.lineWidth = 5;
      ctx.moveTo(x, y + h - 1);
      ctx.lineTo(x + w, y + h - 1);
      ctx.closePath();
      this._renderFill(ctx);
      return this._renderStroke(ctx);
    },
    __resizeShelf: function() {
      var actualHeight, actualWidth, count, maxHeight, maxWidth, side;
      maxWidth = this.maxWidth;
      maxHeight = this.maxHeight;
      actualWidth = this.scaleX * this.width;
      actualHeight = this.scaleY * this.height;
      if (!isNaN(maxWidth) && actualWidth >= maxWidth) {
        this.set({
          scaleX: maxWidth / this.width
        });
      }
      if (!isNaN(maxHeight) && actualHeight >= maxHeight) {
        this.set({
          scaleY: maxHeight / this.height
        });
      }
      count = Math.round(this.currentWidth * this.scaleX / this.__width);
      count = count < 1 ? 1 : count;
      side = Math.round(this.currentHeight * this.scaleY / this.__height);
      side = side < 1 ? 1 : side;
      return this.set({
        count: count,
        side: side,
        minScaleLimit: 1 / this.count,
        flipX: false,
        flipY: false
      });
    },
    __modifiedShelf: function() {
      log('__modifiedShelf');
      log(this.scaleX);
      this.width = this.currentWidth;
      this.scaleX = 1;
      this.height = this.currentHeight;
      return this.scaleY = 1;
    },
    _renderDashedStroke: function(ctx) {
      var h, w, x, y;
      x = -this.width / 2;
      y = -this.height / 2;
      w = this.width;
      h = this.height;
      ctx.beginPath();
      fabric.util.drawDashedLine(ctx, x, y, x + w, y, this.strokeDashArray);
      fabric.util.drawDashedLine(ctx, x + w, y, x + w, y + h, this.strokeDashArray);
      fabric.util.drawDashedLine(ctx, x + w, y + h, x, y + h, this.strokeDashArray);
      fabric.util.drawDashedLine(ctx, x, y + h, x, y, this.strokeDashArray);
      ctx.closePath();
    },
    _normalizeLeftTopProperties: function(parsedAttributes) {
      if ("left" in parsedAttributes) {
        this.set("left", parsedAttributes.left + this.getWidth() / 2);
      }
      this.set("x", parsedAttributes.left || 0);
      if ("top" in parsedAttributes) {
        this.set("top", parsedAttributes.top + this.getHeight() / 2);
      }
      this.set("y", parsedAttributes.top || 0);
      return this;
    },
    toObject: function(propertiesToInclude) {
      var object;
      object = extend(this.callSuper("toObject", propertiesToInclude), {
        rx: this.get("rx") || 0,
        ry: this.get("ry") || 0,
        x: this.get("x"),
        y: this.get("y")
      });
      if (!this.includeDefaultValues) {
        this._removeDefaultValues(object);
      }
      return object;
    },
    toSVG: function(reviver) {
      var count, i, k, markup, row;
      markup = this._createBaseSVGMarkup();
      markup.push("<g>");
      i = 0;
      k = 0;
      count = this.get("count");
      row = this.get("row") === 'one' ? 1 : 2;
      while (i < count) {
        markup.push("<rect x=\"" + ((-1 * this.width / 2) + this.width / count * i) + "\" y=\"" + (-1 * this.height / 2) + "\" rx=\"" + (this.get("rx")) + "\" ry=\"" + (this.get("ry")) + "\" width=\"" + (this.width / count) + "\" height=\"" + this.height + "\" style=\"" + (this.getSvgStyles()) + "\" transform=\"" + (this.getSvgTransform()) + "\"/>");
        i++;
      }
      markup.push("</g>");
      if (reviver) {
        return reviver(markup.join(""));
      } else {
        return markup.join("");
      }
    },
    complexity: function() {
      return 1;
    }
  });
  fabric.Shelf.ATTRIBUTE_NAMES = fabric.SHARED_ATTRIBUTES.concat("x y rx ry width height".split(" "));
  fabric.Shelf.fromElement = function(element, options) {
    var parsedAttributes, shelf;
    if (!element) {
      return null;
    }
    parsedAttributes = fabric.parseAttributes(element, fabric.Shelf.ATTRIBUTE_NAMES);
    parsedAttributes = _setDefaultLeftTopValues(parsedAttributes);
    shelf = new fabric.Shelf(extend((options ? fabric.util.object.clone(options) : {}), parsedAttributes));
    shelf._normalizeLeftTopProperties(parsedAttributes);
    return shelf;
  };
  fabric.Shelf.fromObject = function(object) {
    return new fabric.Shelf(object);
  };
})((typeof exports !== "undefined" ? exports : this));
