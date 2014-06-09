// Generated by CoffeeScript 1.7.1
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
  fabric.Shelf = fabric.util.createClass(fabric.Object, {
    stateProperties: stateProperties,
    type: "shelf",
    rx: 0,
    ry: 0,
    x: 0,
    y: 0,
    __width: function() {
      return this.__eachWidth() * this.count;
    },
    __height: function() {
      return this.__eachHeight() * this.side;
    },
    __eachWidth: function() {
      return 90 * app.scale;
    },
    __eachHeight: function() {
      return 25 * app.scale;
    },
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
      this.width = this.__width();
      this.height = this.__height();
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
      var h, i, isInPathGroup, label, sx, w, x, y;
      if (this.width === 1 && this.height === 1) {
        ctx.fillRect(0, 0, 1, 1);
        return;
      }
      ctx.scale(1 / this.scaleX, 1 / this.scaleY);
      sx = 0;
      if (this.scaleX !== 0 && (this.__corner === 'mr' || this.__corner === 'tr' || this.__corner === 'br')) {
        sx = (this.count * this.__eachWidth() - this.width * this.scaleX) / 2;
      }
      if (this.scaleX !== 0 && (this.__corner === 'ml' || this.__corner === 'tl' || this.__corner === 'bl')) {
        sx = -1 * (this.count * this.__eachWidth() - this.width * this.scaleX) / 2;
      }
      w = this.__eachWidth();
      h = this.__eachHeight();
      x = -w / 2 * this.count + sx;
      y = -h / 2 * this.side;
      isInPathGroup = this.group && this.group.type === "path-group";
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
          if (app.scale > 0.5) {
            this.__renderSide(ctx, x + i * w, y, w, h);
          }
        } else if (this.side === 2) {
          this.__renderShelf(ctx, x + i * w, y, w, h);
          this.__renderShelf(ctx, x + i * w, y + h, w, h);
        }
        i++;
      }
      if (this.active) {
        ctx.font = "13.5px Arial";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.fillStyle = 'rgba(0, 0, 0,1)';
        label = this.side === 1 ? "単式" : "複式";
        label = "[" + this.id + "] " + label + this.count + "連";
        ctx.fillText(label, 0, (this.height * this.scaleY) / 2 + 15);
      }
      ctx.scale(this.scaleX, this.scaleY);
    },
    __renderShelf: function(ctx, x, y, w, h) {
      ctx.beginPath();
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
      var actualHeight, actualWidth, count, side;
      actualWidth = this.scaleX * this.currentWidth;
      actualHeight = this.scaleY * this.currentHeight;
      count = Math.floor(actualWidth / this.__eachWidth());
      if (count < 1) {
        count = 1;
      }
      if (count > 10) {
        count = 10;
      }
      side = Math.round(actualHeight / this.__eachHeight());
      if (side < 1) {
        side = 1;
      }
      if (side > 2) {
        side = 2;
      }
      return this.set({
        count: count,
        side: side,
        minScaleLimit: 0.01,
        flipX: false,
        flipY: false
      });
    },
    __modifiedShelf: function() {
      var th;
      this.angle = this.angle % 360;
      if (this.angle >= 350 || this.angle <= 10) {
        this.angle = 0;
      }
      if (this.angle >= 80 && this.angle <= 100) {
        this.angle = 90;
      }
      if (this.angle >= 170 && this.angle <= 190) {
        this.angle = 180;
      }
      if (this.angle >= 260 && this.angle <= 280) {
        this.angle = 270;
      }
      if (this.scaleX !== 0 && (this.__corner === 'mr' || this.__corner === 'tr' || this.__corner === 'br')) {
        th = this.angle * (Math.PI / 180);
        this.top = this.top + Math.sin(th) * (this.count * this.__eachWidth() - this.width * this.scaleX) / 2;
        this.left = this.left + Math.cos(th) * (this.count * this.__eachWidth() - this.width * this.scaleX) / 2;
      }
      if (this.scaleX !== 0 && (this.__corner === 'ml' || this.__corner === 'tl' || this.__corner === 'bl')) {
        th = this.angle * (Math.PI / 180);
        this.top = this.top - Math.sin(th) * (this.count * this.__eachWidth() - this.width * this.scaleX) / 2;
        this.left = this.left - Math.cos(th) * (this.count * this.__eachWidth() - this.width * this.scaleX) / 2;
      }
      this.scaleX = this.scaleY = 1;
      this.width = this.__width();
      this.height = this.__height();
      return this.setCoords();
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
  fabric.Shelf.ATTRIBUTE_NAMES = fabric.SHARED_ATTRIBUTES.concat("x y rx ry width height count side".split(" "));
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

//# sourceMappingURL=shelf.map
