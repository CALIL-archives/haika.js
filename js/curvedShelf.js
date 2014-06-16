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
  if (fabric.curvedShelf) {
    console.warn("fabric.curvedShelf is already defined");
    return;
  }
  stateProperties = fabric.Object.prototype.stateProperties.concat();
  stateProperties.push("rx", "ry", "x", "y");
  fabric.curvedShelf = fabric.util.createClass(fabric.Object, {
    stateProperties: stateProperties,
    type: "curved_shelf",
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
      var arcEnd, arcStart, arcX, arcY, label, rad;
      if (this.width === 1 && this.height === 1) {
        ctx.fillRect(0, 0, 1, 1);
        return;
      }
      ctx.scale(1 / this.scaleX, 1 / this.scaleY);
      arcStart = (180 - 30 * this.count) / 2 * Math.PI / 180;
      arcEnd = arcStart + 30 * this.count * Math.PI / 180;
      arcX = 0;
      arcY = 0;
      ctx.beginPath();
      ctx.arc(arcX, arcY, this.height * this.scaleY / 2, arcStart, arcEnd, false);
      rad = this.height * this.scaleY / 2 - this.__eachHeight() * this.side;
      if (rad <= 10) {
        rad = 10;
      }
      if (30 * this.count < 360) {
        ctx.arc(arcX, arcY, rad, arcEnd, arcStart, true);
      }
      ctx.closePath();
      this._renderFill(ctx);
      this._renderStroke(ctx);
      ctx.beginPath();
      rad = this.height * this.scaleY / 2 - this.__eachHeight() * 1;
      if (rad <= 10) {
        rad = 10;
      }
      ctx.arc(arcX, arcY, rad, arcStart, arcEnd, false);
      ctx.stroke();
      if (this.active) {
        ctx.font = "13.5px Arial";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.fillStyle = 'rgba(0, 0, 0,1)';
        label = this.side === 1 ? "曲面単式" : "曲面複式";
        label = "[" + this.id + "] " + label + this.count + "連";
        ctx.fillText(label, 0, (this.height * this.scaleY) / 2 + 15);
      }
      ctx.scale(this.scaleX, this.scaleY);
    },
    __resizeShelf: function() {
      var actualHeight, actualWidth, count, side;
      actualWidth = this.scaleX * this.currentWidth;
      actualHeight = this.scaleY * this.currentHeight;
      count = Math.floor(actualWidth / this.__eachWidth());
      if (count < 1) {
        count = 1;
      }
      if (count > 20) {
        count = 20;
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
      this.height = this.height * this.scaleY;
      this.scaleX = this.scaleY = 1;
      this.width = this.__width();
      return this.setCoords();
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
  fabric.curvedShelf.ATTRIBUTE_NAMES = fabric.SHARED_ATTRIBUTES.concat("x y rx ry width height count side".split(" "));
  fabric.curvedShelf.fromElement = function(element, options) {
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
  fabric.curvedShelf.fromObject = function(object) {
    return new fabric.curvedShelf(object);
  };
})((typeof exports !== "undefined" ? exports : this));

//# sourceMappingURL=curvedShelf.map
