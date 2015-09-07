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
    log(options);
    log(Haikalayer.__super__.constructor.apply(this, arguments));
    Haikalayer.__super__.constructor.call(this, options);
    this.on('postcompose', this.postcompose_, this);
    this.setSource(new ol.source.Vector());
  }

  Haikalayer.prototype.setRotation = function(r) {
    this.rotation = r;
    return this.changed();
  };

  Haikalayer.prototype.postcompose_ = function(event) {
    var context, height, pixelRatio, width;
    context = event.context;
    pixelRatio = event.frameState.pixelRatio;
    width = context.canvas.width;
    height = context.canvas.height;
    if (haika.canvas != null) {
      return haika.render();
    } else {
      haika.init({
        'canvasId': context.canvas
      });
      return $.ajax({
        url: 'data/calil.json',
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

  return Haikalayer;

})(ol.layer.Vector);

fabric.Object.prototype.globalCompositeOperation = 'darker';

haika.addObject('shelf', 0, fabric.Shelf);

haika.addObject('curved_shelf', 0, fabric.curvedShelf);

haika.addObject('beacon', 1, fabric.Beacon);

haika.addObject('wall', 2, fabric.Wall);

haika.addObject('floor', 3, fabric.Floor);
