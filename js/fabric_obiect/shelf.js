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
  stateProperties.push("id", "count", "side", "top_cm", "left_cm", "eachWidth", "eachHeight", "label");
  fabric.Shelf = fabric.util.createClass(fabric.Object, {
    stateProperties: stateProperties,
    type: "shelf",
    eachWidth: 90,
    eachHeight: 25,
    __width: function() {
      return this.__eachWidth() * this.count;
    },
    __height: function() {
      return this.__eachHeight() * this.side;
    },
    __eachWidth: function() {
      return this.eachWidth * haika.scale;
    },
    __eachHeight: function() {
      return this.eachHeight * haika.scale;
    },
    count: 1,
    side: 1,
    label: '',
    minScaleLimit: 1,
    strokeDashArray: null,
    initialize: function(options) {
      options = options || {};
      this.callSuper("initialize", options);
      this.width = this.__width();
      this.height = this.__height();
    },
    _render: function(ctx) {
      var h, isInPathGroup, label, sx, w, x, y;
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
      if (this.side === 1) {
        this.__renderShelf(ctx, x, y, w, h);
        if (haika.scale > 0.5) {
          this.__renderSide(ctx, x, y, w, h);
        }
      }
      if (this.side === 2) {
        this.__renderShelf(ctx, x, y, w, h);
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
      var total_width;
      total_width = w * this.count;
      this.__renderRect(ctx, x, y, total_width, h);
      this.__renderPartitionLine(ctx, x, y, w, h);
      if (this.side === 2) {
        this.__renderRect(ctx, x, y + h, total_width, h);
        return this.__renderPartitionLine(ctx, x, y + h, w, h);
      }
    },
    __renderRect: function(ctx, x, y, w, h) {
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(x, y);
      ctx.lineTo(x + w, y);
      ctx.lineTo(x + w, y + h);
      ctx.lineTo(x, y + h);
      ctx.lineTo(x, y);
      ctx.closePath();
      this._renderFill(ctx);
      return this._renderStroke(ctx);
    },
    __renderPartitionLine: function(ctx, x, y, w, h) {
      var i;
      if (this.count <= 1) {
        return;
      }
      ctx.lineWidth = 1;
      ctx.beginPath();
      i = 1;
      while (i < this.count) {
        ctx.moveTo(x + w * i, y);
        ctx.lineTo(x + w * i, y + h);
        i++;
      }
      ctx.closePath();
      return this._renderStroke(ctx);
    },
    __renderSide: function(ctx, x, y, w, h) {
      ctx.lineWidth = 5;
      ctx.beginPath();
      ctx.moveTo(x, y + h - 1);
      ctx.lineTo(x + w * this.count, y + h - 1);
      ctx.closePath();
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
        count: this.get("count"),
        side: this.get("side")
      });
      if (!this.includeDefaultValues) {
        this._removeDefaultValues(object);
      }
      return object;
    },
    toGeoJSON: function() {
      var c, coordinate, coordinates, data, h, new_coordinate, new_coordinates, w, x, y, _i, _j, _len, _len1;
      w = this.eachWidth * this.count / 100;
      h = this.eachHeight * this.side / 100;
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
          "label": this.label ? this.label : "",
          "type": this.type,
          "left_cm": this.left_cm,
          "top_cm": this.top_cm,
          "eachWidth": this.eachWidth,
          "eachHeight": this.eachHeight,
          "id": this.id,
          "count": this.count,
          "side": this.side,
          "angle": this.angle,
          "fill": this.fill,
          "stroke": this.stroke
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
      w = this.eachWidth;
      h = this.eachHeight;
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
          markup.push("<rect x=\"" + ((-1 * this.width / 2) + this.width / count * i) + "\" y=\"" + ((-1 * this.height / 2) + this.eachHeight) + "\" rx=\"" + (this.get("rx")) + "\" ry=\"" + (this.get("ry")) + "\" width=\"" + (this.width / count) + "\" height=\"" + (this.height / 2) + "\" style=\"" + (this.getSvgStyles()) + "\" transform=\"" + (this.getSvgTransform()) + "\"/>");
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
    getJsonSchema: function() {
      var schema;
      schema = {
        title: "基本情報",
        type: "object",
        properties: {
          label: {
            title: "ラベル",
            type: "string",
            "default": ""
          },
          count: {
            title: "連数",
            type: "integer",
            "default": 3,
            minimum: 1,
            maximum: 10
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
          },
          eachWidth: {
            type: "integer",
            "default": 90,
            minimum: 1
          },
          eachHeight: {
            type: "integer",
            "default": 25,
            minimum: 1
          }
        }
      };
      return schema;
    },
    complexity: function() {
      return 1;
    }
  });
  fabric.Shelf.ATTRIBUTE_NAMES = fabric.SHARED_ATTRIBUTES.concat("width height count side".split(" "));
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

//# sourceMappingURL=shelf.js.map
