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
    var context, log;
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
      if (window.rect) {
        rect.fill = 'blue';
      }
    } else {
      window.canvas = new fabric.Canvas(context.canvas);
      canvas._renderAll = canvas.renderAll;
      canvas.renderAll = (function(_this) {
        return function() {
          return _this.changed();
        };
      })(this);
      window.rect = new fabric.Rect({
        left: 400,
        top: 100,
        fill: 'red',
        width: 400,
        height: 400,
        angle: 45
      });
      canvas.renderOnAddRemove = true;
      canvas.add(rect);
    }
    return canvas._renderAll(true);
  };

  return Haikalayer;

})(ol.layer.Vector);
