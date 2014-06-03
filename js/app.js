// Generated by CoffeeScript 1.3.1
var SCALE_FACTOR, app, log;

log = function(obj) {
  try {
    return console.log(obj);
  } catch (_error) {}
};

SCALE_FACTOR = 2;

app = {
  width: 800,
  height: 800,
  centerX: 0,
  centerY: 0,
  scale: 10,
  objects: [],
  object_id: 1,
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
      bgurl: null,
      bgopacity: 1,
      bgscale: 1
    };
    this.options = $.extend(default_options, options);
    canvas = new fabric.Canvas(this.options.canvas);
    canvas.setWidth(this.options.canvas_width);
    $('#canvas_width').val(this.options.canvas_width);
    canvas.setHeight(this.options.canvas_height);
    $('#canvas_height').val(this.options.canvas_height);
    initAligningGuidelines(canvas);
    this.canvas = canvas;
    if (this.options.bgurl) {
      fabric.Image.fromURL(this.options.bgurl, function(img) {
        _this.bgimg = img;
        _this.bgimg_width = img.width;
        return _this.bgimg_height = img.height;
      });
    }
    this.canvas.on('object:selected', function(e) {
      var object;
      object = e.target;
      if (object._objects != null) {
        object.lockScalingX = true;
        return object.lockScalingY = true;
      }
    });
    this.canvas.on('before:selection:cleared', function(e) {
      var group, object, objects, _i, _len, _results;
      object = e.target;
      log('before_unselect');
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
    return this.canvas.on('object:modified', function(e) {
      var object;
      object = e.target;
      log('modified');
      if (object.__modifiedShelf != null) {
        return object.__modifiedShelf();
      }
    });
  },
  save_prop: function(object, group) {
    var count;
    if (group == null) {
      group = false;
    }
    count = this.match(object);
    if (count !== null) {
      this.objects[count].top_cm = this.transformY_px2cm(object.top);
      this.objects[count].left_cm = this.transformX_px2cm(object.left);
      this.objects[count].scaleX = object.scaleX / this.scale;
      this.objects[count].scaleY = object.scaleY / this.scale;
      this.objects[count].angle = object.angle;
    }
    return localStorage.setItem('app_data', JSON.stringify(this.objects));
  },
  add: function(object) {
    var o, prop, props, _i, _len;
    object.__id = this.object_id;
    this.object_id += 1;
    o = {
      object: object
    };
    props = 'width height scaleX scaleY left top angle fill stroke'.split(' ');
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
  bind: function(func) {
    var group, object, objects;
    object = this.canvas.getActiveObject();
    if (object) {
      func(object);
    }
    group = this.canvas.getActiveGroup();
    if (group) {
      objects = group._objects;
      this.canvas._activeObject = null;
      return this.canvas.setActiveGroup(group.setCoords()).renderAll();
    }
  },
  remove: function() {
    var _this = this;
    return this.bind(function(object) {
      var count;
      _this.canvas.remove(object);
      count = _this.match(object);
      if (count !== null) {
        return _this.objects.splice(count, 1);
      }
    });
  },
  bringToFront: function() {
    var _this = this;
    return this.bind(function(object) {
      var count, obj;
      count = _this.match(object);
      if (count !== null) {
        object.bringToFront();
        obj = _this.objects[count];
        _this.objects.splice(count, 1);
        return _this.objects.push(obj);
      }
    });
  },
  match: function(object) {
    var count, o, _i, _len, _ref;
    count = 0;
    _ref = this.objects;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      o = _ref[_i];
      if (o['object'].__id === object.__id) {
        return count;
      }
      count += 1;
    }
    return null;
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
  render: function() {
    var angle, left_cm, o, object, scaleX, scaleY, tempLeft, tempScaleX, tempScaleY, tempTop, top_cm;
    object = app.canvas.getActiveObject();
    if (!object) {
      object = app.canvas.getActiveGroup();
    }
    if (object) {
      this.canvas.fire('before:selection:cleared', {
        target: object
      });
      this.canvas.fire('selection:cleared', {
        target: object
      });
    }
    if (this.objects.length <= 0) {
      return;
    }
    this.canvas.clear();
    for (o in this.objects) {
      scaleX = this.objects[o].scaleX;
      scaleY = this.objects[o].scaleY;
      left_cm = this.objects[o].left_cm;
      top_cm = this.objects[o].top_cm;
      angle = this.objects[o].angle;
      tempScaleX = scaleX * this.scale;
      tempScaleY = scaleY * this.scale;
      tempLeft = this.transformX_cm2px(left_cm);
      tempTop = this.transformY_cm2px(top_cm);
      object = this.objects[o]['object'];
      object.scaleX = tempScaleX;
      object.scaleY = tempScaleY;
      object.left = tempLeft;
      object.top = tempTop;
      if (angle > 0) {
        object.angle = angle;
      }
      object.originX = 'center';
      object.originY = 'center';
      object.setCoords();
      this.canvas.add(object);
    }
    if (this.scale === 1 && this.drawguideline) {
      fabric.drawGridLines(this.canvas);
    }
    this.canvas.renderAll();
    if (this.bgimg) {
      this.bgimg.left = -(this.centerX * this.scale);
      this.bgimg.top = -(this.centerY * this.scale);
      this.bgimg.width = this.bgimg_width * this.options.bgscale * this.scale;
      this.bgimg.height = this.bgimg_height * this.options.bgscale * this.scale;
      this.bgimg.opacity = this.options.bgopacity;
      this.canvas.setBackgroundImage(this.bgimg, this.canvas.renderAll.bind(this.canvas));
    }
    return this.debug();
  },
  debug: function() {
    $('#canvas_width').val(this.canvas.getWidth());
    $('#canvas_height').val(this.canvas.getHeight());
    $('#canvas_centerX').val(this.centerX);
    return $('#canvas_centerY').val(this.centerY);
  },
  zoomIn: function() {
    this.scale += 0.1;
    this.scale = (this.scale * 100).toFixed(0) / 100;
    this.render();
    return $('.zoom').html((this.scale * 100).toFixed(0) + '%');
  },
  zoomOut: function() {
    if (this.scale <= 0.1) {
      return;
    }
    this.scale -= 0.1;
    this.scale = (this.scale * 100).toFixed(0) / 100;
    this.render();
    return $('.zoom').html((this.scale * 100).toFixed(0) + '%');
  },
  zoomReset: function() {
    this.scale = 1;
    this.render();
    return $('.zoom').html('100%');
  },
  toTop: function(y) {
    if (y == null) {
      y = 100;
    }
    this.centerY += y;
    return this.render();
  },
  toBottom: function(y) {
    if (y == null) {
      y = 100;
    }
    this.centerY -= y;
    return this.render();
  },
  toRight: function(x) {
    if (x == null) {
      x = 100;
    }
    this.centerX -= x;
    return this.render();
  },
  toLeft: function(x) {
    if (x == null) {
      x = 100;
    }
    this.centerX += x;
    return this.render();
  },
  save: function() {
    var a, blob, canvas, svg, tmp_canvas;
    canvas = document.createElement('canvas');
    canvas = new fabric.Canvas(canvas);
    canvas.setWidth(this.options.max_width);
    canvas.setHeight(this.options.max_height);
    tmp_canvas = this.canvas;
    this.canvas = canvas;
    this.drawguideline = false;
    this.render();
    this.drawguideline = true;
    svg = this.canvas.toSVG();
    this.canvas = tmp_canvas;
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
