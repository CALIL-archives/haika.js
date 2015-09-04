var Haikagrid,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Haikagrid = (function(superClass) {
  extend(Haikagrid, superClass);

  Haikagrid.prototype.map = null;

  Haikagrid.prototype.origin = [0, 0];

  Haikagrid.prototype.img = null;

  Haikagrid.prototype.rotation = 0;

  function Haikagrid(options) {
    Haikagrid.__super__.constructor.call(this, options);
    this.on('postcompose', this.postcompose_, this);
    this.setSource(new ol.source.Vector());
  }

  Haikagrid.prototype.setRotation = function(r) {
    this.rotation = r;
    return this.changed();
  };

  Haikagrid.prototype.postcompose_ = function(event) {
    var a, b, c, context, cx, cy, d, height, i, j, matrix, origin, origin_xy, pixelRatio, r, r2, resolutionAtCoords, size, width;
    if (this.map == null) {
      return;
    }
    context = event.context;
    pixelRatio = event.frameState.pixelRatio;
    width = context.canvas.width;
    height = context.canvas.height;
    resolutionAtCoords = this.map.getView().getProjection().getPointResolution(event.frameState.viewState.resolution, this.origin);
    r = event.frameState.viewState.rotation;
    r2 = this.rotation * Math.PI / 180;
    size = (1 / resolutionAtCoords) * pixelRatio;
    matrix = function(x, y, cx, cy, r) {
      var ax, ay, x_, y_;
      x_ = x - cx;
      y_ = y - cy;
      ax = x_ * Math.cos(r) - y_ * Math.sin(r) + cx;
      ay = x_ * Math.sin(r) + y_ * Math.cos(r) + cy;
      return {
        x: ax,
        y: ay
      };
    };
    cx = width / 2;
    cy = height / 2;
    origin_xy = this.map.getPixelFromCoordinate(this.origin);
    origin = matrix(origin_xy[0], origin_xy[1], cx, cy, -r);
    context.save();
    a = matrix(origin.x, origin.y, cx, cy, r);
    a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2);
    context.translate(a.x, a.y);
    context.rotate(r2);
    context.rotate(r);
    context.restore();
    context.save();
    if (size >= 10) {
      context.beginPath();
      context.lineWidth = 0.4;
      context.strokeStyle = '#B8BFD4';
      for (i = j = -50; j <= 50; i = ++j) {
        if (i === 0) {
          continue;
        }
        a = matrix(origin.x + i * size, origin.y - 50 * size, cx, cy, r);
        a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2);
        b = matrix(origin.x + i * size, origin.y + 50 * size, cx, cy, r);
        b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2);
        context.moveTo(a.x, a.y);
        context.lineTo(b.x, b.y);
        a = matrix(origin.x - 50 * size, origin.y + i * size, cx, cy, r);
        a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2);
        b = matrix(origin.x + 50 * size, origin.y + i * size, cx, cy, r);
        b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2);
        context.moveTo(a.x, a.y);
        context.lineTo(b.x, b.y);
      }
      context.stroke();
      i = 0;
      context.lineWidth = 1;
      context.beginPath();
      a = matrix(origin.x + i * size, origin.y - 50 * size, cx, cy, r);
      a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2);
      b = matrix(origin.x + i * size, origin.y + 50 * size, cx, cy, r);
      b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2);
      context.moveTo(a.x, a.y);
      context.lineTo(b.x, b.y);
      a = matrix(origin.x - 50 * size, origin.y + i * size, cx, cy, r);
      a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2);
      b = matrix(origin.x + 50 * size, origin.y + i * size, cx, cy, r);
      b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2);
      context.moveTo(a.x, a.y);
      context.lineTo(b.x, b.y);
      context.stroke();
    } else {
      a = matrix(origin.x - 50 * size, origin.y - 50 * size, cx, cy, r);
      a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2);
      b = matrix(origin.x - 50 * size, origin.y + 50 * size, cx, cy, r);
      b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2);
      c = matrix(origin.x + 50 * size, origin.y + 50 * size, cx, cy, r);
      c = matrix(c.x, c.y, origin_xy[0], origin_xy[1], r2);
      d = matrix(origin.x + 50 * size, origin.y - 50 * size, cx, cy, r);
      d = matrix(d.x, d.y, origin_xy[0], origin_xy[1], r2);
      context.beginPath();
      context.moveTo(a.x, a.y);
      context.lineTo(b.x, b.y);
      context.lineTo(c.x, c.y);
      context.lineTo(d.x, d.y);
      context.closePath();
      context.fillStyle = 'rgba(0,0,0,0.03)';
      context.fill();
    }
    context.beginPath();
    context.strokeStyle = '#ff0000';
    context.lineWidth = 2;
    context.arc(origin_xy[0], origin_xy[1], 5, 0, 2 * Math.PI, true);
    context.fillStyle = '#ffffff';
    context.fill();
    context.stroke();
    context.beginPath();
    a = matrix(origin.x, origin.y - 7, cx, cy, r);
    b = matrix(origin.x, origin.y - 150, cx, cy, r);
    c = matrix(origin.x - 8, origin.y - 140, cx, cy, r);
    d = matrix(origin.x + 8, origin.y - 140, cx, cy, r);
    context.moveTo(a.x, a.y);
    context.lineTo(b.x, b.y);
    context.moveTo(b.x, b.y);
    context.lineTo(c.x, c.y);
    context.moveTo(b.x, b.y);
    context.lineTo(d.x, d.y);
    context.strokeStyle = '#ffffff';
    context.lineWidth = 4;
    context.stroke();
    context.strokeStyle = '#888888';
    context.lineWidth = 2;
    context.stroke();
    context.fillStyle = "#555555";
    context.textAlign = "center";
    context.textBaseline = "middle";
    context.font = "13px 'Courier New'";
    context.lineWidth = 3;
    context.strokeStyle = '#ffffff';
    b = matrix(origin.x, origin.y - 160, cx, cy, r);
    context.strokeText("北", b.x, b.y);
    context.fillText("北", b.x, b.y);
    context.restore();
    context.beginPath();
    a = matrix(origin.x, origin.y - 5, cx, cy, r);
    a = matrix(a.x, a.y, origin_xy[0], origin_xy[1], r2);
    b = matrix(origin.x, origin.y - 100, cx, cy, r);
    b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2);
    c = matrix(origin.x - 8, origin.y - 90, cx, cy, r);
    c = matrix(c.x, c.y, origin_xy[0], origin_xy[1], r2);
    d = matrix(origin.x + 8, origin.y - 90, cx, cy, r);
    d = matrix(d.x, d.y, origin_xy[0], origin_xy[1], r2);
    context.moveTo(a.x, a.y);
    context.lineTo(b.x, b.y);
    context.moveTo(b.x, b.y);
    context.lineTo(c.x, c.y);
    context.moveTo(b.x, b.y);
    context.lineTo(d.x, d.y);
    context.strokeStyle = '#ffffff';
    context.lineWidth = 4;
    context.stroke();
    context.strokeStyle = '#ff0000';
    context.lineWidth = 2;
    context.stroke();
    context.fillStyle = "#555555";
    context.textAlign = "left";
    context.textBaseline = "middle";
    context.font = "13px 'Courier New'";
    context.lineWidth = 3;
    context.strokeStyle = '#ffffff';
    context.strokeText("基準点", origin_xy[0] + 10, origin_xy[1]);
    context.fillText("基準点", origin_xy[0] + 10, origin_xy[1]);
    context.fillStyle = "#555555";
    context.textAlign = "center";
    context.textBaseline = "middle";
    context.font = "13px 'Courier New'";
    context.lineWidth = 3;
    context.strokeStyle = '#ffffff';
    b = matrix(origin.x, origin.y - 110, cx, cy, r);
    b = matrix(b.x, b.y, origin_xy[0], origin_xy[1], r2);
    context.strokeText("建物方向", b.x, b.y);
    context.fillText("建物方向", b.x, b.y);
    context.restore();
    "debugText = \"[Gridlines]\"\ncontext.save()\ncontext.fillStyle = \"rgba(255, 255, 255, 0.6)\"\ncontext.fillRect(0, context.canvas.height - 20, context.canvas.width, 20)\ncontext.font = \"10px\"\ncontext.fillStyle = \"black\"\ncontext.fillText(debugText, 10, context.canvas.height - 7)\ncontext.restore()";
    if (haika.canvas != null) {
      return haika.render();
    } else {
      haika.init({
        'canvasId': context.canvas
      });
      return $.ajax({
        url: 'data/sabae.json',
        type: 'GET',
        cache: false,
        dataType: 'json',
        error: (function(_this) {
          return function() {
            return option.error && option.error('データが読み込めませんでした');
          };
        })(this),
        success: (function(_this) {
          return function(json) {
            if (json.locked) {
              _this.readOnly = true;
              return option.error && option.error('データはロックされています');
            }
            haika._dataId = json.id;
            haika._revision = json.revision;
            haika._collision = json.collision;
            haika._geojson = json.data;
            haika.loadFromGeoJson();
            $(haika).trigger('haika:load');
            return haika.render();
          };
        })(this)
      });
    }
  };

  return Haikagrid;

})(ol.layer.Vector);
