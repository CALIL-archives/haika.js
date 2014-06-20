// Generated by CoffeeScript 1.7.1
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
  is_moving: false,
  is_scaling: false,
  is_rotating: false,
  bgimg: null,
  bgimg_width: null,
  bgimg_height: null,
  options: {},
  init: function(options) {
    var canvas, default_options;
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
      fabric.Image.fromURL(this.options.bgurl, (function(_this) {
        return function(img) {
          _this.bgimg = img;
          _this.bgimg_width = img.width;
          _this.bgimg_height = img.height;
          return _this.render();
        };
      })(this));
    }
    this.render();
    setTimeout((function(_this) {
      return function() {
        return _this.load();
      };
    })(this), 500);
    this.canvas.on('object:selected', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        if (object._objects != null) {
          object.lockScalingX = true;
          object.lockScalingY = true;
        }
        _this.save();
        return _this.set_propety_panel();
      };
    })(this));
    this.canvas.on('before:selection:cleared', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        _this.canvas.deactivateAll().renderAll();
        _this.save();
        return _this.set_propety_panel();
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
    this.canvas.on('object:modified', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        if (object.__modifiedShelf != null) {
          return object.__modifiedShelf();
        }
      };
    })(this));
    return $(window).on('beforeunload', (function(_this) {
      return function(event) {
        _this.render();
        _this.save();
      };
    })(this));
  },
  last_id: 0,
  get_id: function() {
    if (this.objects.length === 0) {
      return 0;
    }
    this.last_id += 1;
    return this.last_id;
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
  add: function(object) {
    var o, prop, props, _i, _len;
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
        o.top_cm = this.transformTopY_px2cm(object.top);
        continue;
      }
      if (prop === 'left') {
        o.left_cm = this.transformLeftX_px2cm(object.left);
        continue;
      }
      o[prop] = object[prop];
    }
    this.objects.push(o);
    return o.id;
  },
  set_state: function(object) {
    var state;
    if (object.type.match(/shelf$/)) {
      state = 'shelf';
    } else {
      state = 'beacon';
    }
    this.state = state;
    return $('.nav a.' + this.state).tab('show');
  },
  bind: function(func, do_active) {
    var group, new_id, new_ids, object, _i, _len, _ref;
    if (do_active == null) {
      do_active = true;
    }
    object = this.canvas.getActiveObject();
    if (object) {
      log(object.top);
      new_id = func(object);
      if (new_id && do_active) {
        $(this.canvas.getObjects()).each((function(_this) {
          return function(i, obj) {
            if (obj.id === new_id) {
              return _this.canvas.setActiveObject(obj);
            }
          };
        })(this));
      }
    }
    group = this.canvas.getActiveGroup();
    if (group) {
      new_ids = [];
      _ref = group.getObjects();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        new_id = func(object);
        new_ids.push(new_id);
      }
      if (do_active) {
        return this.active_group(new_ids);
      } else {
        return this.render();
      }
    }
  },
  active_group: function(new_ids) {
    var group, new_id, new_objects, object, _i, _j, _len, _len1, _ref;
    new_objects = [];
    _ref = this.canvas.getObjects();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      for (_j = 0, _len1 = new_ids.length; _j < _len1; _j++) {
        new_id = new_ids[_j];
        if (object.id === new_id) {
          new_objects.push(object);
        }
      }
    }
    new_objects = new_objects.map(function(o) {
      return o.set("active", true);
    });
    group = new fabric.Group(new_objects, {
      originX: "center",
      originY: "center"
    });
    this.canvas._activeObject = null;
    return this.canvas.setActiveGroup(group.setCoords()).renderAll();
  },
  remove: function() {
    return this.bind((function(_this) {
      return function(object) {
        var count;
        _this.canvas.remove(object);
        count = _this.findbyid(object.id);
        return _this.objects.splice(count, 1);
      };
    })(this), false);
  },
  bringToFront: function() {
    return this.bind((function(_this) {
      return function(object) {
        var count, obj;
        count = _this.findbyid(object.id);
        object.bringToFront();
        obj = _this.objects[count];
        _this.objects.splice(count, 1);
        _this.objects.push(obj);
        return obj.id;
      };
    })(this));
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
    return this.bind((function(_this) {
      return function(object) {
        var new_id, o;
        _this.canvas.discardActiveGroup();
        o = fabric.util.object.clone(object);
        new_id = _this.add_active(o, o.top + 10, o.left + 10);
        return new_id;
      };
    })(this));
  },
  clipboard: [],
  clipboard_count: 1,
  copy: function() {
    this.clipboard = [];
    this.clipboard_count = 1;
    return this.bind((function(_this) {
      return function(object) {
        return _this.clipboard.push(object);
      };
    })(this), false);
  },
  paste: function() {
    var new_id, new_ids, object, _i, _len, _ref;
    if (this.clipboard.length <= 0) {
      return;
    }
    if (this.clipboard.length === 1) {
      new_id = this.__paste(this.clipboard[0]);
      $(this.canvas.getObjects()).each((function(_this) {
        return function(i, obj) {
          if (obj.id === new_id) {
            return _this.canvas.setActiveObject(obj);
          }
        };
      })(this));
    } else {
      new_ids = [];
      _ref = this.clipboard;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        new_id = this.__paste(object);
        new_ids.push(new_id);
      }
      this.active_group(new_ids);
    }
    return this.clipboard_count += 1;
  },
  __paste: function(object) {
    var left, new_id, o, top;
    o = fabric.util.object.clone(object);
    top = o.top + this.clipboard_count * o.height / 2;
    left = o.left + this.clipboard_count * o.width / 10;
    new_id = this.add_active(o, top, left);
    return new_id;
  },
  select_all: function() {
    var group, objects;
    this.canvas.discardActiveGroup();
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
  unselect_all: function() {
    return this.canvas.deactivateAll().renderAll();
  },
  transformLeftX_cm2px: function(cm) {
    return this.canvas.getWidth() / 2 + (this.centerX - cm) * this.scale;
  },
  transformTopY_cm2px: function(cm) {
    return this.canvas.getHeight() / 2 + (this.centerY - cm) * this.scale;
  },
  transformLeftX_px2cm: function(px) {
    return this.centerX - (px - this.canvas.getWidth() / 2) / this.scale;
  },
  transformTopY_px2cm: function(px) {
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
    var beacons, o, shelfs, _i, _j, _k, _len, _len1, _len2, _ref;
    this.canvas.renderOnAddRemove = false;
    this.unselect();
    this.canvas._objects.length = 0;
    beacons = [];
    shelfs = [];
    _ref = this.objects;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      o = _ref[_i];
      if (o.type === 'beacon') {
        beacons.push(o);
      }
      if (o.type.match(/shelf$/)) {
        shelfs.push(o);
      }
    }
    for (_j = 0, _len1 = shelfs.length; _j < _len1; _j++) {
      o = shelfs[_j];
      this.render_object(o);
    }
    for (_k = 0, _len2 = beacons.length; _k < _len2; _k++) {
      o = beacons[_k];
      this.render_object(o);
    }
    this.render_bg();
    this.canvas.renderAll();
    this.canvas.renderOnAddRemove = true;
    return this.debug();
  },
  render_object: function(o) {
    var object;
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
    object.left = this.transformLeftX_cm2px(o.left_cm);
    object.top = this.transformTopY_cm2px(o.top_cm);
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
    return this.canvas.add(object);
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
  load: function() {
    var canvas, geojson, h, klass, left, object, shape, top, w, x, y, _i, _len, _ref;
    canvas = JSON.parse(localStorage.getItem('canvas'));
    if (canvas) {
      this.state = canvas.state;
      $('.nav a.' + this.state).tab('show');
      this.scale = canvas.scale;
      $('.zoom').html((this.scale * 100).toFixed(0) + '%');
      this.centerX = canvas.centerX;
      this.centerY = canvas.centerY;
    }
    geojson = JSON.parse(localStorage.getItem('geojson'));
    if (geojson && geojson.features.length > 0) {
      _ref = geojson.features;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        if (object.properties.id > this.last_id) {
          this.last_id = object.properties.id;
        }
        if (object.properties.type === 'shelf') {
          klass = fabric.Shelf;
        } else if (object.properties.type === 'curved_shelf') {
          klass = fabric.curvedShelf;
        } else if (object.properties.type === 'beacon') {
          klass = fabric.Beacon;
        } else {
          continue;
        }
        if (object.properties.type.match(/shelf$/)) {
          w = klass.prototype.__eachWidth() * object.properties.count;
          h = klass.prototype.__eachHeight() * object.properties.side;
        }
        if (object.properties.type === 'beacon') {
          w = klass.prototype.__width();
          h = klass.prototype.__height();
        }
        x = object.geometry.coordinates[0][0][0];
        y = object.geometry.coordinates[0][0][1];
        x = this.transformLeftX_cm2px(x);
        y = this.transformTopY_cm2px(y);
        top = y + h / 2;
        left = x + w / 2;
        shape = new klass({
          id: object.properties.id,
          count: object.properties.count,
          side: object.properties.side,
          top: top,
          left: left,
          fill: "#CFE2F3",
          stroke: "#000000",
          angle: object.properties.angle
        });
        this.add(shape);
      }
    }
    return this.render();
  },
  local_save: function() {
    var canvas;
    canvas = {
      state: this.state,
      scale: this.scale,
      centerX: this.centerX,
      centerY: this.centerY
    };
    localStorage.setItem('canvas', JSON.stringify(canvas));
    return localStorage.setItem('geojson', this.toGeoJSON());
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
    this.objects[count].top_cm = this.transformTopY_px2cm(object.top);
    this.objects[count].left_cm = this.transformLeftX_px2cm(object.left);
    this.objects[count].scaleX = object.scaleX / this.scale;
    this.objects[count].scaleY = object.scaleY / this.scale;
    this.objects[count].angle = object.angle;
    if (object.type.match(/shelf$/)) {
      this.objects[count].count = object.count;
      return this.objects[count].side = object.side;
    }
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
    var geojson;
    this.unselect();
    this.render();
    geojson = this.toGeoJSON();
    localStorage.setItem('geojson', geojson);
    return location.href = 'map.html';
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
    this.render();
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

//# sourceMappingURL=app.map
