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
  stateProperties.push("id", "top_cm", "left_cm", "lane", "index");
  fabric.Beacon = fabric.util.createClass(fabric.Object, {
    stateProperties: stateProperties,
    type: "beacon",
    eachWidth: 10,
    eachHeight: 10,
    hasControls: false,
    padding: 10,
    lane: "main",
    index: 0,
    minor: 0,
    __width: function() {
      return this.eachWidth * haika.scaleFactor;
    },
    __height: function() {
      return this.eachHeight * haika.scaleFactor;
    },
    initialize: function(options) {
      options = options || {};
      this.callSuper("initialize", options);
      this.width = this.__width();
      this.height = this.__height();
    },
    _render: function(ctx) {
      var label;
      ctx.beginPath();
      ctx.fillRect(this.width / 2 * (-1), this.height / 2 * (-1), this.width, this.height);
      this._renderFill(ctx);
      this._renderStroke(ctx);
      "ctx.fillStyle='rgba(255,0,0,0.02)'\nctx.beginPath()\nctx.arc(0,0, 2000*haika.scaleFactor, 0, Math.PI*2, false);\nctx.fill()\n\n\nctx.fillStyle='rgba(255,0,0,0.08)'\nctx.beginPath()\nctx.arc(0,0, 500*haika.scaleFactor, 0, Math.PI*2, false);\nctx.fill()";
      ctx.font = "12px Arial";
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      ctx.fillStyle = 'rgba(0, 0, 0,1)';
      label = this.minor + '(' + this.lane + ')';
      ctx.fillText(label, 0, (this.height * this.scaleY) / 2 + 15);
    },
    __resizeShelf: function() {
      return this.set({
        flipX: false,
        flipY: false
      });
    },
    __modifiedShelf: function() {
      this.angle = 0;
      this.width = this.__width();
      this.height = this.__height();
      this.setCoords();
      return this.__is_into();
    },
    __is_into: function() {
      var bottom, half_height, half_width, i, left, len, object, objects, results, right, top;
      objects = haika.canvas.getObjects();
      results = [];
      for (i = 0, len = objects.length; i < len; i++) {
        object = objects[i];
        if (object.type.match(/shelf$/)) {
          half_width = object.__width() / 2;
          left = object.left - half_width;
          right = object.left + half_width;
          half_height = object.__height() / 2;
          top = object.top - half_height;
          bottom = object.top + half_height;
          if ((this.left > left && this.left < right) && (this.top > top && this.top < bottom)) {
            results.push(log('into:' + object.id));
          } else {
            results.push(void 0);
          }
        } else {
          results.push(void 0);
        }
      }
      return results;
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
      var data;
      data = {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [this.left_cm, -this.top_cm]
        },
        "properties": {
          "type": this.type,
          "id": this.id,
          "left_cm": this.left_cm,
          "top_cm": this.top_cm,
          "minor": this.minor,
          "lane": this.lane,
          "index": this.index
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
          minor: {
            description: "minor",
            type: "integer"
          },
          lane: {
            description: "レーン名",
            type: "string"
          },
          index: {
            description: "レーンの順番",
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
