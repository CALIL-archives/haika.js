// Generated by CoffeeScript 1.7.1
(function(global) {
  "use strict";
  var extend, fabric;
  fabric = global.fabric || (global.fabric = {});
  extend = fabric.util.object.extend;
  if (fabric.Beacon) {
    console.warn("fabric.Beacon is already defined");
    return;
  }
  fabric.Beacon = fabric.util.createClass(fabric.Object, {
    type: "beacon",
    eachWidth: 10,
    eachHeight: 10,
    __width: function() {
      return this.eachWidth * app.scale;
    },
    __height: function() {
      return this.eachHeight * app.scale;
    },
    initialize: function(options) {
      options = options || {};
      this.callSuper("initialize", options);
      this.width = this.__width();
      this.height = this.__height();
    },
    _render: function(ctx) {
      ctx.beginPath();
      if (this.width === 1 && this.height === 1) {
        ctx.fillRect(0, 0, 1, 1);
        return;
      }
      ctx.fillRect(this.width / 2 * (-1), this.height / 2 * (-1), this.width, this.height);
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
      if ("top" in parsedAttributes) {
        this.set("top", parsedAttributes.top + this.getHeight() / 2);
      }
      return this;
    },
    toObject: function(propertiesToInclude) {
      var object;
      object = extend(this.callSuper("toObject", propertiesToInclude));
      if (!this.includeDefaultValues) {
        this._removeDefaultValues(object);
      }
      return object;
    },
    toGeoJSON: function() {
      var center, data, h, w, x, y;
      w = this.eachWidth;
      h = this.eachHeight;
      center = this.getCenterPoint();
      x = -w / 2 + center.x;
      y = -h / 2 + center.y;
      x = app.transformLeftX_px2cm(x);
      y = app.transformTopY_px2cm(y);
      data = {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [[[x, y], [x + w, y], [x + w, y - h], [x, y - h], [x, y]]]
        },
        "properties": {
          "type": this.type,
          "id": this.id,
          "angle": this.angle
        }
      };
      return data;
    },
    toSVG: function(reviver) {
      return "";
    },
    getJsonSchema: function() {
      var schema;
      schema = {
        title: "基本情報",
        type: "object",
        properties: {
          angle: {
            type: "integer",
            "default": 0,
            minimum: 0,
            maximum: 360
          }
        }
      };
      return schema;
    },
    complexity: function() {
      return 1;
    }
  });
})((typeof exports !== "undefined" ? exports : this));

/*
//@ sourceMappingURL=beacon.map
*/
