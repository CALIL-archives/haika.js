// Generated by CoffeeScript 1.3.1

(function(global) {
  "use strict";

  var extend, fabric, stateProperties;
  fabric = global.fabric || (global.fabric = {});
  extend = fabric.util.object.extend;
  if (fabric.Beacon) {
    console.warn("fabric.Beacon is already defined");
    return;
  }
  stateProperties = fabric.Object.prototype.stateProperties.concat();
  stateProperties.push("x", "y");
  fabric.Beacon = fabric.util.createClass(fabric.Object, {
    stateProperties: stateProperties,
    type: "beacon",
    x: 0,
    y: 0,
    __const_width: 10,
    __const_height: 10,
    __width: function() {
      return this.__const_width * app.scale;
    },
    __height: function() {
      return this.__const_height * app.scale;
    },
    initialize: function(options) {
      options = options || {};
      this.callSuper("initialize", options);
      this.x = options.x || 0;
      this.y = options.y || 0;
      this.width = this.__width();
      this.height = this.__height();
    },
    _render: function(ctx) {
      console.log(this);
      ctx.beginPath();
      if (this.width === 1 && this.height === 1) {
        ctx.fillRect(0, 0, 1, 1);
        return;
      }
      ctx.fillRect(0, 0, this.width, this.height);
      this._renderFill(ctx);
      this._renderStroke(ctx);
    },
    __resizeShelf: function() {
      return this.set({
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
      this.width = this.__width();
      this.height = this.__height();
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
        y: this.get("y"),
        count: this.get("count"),
        side: this.get("side")
      });
      if (!this.includeDefaultValues) {
        this._removeDefaultValues(object);
      }
      return object;
    },
    toGeoJSON: function() {
      var center, data, h, w, x, y;
      w = this.__eachWidth() * this.count / 100;
      h = this.__eachHeight() * this.side / 100;
      center = this.getCenterPoint();
      log(center);
      x = -w / 2 + (center.x / 100);
      y = -h / 2 + (center.y / 100);
      data = {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [[[x, y], [x + w, y], [x + w, y - h], [x, y - h], [x, y]]]
        },
        "properties": {
          "id": this.id,
          "count": this.count,
          "side": this.side,
          "center": this.getCenterPoint()
        }
      };
      return data;
    },
    toSVG: function(reviver) {
      var count, h, i, k, markup, side, w, x, y;
      markup = this._createBaseSVGMarkup();
      markup.push("<g>");
      count = this.get("count");
      side = this.get("side");
      w = this.__const_width;
      h = this.__const_hegiht;
      x = -w / 2 * this.count;
      y = -h / 2 * this.side;
      i = 0;
      k = 0;
      while (i < count) {
        markup.push("<rect x=\"" + ((-1 * this.width / 2) + this.width / count * i) + "\" y=\"" + (-1 * this.height / 2) + "\" rx=\"" + (this.get("rx")) + "\" ry=\"" + (this.get("ry")) + "\" width=\"" + (this.width / count) + "\" height=\"" + (this.height / 2) + "\" style=\"" + (this.getSvgStyles()) + "\" transform=\"" + (this.getSvgTransform()) + "\"/>");
        i++;
      }
      if (side === 2) {
        i = 0;
        while (i < count) {
          markup.push("<rect x=\"" + ((-1 * this.width / 2) + this.width / count * i) + "\" y=\"" + ((-1 * this.height / 2) + this.__const_hegiht) + "\" rx=\"" + (this.get("rx")) + "\" ry=\"" + (this.get("ry")) + "\" width=\"" + (this.width / count) + "\" height=\"" + (this.height / 2) + "\" style=\"" + (this.getSvgStyles()) + "\" transform=\"" + (this.getSvgTransform()) + "\"/>");
          i++;
        }
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
  fabric.Beacon.ATTRIBUTE_NAMES = fabric.SHARED_ATTRIBUTES.concat("x y".split(" "));
})((typeof exports !== "undefined" ? exports : this));
