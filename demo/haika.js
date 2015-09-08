var haika, log;

log = function(obj) {
  try {
    return console.log(obj);
  } catch (_error) {}
};

haika = {
  INSTALLED_OBJECTS: {},
  addObject: function(name, layer, klass) {
    return this.INSTALLED_OBJECTS[name] = {
      'layer': layer,
      'class': klass
    };
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
    scaleFactor: 1,
    layer: 0,
    readOnly: false
  },
  init: function(options) {
    var $haikaDiv, canvas, fabricCanvasClass;
    options = $.extend(this.options, options);
    this.scaleFactor = options.scaleFactor;
    this.layer = options.layer;
    this.readOnly = options.readOnly;
    $haikaDiv = $('#' + options.divId);
    if (this.readOnly) {
      fabricCanvasClass = fabric.StaticCanvas;
    } else {
      fabricCanvasClass = fabric.Canvas;
    }
    canvas = new fabricCanvasClass(options.canvasId, {
      width: $haikaDiv.width(),
      height: $haikaDiv.height()
    });
    canvas.selectionBorderColor = 'black';
    canvas.selectionLineWidth = 1;
    canvas.selectionDashArray = [2, 2];
    fabric.Object.prototype.scaleX = 1;
    fabric.Object.prototype.scaleY = 1;
    fabric.Object.prototype.originX = 'center';
    fabric.Object.prototype.originY = 'center';
    fabric.Object.prototype.transparentCorners = true;
    fabric.Object.prototype.cornerColor = "#488BD4";
    fabric.Object.prototype.borderOpacityWhenMoving = 0.8;
    fabric.Object.prototype.cornerSize = 10;
    this.canvas = canvas;
    this.canvas.on('object:selected', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        if (object._objects != null) {
          object.lockScalingX = true;
          return object.lockScalingY = true;
        }
      };
    })(this));
    this.canvas.on('object:rotating', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        if (object.__rotating != null) {
          return object.__rotating();
        }
      };
    })(this));
    this.canvas.on('object:moving', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        if (_this.readOnly) {
          return;
        }
        if (object.__moving != null) {
          return object.__moving();
        }
      };
    })(this));
    this.canvas.on('object:scaling', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        if (object.__resizeShelf != null) {
          return object.__resizeShelf();
        }
      };
    })(this));
    return this.canvas.on('object:modified', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        if (object.__modifiedShelf != null) {
          object.__modifiedShelf();
        }
        return _this._save();
      };
    })(this));
  },
  _save: function(object) {
    var group, i, len, o, ref;
    log('save');
    object = this.canvas.getActiveObject();
    group = this.canvas.getActiveGroup();
    if (group) {
      ref = group.objects;
      for (i = 0, len = ref.length; i < len; i++) {
        object = ref[i];
        o = $.extend({}, object);
        group._setObjectPosition(o);
        this.setGeoJSONFromObject(o);
      }
    } else {
      this.setGeoJSONFromObject(object);
    }
    if (this.save != null) {
      return this.save();
    }
  },
  setGeoJSONFromObject: function(object) {
    var feature, o;
    object.top_cm = this.px2cm_y(object.top);
    object.left_cm = this.px2cm_x(object.left);
    o = this.locateObjectFromId(object.id);
    feature = object.toGeoJSON();
    $.extend(o.geometry, feature.geometry);
    return $.extend(o.properties, feature.properties);
  },
  locateObjectFromId: function(id) {
    var i, len, o, ref;
    ref = this._geojson.features;
    for (i = 0, len = ref.length; i < len; i++) {
      o = ref[i];
      if (o.properties.id === id) {
        log(o);
        return o;
      }
    }
    return false;
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
      return '認識できないオブジェクト(' + type + ')が含まれています';
    }
  },
  render: function() {
    var i, len, o, ref;
    this.canvas.renderOnAddRemove = false;
    this.canvas._objects.length = 0;
    ref = this.objects;
    for (i = 0, len = ref.length; i < len; i++) {
      o = ref[i];
      if (this.layer === this.INSTALLED_OBJECTS[o.type].layer) {
        o.selectable = true;
      } else {
        o.selectable = false;
      }
      this.addObjectToCanvas(o);
    }
    this.canvas.renderAll(true);
    this.canvas.renderOnAddRemove = true;
    return $(this).trigger('haika:render');
  },
  addObjectToCanvas: function(o) {
    var klass, object;
    klass = this.getClass(o.type);
    if (typeof klass !== 'function') {
      return log(klass);
    }
    object = new klass(o);
    object.width = object.__width();
    object.height = object.__height();
    object.top = this.cm2px_y(o.top_cm);
    object.left = this.cm2px_x(o.left_cm);
    object.selectable = o.selectable;
    return this.canvas.add(object);
  }
};
