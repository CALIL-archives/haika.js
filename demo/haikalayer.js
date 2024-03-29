var Haikalayer,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Haikalayer = (function(superClass) {
  extend(Haikalayer, superClass);

  Haikalayer.prototype.map = null;

  Haikalayer.prototype.origin = [0, 0];

  Haikalayer.prototype.img = null;

  Haikalayer.prototype.rotation = 0;

  function Haikalayer(options) {
    Haikalayer.__super__.constructor.call(this, options);
    this.on('postcompose', this.postcompose_, this);
    this.setSource(new ol.source.Vector());
  }

  Haikalayer.prototype.setRotation = function(r) {
    this.rotation = r;
    return this.changed();
  };

  Haikalayer.prototype.postcompose_ = function(event) {
    var blue, context, log, red;
    if (this.map == null) {
      return;
    }
    context = event.context;
    log = function(obj) {
      try {
        return console.log(obj);
      } catch (_error) {}
    };
    if (window.canvas != null) {

    } else {
      window.canvas = new fabric.Canvas(context.canvas);
      canvas._renderAll = canvas.renderAll;
      canvas.renderAll = (function(_this) {
        return function() {
          return _this.changed();
        };
      })(this);
      canvas.renderTop = (function(_this) {
        return function() {
          return _this.changed();
        };
      })(this);
      canvas._renderAllFix = function() {
        var activeGroup, canvasToDrawOn;
        canvasToDrawOn = this.contextTop;
        activeGroup = this.getActiveGroup();
        this.clearContext(this.contextTop);
        this.fire('before:render');
        if (this.clipTo) {
          fabric.util.clipContext(this, canvasToDrawOn);
        }
        this._renderBackground(canvasToDrawOn);
        this._renderObjects(canvasToDrawOn, activeGroup);
        this._renderActiveGroup(canvasToDrawOn, activeGroup);
        if (this.selection && this._groupSelector) {
          this._drawSelection();
        }
        if (this.clipTo) {
          canvasToDrawOn.restore();
        }
        this._renderOverlay(canvasToDrawOn);
        if (this.controlsAboveOverlay && this.interactive) {
          this.drawControls(canvasToDrawOn);
        }
        this.fire('after:render');
        return this;
      };
      red = new fabric.Rect({
        left: 400,
        top: 100,
        fill: 'red',
        width: 400,
        height: 400,
        angle: 45
      });
      blue = new fabric.Rect({
        left: 800,
        top: 100,
        fill: 'blue',
        width: 400,
        height: 400,
        angle: 45
      });
      canvas.renderOnAddRemove = true;
      canvas.add(red);
      canvas.add(blue);
    }
    return canvas._renderAllFix();
  };

  return Haikalayer;

})(ol.layer.Vector);
