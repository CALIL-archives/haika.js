// Generated by CoffeeScript 1.3.1
var app, log;

log = function(obj) {
  try {
    return console.log(obj);
  } catch (_error) {}
};

app = {
  width: 800,
  height: 800,
  centerX: 0,
  centerY: 0,
  scale: 1,
  objects: [],
  canvas: false,
  drawguideline: true,
  is_moving: false,
  is_scaling: false,
  is_rotating: false,
  bgimg: null,
  bgimg_width: null,
  bgimg_height: null,
  options: {},
  init: function(options) {
    var canvas, default_options,
      _this = this;
    default_options = {
      canvas: 'canvas',
      canvas_width: 800,
      canvas_height: 600,
      max_width: 10000,
      max_height: 10000,
      scale: 1,
      bgurl: null,
      bgopacity: 1,
      bgscale: 1
    };
    this.options = $.extend(default_options, options);
    canvas = new fabric.Canvas(this.options.canvas, {
      rotationCursor: 'url("img/rotate.cur") 10 10, crosshair'
    });
    canvas.setWidth(this.options.canvas_width);
    $('#canvas_width').val(this.options.canvas_width);
    canvas.setHeight(this.options.canvas_height);
    $('#canvas_height').val(this.options.canvas_height);
    canvas._getActionFromCorner = function(target, corner) {
      var action;
      action = 'drag';
      if (corner) {
        if (corner === 'ml' || corner === 'mr' || corner === 'tr' || corner === 'tl' || corner === 'bl' || corner === 'br') {
          action = 'scaleX';
        } else if (corner === 'mt' || corner === 'mb') {
          action = 'scaleY';
        } else if (corner === 'mtr') {
          action = 'rotate';
        }
      }
      return action;
    };
    initAligningGuidelines(canvas);
    this.canvas = canvas;
    this.scale = options.scale;
    if (this.options.bgurl) {
      fabric.Image.fromURL(this.options.bgurl, function(img) {
        _this.bgimg = img;
        _this.bgimg_width = img.width;
        return _this.bgimg_height = img.height;
      });
    }
    setTimeout(function() {
      return _this.load();
    }, 500);
    this.canvas.on('object:selected', function(e) {
      var object, _i, _len, _ref, _results;
      object = e.target;
      if (object._objects != null) {
        object.lockScalingX = true;
        object.lockScalingY = true;
      }
      _ref = _this.canvas.getObjects();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        if (object.id != null) {
          _results.push(_this.save_prop(object));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
    this.canvas.on('before:selection:cleared', function(e) {
      var group, object, objects, _i, _len, _results;
      object = e.target;
      _this.canvas.deactivateAll().renderAll();
      if (object._objects != null) {
        group = object;
        objects = object._objects;
        _results = [];
        for (_i = 0, _len = objects.length; _i < _len; _i++) {
          object = objects[_i];
          _results.push(_this.save_prop(object, group));
        }
        return _results;
      } else {
        return _this.save_prop(object);
      }
    });
    this.canvas.on('object:scaling', function(e) {
      var object;
      object = e.target;
      if (object.__resizeShelf != null) {
        return object.__resizeShelf();
      }
    });
    this.canvas.on('object:modified', function(e) {
      var object;
      object = e.target;
      if (object.__modifiedShelf != null) {
        return object.__modifiedShelf();
      }
    });
    return $(window).on('beforeunload', function(event) {
      _this.render();
      _this.save();
    });
  },
  add: function(object) {
    var id, o, prop, props, _i, _len;
    id = this.objects.length;
    object.id = id;
    o = {
      id: id
    };
    this.object_id += 1;
    props = ['type', 'width', 'height', 'scaleX', 'scaleY', 'left', 'top', 'angle', 'fill', 'stroke'];
    if (object.type === 'shelf') {
      props.push('count');
      props.push('side');
    }
    for (_i = 0, _len = props.length; _i < _len; _i++) {
      prop = props[_i];
      if (prop === 'top') {
        o.top_cm = this.transformX_px2cm(object.top);
        continue;
      }
      if (prop === 'left') {
        o.left_cm = this.transformY_px2cm(object.left);
        continue;
      }
      o[prop] = object[prop];
    }
    this.objects.push(o);
    return o;
  },
  load: function() {
    var canvas, object, objects, shelf, _i, _len;
    objects = JSON.parse(localStorage.getItem('app_data'));
    if (objects) {
      for (_i = 0, _len = objects.length; _i < _len; _i++) {
        object = objects[_i];
        shelf = new fabric.Shelf({
          count: object.count,
          side: object.side,
          top: app.transformX_cm2px(object.top_cm),
          left: app.transformY_cm2px(object.left_cm),
          fill: "#CFE2F3",
          stroke: "#000000",
          angle: object.angle
        });
        this.add(shelf);
      }
    }
    canvas = JSON.parse(localStorage.getItem('canvas'));
    if (canvas) {
      this.scale = canvas.scale;
      $('.zoom').html((this.scale * 100).toFixed(0) + '%');
      this.centerX = canvas.centerX;
      this.centerY = canvas.centerY;
    }
    return this.render();
  },
  save: function() {
    var canvas;
    canvas = {
      scale: this.scale,
      centerX: this.centerX,
      centerY: this.centerY
    };
    return localStorage.setItem('canvas', JSON.stringify(canvas));
  },
  save_prop: function(object, group) {
    var count;
    if (group == null) {
      group = false;
    }
    count = object.id;
    this.objects[count].type = object.type;
    this.objects[count].top_cm = this.transformY_px2cm(object.top);
    this.objects[count].left_cm = this.transformX_px2cm(object.left);
    this.objects[count].scaleX = object.scaleX / this.scale;
    this.objects[count].scaleY = object.scaleY / this.scale;
    this.objects[count].angle = object.angle;
    if (object.type === 'shelf') {
      this.objects[count].count = object.count;
      this.objects[count].side = object.side;
    }
    return localStorage.setItem('app_data', JSON.stringify(this.objects));
  },
  bind: function(func) {
    var group, object, objects;
    object = this.canvas.getActiveObject();
    if (object) {
      func(object);
    }
    group = this.canvas.getActiveGroup();
    if (group) {
      return objects = group._objects;
    }
  },
  remove: function() {
    var _this = this;
    return this.bind(function(object) {
      var count;
      _this.canvas.remove(object);
      count = object.id;
      return _this.objects.splice(count, 1);
    });
  },
  bringToFront: function() {
    var _this = this;
    return this.bind(function(object) {
      var count, obj;
      count = object.id;
      object.bringToFront();
      obj = _this.objects[count];
      _this.objects.splice(count, 1);
      return _this.objects.push(obj);
    });
  },
  transformX_cm2px: function(cm) {
    return this.canvas.getWidth() / 2 + (this.centerX - cm) * this.scale;
  },
  transformY_cm2px: function(cm) {
    return this.canvas.getHeight() / 2 + (this.centerY - cm) * this.scale;
  },
  transformX_px2cm: function(px) {
    return this.centerX - (px - this.canvas.getWidth() / 2) / this.scale;
  },
  transformY_px2cm: function(px) {
    return this.centerY - (px - this.canvas.getHeight() / 2) / this.scale;
  },
  unselect: function() {
    var object;
    object = app.canvas.getActiveObject();
    if (!object) {
      object = app.canvas.getActiveGroup();
    }
    if (object) {
      this.canvas.fire('before:selection:cleared', {
        target: object
      });
      return this.canvas.fire('selection:cleared', {
        target: object
      });
    }
  },
  render: function() {
    var i, object;
    this.unselect();
    this.canvas.clear();
    for (i in this.objects) {
      if (this.objects[i].type === 'shelf') {
        object = new fabric.Shelf();
        object.side = this.objects[i].side;
        object.count = this.objects[i].count;
      }
      if (this.objects[i].type === 'curved_shelf') {
        object = new fabric.curvedShelf();
      }
      object.id = this.objects[i].id;
      object.scaleX = 1;
      object.scaleY = 1;
      object.width = object.__width();
      object.height = object.__height();
      object.left = this.transformX_cm2px(this.objects[i].left_cm);
      object.top = this.transformY_cm2px(this.objects[i].top_cm);
      if (this.objects[i].angle > 0) {
        object.angle = this.objects[i].angle;
      }
      object.originX = 'center';
      object.originY = 'center';
      object.fill = "#CFE2F3";
      object.stroke = "#000000";
      object.padding = 0;
      object.transparentCorners = false;
      object.cornerColor = "#488BD4";
      object.borderOpacityWhenMoving = 0.8;
      object.borderColor = "#000000";
      object.cornerSize = 10;
      object.setCoords();
      this.canvas.add(object);
    }
    if (this.scale === 1 && this.drawguideline) {
      fabric.drawGridLines(this.canvas);
    }
    this.canvas.renderAll();
    this.render_bg();
    return this.debug();
  },
  render_bg: function() {
    if (this.bgimg) {
      this.bgimg.left = this.canvas.getWidth() / 2 + (-this.bgimg_width * this.options.bgscale / 2 + this.centerX) * this.scale;
      this.bgimg.top = this.canvas.getHeight() / 2 + (-this.bgimg_height * this.options.bgscale / 2 + this.centerY) * this.scale;
      this.bgimg.width = this.bgimg_width * this.options.bgscale * this.scale;
      this.bgimg.height = this.bgimg_height * this.options.bgscale * this.scale;
      this.bgimg.opacity = this.options.bgopacity;
      return this.canvas.setBackgroundImage(this.bgimg, this.canvas.renderAll.bind(this.canvas));
    }
  },
  debug: function() {
    $('#canvas_width').val(this.canvas.getWidth());
    $('#canvas_height').val(this.canvas.getHeight());
    $('#canvas_centerX').val(this.centerX);
    $('#canvas_centerY').val(this.centerY);
    return $('#canvas_bgscale').val(this.options.bgscale);
  },
  zoomIn: function() {
    this.unselect();
    this.scale += 0.1;
    this.scale = (this.scale * 100).toFixed(0) / 100;
    this.render();
    return $('.zoom').html((this.scale * 100).toFixed(0) + '%');
  },
  zoomOut: function() {
    this.unselect();
    if (this.scale <= 0.1) {
      return;
    }
    this.scale -= 0.1;
    this.scale = (this.scale * 100).toFixed(0) / 100;
    this.render();
    return $('.zoom').html((this.scale * 100).toFixed(0) + '%');
  },
  zoomReset: function() {
    this.unselect();
    this.scale = 1;
    this.render();
    return $('.zoom').html('100%');
  },
  toTop: function(y) {
    if (y == null) {
      y = 100;
    }
    this.unselect();
    this.centerY += y;
    return this.render();
  },
  toBottom: function(y) {
    if (y == null) {
      y = 100;
    }
    this.unselect();
    this.centerY -= y;
    return this.render();
  },
  toRight: function(x) {
    if (x == null) {
      x = 100;
    }
    this.unselect();
    this.centerX -= x;
    return this.render();
  },
  toLeft: function(x) {
    if (x == null) {
      x = 100;
    }
    this.unselect();
    this.centerX += x;
    return this.render();
  },
  toGeoJSON: function() {
    var data, features, object, _i, _len, _ref;
    features = [];
    _ref = this.canvas.getObjects();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      features.push(object.toGeoJSON());
    }
    data = {
      "type": "FeatureCollection",
      "features": features
    };
    return JSON.stringify(data, null, 4);
  },
  getGeoJSON: function() {
    var a, blob, geojson;
    this.unselect();
    this.drawguideline = false;
    this.render();
    this.drawguideline = true;
    geojson = this.toGeoJSON();
    localStorage.setItem('geojson', JSON.stringify(geojson));
    location.href = '/map.html';
    return;
    a = document.createElement('a');
    a.download = 'sample.geojson';
    a.type = 'application/json';
    blob = new Blob([geojson], {
      "type": "application/json"
    });
    a.href = (window.URL || webkitURL).createObjectURL(blob);
    return a.click();
  },
  getSVG: function() {
    var a, blob, canvas, svg, tmp_canvas, tmp_scale;
    this.unselect();
    canvas = document.createElement('canvas');
    canvas = new fabric.Canvas(canvas);
    canvas.setWidth(this.options.max_width);
    canvas.setHeight(this.options.max_height);
    tmp_canvas = this.canvas;
    tmp_scale = this.scale;
    this.canvas = canvas;
    this.scale = 1;
    this.drawguideline = false;
    this.render();
    this.drawguideline = true;
    svg = this.canvas.toSVG();
    this.canvas = tmp_canvas;
    this.scale = tmp_scale;
    a = document.createElement('a');
    a.download = 'sample.svg';
    a.type = 'image/svg+xml';
    blob = new Blob([svg], {
      "type": "image/svg+xml"
    });
    a.href = (window.URL || webkitURL).createObjectURL(blob);
    return a.click();
  }
};
