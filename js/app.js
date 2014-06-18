// Generated by CoffeeScript 1.3.1
var app, log;

log = function(obj) {
  try {
    return console.log(obj);
  } catch (_error) {}
};

app = {
  state: 'shelf',
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
    canvas._renderBackground = function(ctx) {
      if (this.backgroundColor) {
        ctx.fillStyle = (this.backgroundColor.toLive ? this.backgroundColor.toLive(ctx) : this.backgroundColor);
        ctx.fillRect(this.backgroundColor.offsetX || 0, this.backgroundColor.offsetY || 0, this.width, this.height);
      }
      ctx.mozImageSmoothingEnabled = false;
      if (this.backgroundImage) {
        this.backgroundImage.render(ctx);
      }
      ctx.mozImageSmoothingEnabled = true;
      return fabric.drawGridLines(ctx);
    };
    initAligningGuidelines(canvas);
    this.canvas = canvas;
    this.scale = options.scale;
    if (this.options.bgurl) {
      fabric.Image.fromURL(this.options.bgurl, function(img) {
        _this.bgimg = img;
        _this.bgimg_width = img.width;
        _this.bgimg_height = img.height;
        return _this.render();
      });
    }
    this.render();
    setTimeout(function() {
      return _this.load();
    }, 500);
    this.canvas.on('object:selected', function(e) {
      var object;
      object = e.target;
      if (object._objects != null) {
        object.lockScalingX = true;
        object.lockScalingY = true;
      }
      _this.save();
      return _this.set_propety_panel();
    });
    this.canvas.on('selection:created', function(e) {
      return e.target.hasControls = false;
    });
    this.canvas.on('before:selection:cleared', function(e) {
      var object;
      object = e.target;
      _this.canvas.deactivateAll().renderAll();
      _this.save();
      return _this.set_propety_panel();
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
  last_id: 0,
  get_id: function() {
    if (this.objects.length === 0) {
      return 0;
    }
    this.last_id += 1;
    return this.last_id;
  },
  add: function(object) {
    var o, prop, props, state, _i, _len;
    if (object.id === '') {
      object.id = this.get_id();
    }
    o = {
      id: object.id
    };
    props = ['type', 'width', 'height', 'scaleX', 'scaleY', 'left', 'top', 'angle', 'fill', 'stroke'];
    if (object.type.match(/shelf$/)) {
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
    if (object.type.match(/shelf$/)) {
      state = 'shelf';
    } else {
      state = 'beacon';
    }
    this.state = state;
    $('.nav a.' + this.state).tab('show');
    return o.id;
  },
  load: function() {
    var canvas, klass, object, objects, shape, _i, _len;
    objects = JSON.parse(localStorage.getItem('app_data'));
    if (objects) {
      for (_i = 0, _len = objects.length; _i < _len; _i++) {
        object = objects[_i];
        if (object.id > this.last_id) {
          this.last_id = object.id;
        }
        if (object.type === 'shelf') {
          klass = fabric.Shelf;
        } else if (object.type === 'curved_shelf') {
          klass = fabric.curvedShelf;
        } else if (object.type === 'beacon') {
          klass = fabric.Beacon;
        } else {
          continue;
        }
        shape = new klass({
          id: object.id,
          count: object.count,
          side: object.side,
          top: app.transformX_cm2px(object.top_cm),
          left: app.transformY_cm2px(object.left_cm),
          fill: "#CFE2F3",
          stroke: "#000000",
          angle: object.angle
        });
        this.add(shape);
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
  findbyid: function(id) {
    var count;
    count = null;
    $(this.objects).each(function(i, obj) {
      if (obj.id === id) {
        return count = i;
      }
    });
    return count;
  },
  local_save: function() {
    var canvas;
    canvas = {
      scale: this.scale,
      centerX: this.centerX,
      centerY: this.centerY
    };
    localStorage.setItem('canvas', JSON.stringify(canvas));
    return localStorage.setItem('app_data', JSON.stringify(this.objects));
  },
  save: function() {
    var object, _i, _len, _ref;
    _ref = this.canvas.getObjects();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      this.save_prop(object);
    }
    return this.local_save();
  },
  save_prop: function(object, group) {
    var count;
    if (group == null) {
      group = false;
    }
    count = this.findbyid(object.id);
    this.objects[count].id = object.id;
    this.objects[count].type = object.type;
    this.objects[count].top_cm = this.transformY_px2cm(object.top);
    this.objects[count].left_cm = this.transformX_px2cm(object.left);
    this.objects[count].scaleX = object.scaleX / this.scale;
    this.objects[count].scaleY = object.scaleY / this.scale;
    this.objects[count].angle = object.angle;
    if (object.type.match(/shelf$/)) {
      this.objects[count].count = object.count;
      return this.objects[count].side = object.side;
    }
  },
  bind: function(func, do_active) {
    var group, new_id, object, objects, _i, _len,
      _this = this;
    if (do_active == null) {
      do_active = true;
    }
    object = this.canvas.getActiveObject();
    if (object) {
      new_id = func(object);
      if (do_active) {
        $(this.canvas.getObjects()).each(function(i, obj) {
          if (obj.id === new_id) {
            return _this.canvas.setActiveObject(obj);
          }
        });
      }
    }
    group = this.canvas.getActiveGroup();
    if (group) {
      this.canvas.discardActiveGroup();
      objects = group._objects;
      for (_i = 0, _len = objects.length; _i < _len; _i++) {
        object = objects[_i];
        func(object);
      }
      if (do_active) {
        objects = objects.map(function(o) {
          return o.set("active", true);
        });
        group = new fabric.Group(objects, {
          originX: "center",
          originY: "center"
        });
        this.canvas._activeObject = null;
        return this.canvas.setActiveGroup(group.setCoords()).renderAll();
      }
    }
  },
  remove: function() {
    var _this = this;
    return this.bind(function(object, do_active) {
      var count;
      if (do_active == null) {
        do_active = false;
      }
      _this.canvas.remove(object);
      count = _this.findbyid(object.id);
      return _this.objects.splice(count, 1);
    });
  },
  bringToFront: function() {
    var _this = this;
    return this.bind(function(object) {
      var count, obj;
      count = _this.findbyid(object.id);
      object.bringToFront();
      obj = _this.objects[count];
      _this.objects.splice(count, 1);
      return _this.objects.push(obj);
    });
  },
  add_active: function(object, top, left) {
    var new_id;
    this.save();
    object.id = this.get_id();
    object.top = top;
    object.left = left;
    new_id = this.add(object);
    this.render();
    return new_id;
  },
  duplicate: function() {
    var _this = this;
    return this.bind(function(object) {
      var o;
      log(object);
      o = fabric.util.object.clone(object);
      return _this.add_active(o, o.top + 10, o.left + 10);
    });
  },
  clipboard: [],
  clipboard_count: 1,
  copy: function() {
    var _this = this;
    this.clipboard = [];
    this.clipboard_count = 1;
    return this.bind(function(object) {
      var o;
      o = fabric.util.object.clone(object);
      o.top_cm = _this.transformY_px2cm(o.top);
      o.left_cm = _this.transformX_px2cm(o.left);
      return _this.clipboard.push(o);
    });
  },
  paste: function() {
    var left, o, object, top, _i, _len, _ref;
    if (this.clipboard === []) {
      return;
    }
    _ref = this.clipboard;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      o = fabric.util.object.clone(object);
      o.top = this.transformY_cm2px(o.top_cm);
      o.left = this.transformX_cm2px(o.left_cm);
      top = object.top + this.clipboard_count * o.height / 2;
      left = object.left + this.clipboard_count * o.width / 10;
      this.add_active(o, top, left);
    }
    return this.clipboard_count += 1;
  },
  select_all: function() {
    var group, objects;
    objects = this.canvas.getObjects().map(function(o) {
      return o.set("active", true);
    });
    group = new fabric.Group(objects, {
      originX: "center",
      originY: "center"
    });
    this.canvas._activeObject = null;
    return this.canvas.setActiveGroup(group.setCoords()).renderAll();
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
    var o, object, _i, _len, _ref;
    this.canvas.renderOnAddRemove = false;
    this.unselect();
    this.canvas._objects.length = 0;
    _ref = this.objects;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      o = _ref[_i];
      if (o.type === 'shelf') {
        object = new fabric.Shelf();
        object.side = o.side;
        object.count = o.count;
      }
      if (o.type === 'curved_shelf') {
        object = new fabric.curvedShelf();
        object.side = o.side;
        object.count = o.count;
      }
      if (o.type === 'beacon') {
        object = new fabric.Beacon();
      }
      object.selectable = o.type.match(this.state);
      if (!o.type.match(this.state)) {
        object.opacity = 0.5;
      }
      object.id = o.id;
      object.scaleX = object.scaleY = 1;
      object.width = object.__width();
      object.height = object.__height();
      object.left = this.transformX_cm2px(o.left_cm);
      object.top = this.transformY_cm2px(o.top_cm);
      object.angle = o.angle;
      object.originX = 'center';
      object.originY = 'center';
      if (o.type === 'beacon') {
        object.fill = "#000000";
        object.hasControls = false;
        object.padding = 10;
        object.borderColor = "#0000ee";
      } else {
        object.borderColor = "#000000";
        object.fill = "#CFE2F3";
        object.padding = 0;
      }
      object.stroke = "#000000";
      object.transparentCorners = false;
      object.cornerColor = "#488BD4";
      object.borderOpacityWhenMoving = 0.8;
      object.cornerSize = 10;
      this.canvas.add(object);
    }
    this.render_bg();
    this.canvas.renderAll();
    this.canvas.renderOnAddRemove = true;
    return this.debug();
  },
  render_bg: function() {
    if (this.bgimg) {
      this.bgimg.left = Math.floor(this.canvas.getWidth() / 2 + (-this.bgimg_width * this.options.bgscale / 2 + this.centerX) * this.scale);
      this.bgimg.top = Math.floor(this.canvas.getHeight() / 2 + (-this.bgimg_height * this.options.bgscale / 2 + this.centerY) * this.scale);
      this.bgimg.width = Math.floor(this.bgimg_width * this.options.bgscale * this.scale);
      this.bgimg.height = Math.floor(this.bgimg_height * this.options.bgscale * this.scale);
      this.bgimg.opacity = this.options.bgopacity;
      return this.canvas.setBackgroundImage(this.bgimg);
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
    var prev_scale;
    this.unselect();
    prev_scale = this.scale;
    this.scale = this.scale + Math.pow(this.scale + 1, 2) / 20;
    if (this.scale >= 4) {
      this.scale = 4;
    }
    if (prev_scale < 1 && this.scale > 1) {
      this.scale = 1;
    }
    this.scale = (this.scale * 100).toFixed(0) / 100;
    this.render();
    return $('.zoom').html((this.scale * 100).toFixed(0) + '%');
  },
  zoomOut: function() {
    var prev_scale;
    this.unselect();
    prev_scale = this.scale;
    this.scale = this.scale - Math.pow(this.scale + 1, 2) / 20;
    if (this.scale <= 0.05) {
      this.scale = 0.05;
    }
    if (prev_scale > 1 && this.scale < 1) {
      this.scale = 1;
    }
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
    location.href = 'map.html';
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
  },
  set_propety_panel: function(object) {
    var group, objects;
    $('.canvas_panel, .object_panel, .group_panel').hide();
    object = this.canvas.getActiveObject();
    if (object) {
      if (object.toGeoJSON != null) {
        $('#geojson').val(JSON.stringify(object.toGeoJSON(), null, 4));
      }
      $('.object_panel').show();
      $('#object_id').html(object.id);
      return;
    }
    group = this.canvas.getActiveGroup();
    if (group) {
      objects = group._objects;
      $('#group_count').html(objects.length);
      $('.group_panel').show();
    } else {
      return $('.canvas_panel').show();
    }
  }
};
