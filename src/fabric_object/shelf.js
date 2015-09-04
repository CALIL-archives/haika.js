(function(global) {
  var extend, fabric, stateProperties;
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
    count: 1,
    side: 1,
    label: '',
    __width: function() {
      return this.__eachWidth() * this.count;
    },
    __height: function() {
      return this.__eachHeight() * this.side;
    },
    __eachWidth: function() {
      return this.eachWidth * haika.scaleFactor;
    },
    __eachHeight: function() {
      return this.eachHeight * haika.scaleFactor;
    },
    minScaleLimit: 1,
    strokeDashArray: null,
    fill: '#ffffff',
    stroke: '#afafaf',
    initialize: function(options) {
      options = options || {};
      this.callSuper("initialize", options);
      this.width = this.__width();
      this.height = this.__height();
      this.transparentCorners = false;
      this.cornerColor = '#ffffff';
    },
    _render: function(ctx) {
      var h, isInPathGroup, label, sx, sy, w, x, y;
      ctx.save();
      this.lineWidth = 1;
      if (this.selectable) {
        if (this.active) {
          this.fill = 'rgba(255,77,77,1)';
          this.stroke = 'rgba(0,0,0,1)';
        } else {
          this.fill = 'rgba(255,77,77,1)';
          this.stroke = 'rgba(50,50,50,1)';
        }
      } else {
        this.fill = '#ffffff';
        this.stroke = '#afafaf';
      }
      ctx.strokeWidth = 1;
      ctx.strokeStyle = this.stroke;
      ctx.fillStyle = this.fill;
      ctx.scale(1 / this.scaleX, 1 / this.scaleY);
      sx = 0;
      if (this.scaleX !== 0 && (this.__corner === 'mr' || this.__corner === 'tr' || this.__corner === 'br')) {
        sx = (this.count * this.__eachWidth() - this.width * this.scaleX) / 2;
      }
      if (this.scaleX !== 0 && (this.__corner === 'ml' || this.__corner === 'tl' || this.__corner === 'bl')) {
        sx = -1 * (this.count * this.__eachWidth() - this.width * this.scaleX) / 2;
      }
      sy = 0;
      if (this.scaleY !== 0 && (this.__corner === 'mb')) {
        sy = (this.side * this.__eachHeight() - this.height * this.scaleY) / 2;
      }
      if (this.scaleY !== 0 && (this.__corner === 'mt')) {
        sy = -1 * (this.side * this.__eachHeight() - this.height * this.scaleY) / 2;
      }
      w = this.__eachWidth();
      h = this.__eachHeight();
      x = -w / 2 * this.count + sx;
      y = -h / 2 * this.side + sy;
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
        if (haika.scaleFactor > 0.5) {
          this.__renderSide(ctx, x, y, w, h);
        }
      }
      if (this.side === 2) {
        this.__renderShelf(ctx, x, y, w, h);
      }
      if (this.active && !this.isMoving) {
        ctx.font = "12px Arial";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.fillStyle = 'rgba(0, 0, 0,1)';
        label = this.side === 1 ? "単式" : "複式";
        label = "[" + this.id + "] " + label + this.count + "連";
        ctx.fillText(label, 0, (this.height * this.scaleY) / 2 + 15);
      }
      if (this.label) {
        ctx.font = "14px Arial";
        ctx.textBaseline = "middle";
        ctx.fillStyle = 'rgba(0, 0, 0,1)';
        if (this.top_cm > 0) {
          ctx.textAlign = "right";
          ctx.fillText(this.label, -(this.width * this.scaleX) / 2 - 5, 0);
        } else {
          ctx.textAlign = "left";
          ctx.fillText(this.label, (this.width * this.scaleX) / 2 + 5, 0);
        }
      }
      ctx.restore();
    },
    __renderShelf: function(ctx, x, y, w, h) {
      this.__renderRect(ctx, x, y, w * this.count, h);
      this.__renderPartitionLine(ctx, x, y, w, h);
      if (this.side === 2) {
        this.__renderRect(ctx, x, y + h, w * this.count, h);
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
      if (this.count === 1) {
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
    __rotating: function() {
      log('__rotating');
      if (Math.abs(this.originalState.angle - this.angle) > 20 || Math.abs(this.originalState.angle - this.angle) < 5) {
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
          return this.angle = 270;
        }
      }
    },
    __moving: function() {
      this.left = Math.round(this.left / haika.scaleFactor / 10) * 10 * haika.scaleFactor;
      return this.top = Math.round(this.top / haika.scaleFactor / 10) * 10 * haika.scaleFactor;
    },
    __resizeShelf: function() {
      var count, currentHeight, currentWidth, p, side;
      log('__resizeShelf');
      p = this._calculateCurrentDimensions(false);
      currentWidth = p.x;
      currentHeight = p.y;
      count = Math.floor(currentWidth / this.__eachWidth());
      if (count < 1) {
        count = 1;
      }
      if (count > 15) {
        count = 15;
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
      var th;
      this.centeredScaling = false;
      log('__modifiedShelf');
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
      if (this.scaleY !== 0 && (this.__corner === 'mb')) {
        th = this.angle * (Math.PI / 180);
        this.left = this.left + Math.sin(th) * (this.side * this.__eachHeight() - this.height * this.scaleY) / 2;
        this.top = this.top + Math.cos(th) * (this.side * this.__eachHeight() - this.height * this.scaleY) / 2;
      }
      if (this.scaleY !== 0 && (this.__corner === 'mt')) {
        th = this.angle * (Math.PI / 180);
        this.left = this.left - Math.sin(th) * (this.side * this.__eachHeight() - this.height * this.scaleY) / 2;
        this.top = this.top - Math.cos(th) * (this.side * this.__eachHeight() - this.height * this.scaleY) / 2;
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
        side: this.get("side"),
        label: this.get("label")
      });
      if (!this.includeDefaultValues) {
        this._removeDefaultValues(object);
      }
      return object;
    },
    toGeoJSON: function() {
      var coordinate, data, h, j, len, new_coordinate, new_coordinates, ref, w, x, y;
      w = this.eachWidth * this.count;
      h = this.eachHeight * this.side;
      x = -w / 2 + this.left_cm;
      y = -h / 2 + this.top_cm;
      new_coordinates = [];
      ref = [[x, y], [x + w, y], [x + w, y + h], [x, y + h], [x, y]];
      for (j = 0, len = ref.length; j < len; j++) {
        coordinate = ref[j];
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
          "eachWidth": this.eachWidth,
          "eachHeight": this.eachHeight,
          "id": this.id,
          "count": this.count,
          "side": this.side,
          "angle": this.angle,
          "label": this.label
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
            maximum: 15
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
          },
          label: {
            type: "string"
          }
        }
      };
      return schema;
    },
    complexity: function() {
      return 1;
    }
  });
  fabric.Shelf.fromObject = function(object) {
    return new fabric.Shelf(object);
  };
})((typeof exports !== "undefined" ? exports : this));
