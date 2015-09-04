(function(global) {
  var extend, fabric;
  fabric = global.fabric || (global.fabric = {});
  extend = fabric.util.object.extend;
  if (fabric.Wall) {
    console.warn("fabric.Wall is already defined");
    return;
  }
  fabric.Wall = fabric.util.createClass(fabric.Rect, {
    type: "wall",
    eachWidth: 100,
    eachHeight: 100,
    width_scale: 1,
    height_scale: 1,
    __width: function() {
      return this.eachWidth * this.width_scale * haika.scaleFactor;
    },
    __height: function() {
      return this.eachHeight * this.height_scale * haika.scaleFactor;
    },
    initialize: function(options) {
      options = options || {};
      this.callSuper("initialize", options);
      this.width = this.__width();
      this.height = this.__height();
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
      if (this.sacleX !== 1) {
        this.width = this.width * this.scaleX;
        this.width_scale = this.width / (this.eachWidth * haika.scaleFactor);
      }
      if (this.sacleY !== 1) {
        this.height = this.height * this.scaleY;
        this.height_scale = this.height / (this.eachHeight * haika.scaleFactor);
      }
      this.scaleX = this.scaleY = 1;
      return this.setCoords();
    },
    toGeoJSON: function() {
      var c, coordinate, coordinates, data, h, i, j, len, len1, new_coordinate, new_coordinates, w, x, y;
      w = this.eachWidth * this.width_scale;
      h = this.eachHeight * this.height_scale;
      x = -w / 2 + this.left_cm;
      y = -h / 2 + this.top_cm;
      coordinates = [[[x, y], [x + w, y], [x + w, y + h], [x, y + h], [x, y]]];
      new_coordinates = [];
      for (i = 0, len = coordinates.length; i < len; i++) {
        c = coordinates[i];
        for (j = 0, len1 = c.length; j < len1; j++) {
          coordinate = c[j];
          new_coordinate = fabric.util.rotatePoint(new fabric.Point(coordinate[0], coordinate[1]), new fabric.Point(this.left_cm, this.top_cm), fabric.util.degreesToRadians(this.angle));
          new_coordinates.push([new_coordinate.x, -new_coordinate.y]);
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
          "width_scale": this.width_scale,
          "height_scale": this.height_scale
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
          width_scale: {
            type: "number",
            "default": 1
          },
          height_scale: {
            type: "number",
            "default": 1
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
