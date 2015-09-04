var haika, log;

log = function(obj) {
  try {
    return console.log(obj);
  } catch (_error) {}
};

haika = {
  CONST_LAYERS: {
    SHELF: 0,
    BEACON: 1,
    WALL: 2,
    FLOOR: 3
  },
  INSTALLED_OBJECTS: {
    'shelf': {
      'layer': 0,
      'class': fabric.Shelf
    },
    'curved_shelf': {
      'layer': 0,
      'class': fabric.curvedShelf
    },
    'beacon': {
      'layer': 1,
      'class': fabric.Beacon
    },
    'wall': {
      'layer': 2,
      'class': fabric.Wall
    },
    'floor': {
      'layer': 3,
      'class': fabric.Floor
    }
  },
  canvas: null,
  centerX: 0,
  centerY: 0,
  layer: null,
  scaleFactor: 1,
  objects: [],
  _geojson: {},
  backgroundUrl: null,
  backgroundOpacity: 1,
  backgroundScaleFactor: 1,
  xyLongitude: null,
  xyLatitude: null,
  xyAngle: 0,
  xyScaleFactor: 1,
  clipboard: [],
  cm2px: function(cm) {
    return cm * this.scaleFactor;
  },
  cm2px_x: function(cm) {
    return this.canvas.getWidth() / 2 + (cm + this.centerX) * this.scaleFactor;
  },
  cm2px_y: function(cm) {
    return this.canvas.getHeight() / 2 + (cm + this.centerY) * this.scaleFactor;
  },
  px2cm_x: function(px) {
    return Math.floor((px - this.canvas.getWidth() / 2) / this.scaleFactor - this.centerX);
  },
  px2cm_y: function(px) {
    return Math.floor((px - this.canvas.getHeight() / 2) / this.scaleFactor - this.centerY);
  },
  plugins: [],
  options: {
    containerSelector: '.haika-container',
    divId: 'haika-canvas',
    canvasId: 'haika-canvas-area',
    scaleFactor: 0.1
  },
  init: function(options) {
    var $haikaDiv, canvas;
    options = $.extend(this.options, options);
    this.scaleFactor = options.scaleFactor;
    $haikaDiv = $('#' + options.divId);
    canvas = new fabric.StaticCanvas(options.canvasId, {
      width: $haikaDiv.width(),
      height: $haikaDiv.height(),
      rotationCursor: 'url("img/rotate.cur") 10 10, crosshair'
    });
    canvas.selectionBorderColor = 'black';
    canvas.selectionLineWidth = 1;
    canvas.selectionDashArray = [2, 2];
    $(window).resize((function(_this) {
      return function() {
        _this.canvas.setWidth($haikaDiv.width());
        _this.canvas.setHeight($haikaDiv.height());
        return _this.render();
      };
    })(this));
    fabric.Object.prototype.scaleX = 1;
    fabric.Object.prototype.scaleY = 1;
    fabric.Object.prototype.originX = 'center';
    fabric.Object.prototype.originY = 'center';
    fabric.Object.prototype.transparentCorners = true;
    fabric.Object.prototype.cornerColor = "#488BD4";
    fabric.Object.prototype.borderOpacityWhenMoving = 0.8;
    fabric.Object.prototype.cornerSize = 10;
    return this.canvas = canvas;
  },
  loadFromGeoJson: function() {
    var header, i, len, object, ref, results;
    if (this._geojson.haika != null) {
      header = this._geojson.haika;
    } else {
      header = {};
    }
    this.backgroundScaleFactor = header.backgroundScaleFactor != null ? header.backgroundScaleFactor : 1;
    this.backgroundOpacity = header.backgroundOpacity != null ? header.backgroundOpacity : 1;
    this.backgroundUrl = header.backgroundUrl != null ? header.backgroundUrl : '';
    this.xyAngle = header.xyAngle != null ? header.xyAngle : 0;
    this.xyScaleFactor = header.xyScaleFactor != null ? header.xyScaleFactor : 1;
    this.xyLongitude = header.xyLongitude != null ? header.xyLongitude : null;
    this.xyLatitude = header.xyLatitude != null ? header.xyLatitude : null;
    this.objects = [];
    if (this._geojson.features != null) {
      ref = this._geojson.features;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        object = ref[i];
        results.push(this.objects.push(object.properties));
      }
      return results;
    }
  },
  getClass: function(type) {
    if (this.INSTALLED_OBJECTS[type] != null) {
      return this.INSTALLED_OBJECTS[type]["class"];
    } else {
      throw '認識できないオブジェクトが含まれています';
    }
  },
  render: function() {
    var i, len, o, ref;
    this.canvas.renderOnAddRemove = false;
    this.canvas._objects.length = 0;
    ref = this.objects;
    for (i = 0, len = ref.length; i < len; i++) {
      o = ref[i];
      this.addObjectToCanvas(o);
    }
    this.canvas.renderAll();
    this.canvas.renderOnAddRemove = true;
    return $(this).trigger('haika:render');
  },
  addObjectToCanvas: function(o) {
    var klass, object;
    klass = this.getClass(o.type);
    object = new klass(o);
    object.width = object.__width();
    object.height = object.__height();
    object.top = this.cm2px_y(o.top_cm);
    object.left = this.cm2px_x(o.left_cm);
    object.selectable = o.selectable;
    return this.canvas.add(object);
  }
};
