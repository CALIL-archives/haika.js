(function(global) {
  "use strict";
  var _setDefaultLeftTopValues, extend, fabric, stateProperties;
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
      return 90 * haika.scaleFactor;
    },
    __eachHeight: function() {
      return 25 * haika.scaleFactor;
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
      var count, currentHeight, currentWidth, p, side;
      p = this._calculateCurrentDimensions(false);
      currentWidth = p.x;
      currentHeight = p.y;
      count = Math.floor(currentWidth / this.__eachWidth());
      if (count < 1) {
        count = 1;
      }
      if (count > 20) {
        count = 20;
      }
      side = Math.round(currentHeight / this.__eachHeight());
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
    toGeoJSON: function() {
      var coordinate, data, h, i, len, new_coordinate, new_coordinates, ref, w, x, y;
      w = this.__eachWidth() * this.count;
      h = this.__eachHeight() * this.side;
      x = -w / 2 + this.left_cm;
      y = -h / 2 + this.top_cm;
      new_coordinates = [];
      ref = [[x, y], [x + w, y], [x + w, y + h], [x, y + h], [x, y]];
      for (i = 0, len = ref.length; i < len; i++) {
        coordinate = ref[i];
        new_coordinate = fabric.util.rotatePoint(new fabric.Point(coordinate[0], coordinate[1]), new fabric.Point(this.left_cm, this.top_cm), fabric.util.degreesToRadians(this.angle));
        new_coordinates.push([new_coordinate.x, -new_coordinate.y]);
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
          "count": this.count,
          "side": this.side,
          "angle": this.angle
        }
      };
      return data;
    },
    getJSONSchema: function() {
      var schema;
      schema = {
        title: "基本情報",
        type: "object",
        properties: {
          count: {
            title: "連数",
            type: "integer",
            "default": 3,
            minimum: 1,
            maximum: 12
          },
          side: {
            type: "integer",
            "default": 1,
            minimum: 1,
            maximum: 2
          },
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
