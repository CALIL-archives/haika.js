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
    minor: 0,
    __width: function() {
      return this.eachWidth * haika.scale;
    },
    __height: function() {
      return this.eachHeight * haika.scale;
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
      this.setCoords();
      return this.__is_into();
    },
    __is_into: function() {
      var bottom, half_height, half_width, left, object, objects, right, top, _i, _len, _results;
      objects = haika.canvas.getObjects();
      _results = [];
      for (_i = 0, _len = objects.length; _i < _len; _i++) {
        object = objects[_i];
        if (object.type.match(/shelf$/)) {
          half_width = object.__width() / 2;
          left = object.left - half_width;
          right = object.left + half_width;
          half_height = object.__height() / 2;
          top = object.top - half_height;
          bottom = object.top + half_height;
          if ((this.left > left && this.left < right) && (this.top > top && this.top < bottom)) {
            _results.push(log('into:' + object.id));
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
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
      var c, coordinate, coordinates, data, h, new_coordinate, new_coordinates, w, x, y, _i, _j, _len, _len1;
      w = this.__width() / 100;
      h = this.__height() / 100;
      x = -w / 2 + this.left_cm / 100;
      y = -h / 2 + this.top_cm / 100;
      coordinates = [[[x, y], [x + w, y], [x + w, y + h], [x, y + h], [x, y]]];
      new_coordinates = [];
      for (_i = 0, _len = coordinates.length; _i < _len; _i++) {
        c = coordinates[_i];
        for (_j = 0, _len1 = c.length; _j < _len1; _j++) {
          coordinate = c[_j];
          new_coordinate = fabric.util.rotatePoint(new fabric.Point(coordinate[0], coordinate[1]), new fabric.Point(this.left_cm / 100, this.top_cm / 100), fabric.util.degreesToRadians(this.angle));
          new_coordinates.push([-new_coordinate.x, new_coordinate.y]);
        }
      }
      data = {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [new_coordinates]
        },
        "properties": {
          "type": this.type,
          "left_cm": this.left_cm,
          "top_cm": this.top_cm,
          "id": this.id,
          "angle": this.angle,
          "fill": this.fill,
          "stroke": this.stroke,
          "minor": this.minor
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
          },
          minor: {
            type: "integer"
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

//# sourceMappingURL=beacon.js.map
