(function(global) {
  "use strict";
  var degreesToRadians, fabric;
  fabric = global.fabric || (global.fabric = {});
  degreesToRadians = fabric.util.degreesToRadians;
  if (fabric.Floor) {
    console.warn("fabric.Floor is already defined");
    return;
  }
  fabric.Floor = fabric.util.createClass(fabric.Rect, {
    type: "floor",
    width_cm: 1000,
    height_cm: 1000,
    is_negative: false,
    fill: '#ffffff',
    stroke: '#000000',
    strokeDashArray: [2, 2],
    __width: function() {
      return this.width_cm * haika.scaleFactor;
    },
    __height: function() {
      return this.height_cm * haika.scaleFactor;
    },
    initialize: function(options) {
      if (options == null) {
        options = {};
      }
      this.callSuper("initialize", options);
      this.width = this.__width();
      this.height = this.__height();
    },
    _render: function(ctx, noTransform) {
      var h, label, metrics, rx, ry, w, x, y;
      if (!this.selectable) {
        return;
      }
      rx = this.rx ? Math.min(this.rx, this.width / 2) : 0;
      ry = this.ry ? Math.min(this.ry, this.height / 2) : 0;
      w = this.width;
      h = this.height;
      x = noTransform ? this.left : -this.width / 2;
      y = noTransform ? this.top : -this.height / 2;
      ctx.save();
      if (this.is_negative) {
        ctx.fillStyle = '#353535';
      } else {
        ctx.fillStyle = 'rgba(255,0,0,0.3)';
      }
      ctx.beginPath();
      ctx.moveTo(x + rx, y);
      ctx.lineTo(x + w - rx, y);
      ctx.lineTo(x + w, y + h - ry);
      ctx.lineTo(x + rx, y + h);
      ctx.lineTo(x, y + ry);
      ctx.closePath();
      this._renderFill(ctx);
      if (this.selectable) {
        this._renderStroke(ctx);
        ctx.scale(1 / this.scaleX, 1 / this.scaleY);
        if (this.angle > 90 && this.angle < 270) {
          ctx.rotate(degreesToRadians(180));
        }
        if (this.is_negative) {
          ctx.fillStyle = '#999999';
          label = '吹き抜け';
        } else {
          ctx.fillStyle = '#000000';
          label = 'フロア指定';
        }
        ctx.font = "12px Arial";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        metrics = ctx.measureText(label);
        if (metrics.width <= this.__width()) {
          ctx.fillText(label, 0, 0);
        } else if (metrics.width <= this.__height()) {
          ctx.rotate(degreesToRadians(90));
          ctx.fillText(label, 0, 0);
        }
      }
      ctx.restore();
    },
    __resizeShelf: function() {
      return this.set({
        flipX: false,
        flipY: false
      });
    },
    __modifiedShelf: function() {
      this.angle = Math.floor(this.angle % 360);
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
      if (this.scaleX !== 1) {
        this.width = this.width * this.scaleX;
        this.width_cm = Math.floor(this.width / haika.scaleFactor);
      }
      if (this.scaleY !== 1) {
        this.height = this.height * this.scaleY;
        this.height_cm = Math.floor(this.height / haika.scaleFactor);
      }
      this.scaleX = this.scaleY = 1;
      return this.setCoords();
    },
    toGeoJSON: function() {
      var coordinate, data, h, i, left_cm, len, new_coordinate, new_coordinates, ref, top_cm, w, x, y;
      w = this.width_cm;
      h = this.height_cm;
      left_cm = this.left_cm;
      top_cm = this.top_cm;
      x = -w / 2 + left_cm;
      y = -h / 2 + top_cm;
      new_coordinates = [];
      ref = [[x, y], [x + w, y], [x + w, y + h], [x, y + h], [x, y]];
      for (i = 0, len = ref.length; i < len; i++) {
        coordinate = ref[i];
        new_coordinate = fabric.util.rotatePoint(new fabric.Point(coordinate[0], coordinate[1]), new fabric.Point(left_cm, top_cm), fabric.util.degreesToRadians(this.angle));
        new_coordinates.push([new_coordinate.x, -new_coordinate.y]);
      }
      data = {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [new_coordinates]
        },
        "properties": {
          "id": this.id,
          "type": this.type,
          "left_cm": left_cm,
          "top_cm": top_cm,
          "width_cm": this.width_cm,
          "height_cm": this.height_cm,
          "angle": this.angle,
          "is_negative": this.is_negative
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
          angle: {
            type: "integer",
            "default": 0,
            minimum: 0,
            maximum: 360
          },
          width_cm: {
            type: "number",
            "default": 1
          },
          height_cm: {
            type: "number",
            "default": 1
          },
          is_negative: {
            type: "boolean",
            "default": false
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
