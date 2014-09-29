var haika, log;

log = function(obj) {
  try {
    return console.log(obj);
  } catch (_error) {}
};

haika = {
  state: 'shelf',
  centerX: 0,
  centerY: 0,
  scale: 1,
  objects: [],
  canvas: false,
  background_image: null,
  fillColor: "#CFE2F3",
  strokeColor: "#000000",
  options: {},
  default_options: {
    canvas_id: 'canvas_area',
    canvas_width: 800,
    canvas_height: 600,
    scale: 1,
    bgurl: null,
    bgopacity: 1,
    bgscale: 1,
    lon: 0,
    lat: 0,
    angle: 0,
    geojson_scale: 1.5
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
  init: function(options) {
    var canvas;
    this.options = $.extend(this.default_options, options);
    canvas = new fabric.Canvas(this.options.canvas_id, {
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
      ctx.mozImageSmoothingEnabled = false;
      if (this.backgroundImage) {
        this.backgroundImage.render(ctx);
      }
      ctx.mozImageSmoothingEnabled = true;
      return fabric.drawGridLines(ctx);
    };
    initAligningGuidelines(canvas);
    this.canvas = canvas;
    if (options.scale != null) {
      this.scale = options.scale;
    }
    this.render();
    setTimeout((function(_this) {
      return function() {
        var onerror;
        onerror = function(message) {
          return alert(message);
        };
        _this.openFromApi(2, null, null, onerror);
        return $(_this).trigger('haika:initialized');
      };
    })(this), 500);
    return this.bindEvent();
  },
  bindEvent: function() {
    this.canvas.on('object:selected', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        if (object._objects != null) {
          object.lockScalingX = true;
          object.lockScalingY = true;
        }
        _this.saveDelay();
        return _this.setPropetyPanel();
      };
    })(this));
    this.canvas.on('before:selection:cleared', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        _this.canvas.deactivateAll().renderAll();
        _this.saveDelay();
        _this.editor_change();
        return _this.setPropetyPanel();
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
          object.__modifiedShelf();
        }
        return _this.setPropetyPanel();
      };
    })(this));
    return $(window).on('beforeunload', (function(_this) {
      return function(event) {
        _this.render();
        _this.save();
      };
    })(this));
  },
  loadBgFromUrl: function(url) {
    this.options.bgurl = url;
    return this.render();
  },
  resetBg: function() {
    return loadBgFromUrl('');
  },
  lastId: 0,
  getId: function() {
    if (this.objects.length === 0) {
      return 0;
    }
    this.lastId += 1;
    return this.lastId;
  },
  getCountFindById: function(id) {
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
    var key, o, prop, props, schema, _i, _len;
    if (object.id === '' || !object.id) {
      object.id = this.getId();
    }
    o = {
      id: object.id
    };
    props = ['type', 'width', 'height', 'scaleX', 'scaleY', 'left', 'top', 'angle', 'fill', 'stroke'];
    schema = object.constructor.prototype.getJsonSchema();
    for (key in schema.properties) {
      props.push(key);
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
    $(this).trigger('haika:add');
    return o.id;
  },
  setState: function(object) {
    var state;
    if (object.type.match(/shelf$/)) {
      state = 'shelf';
    } else if (object.type === 'wall') {
      state = 'wall';
    } else if (object.type === 'floor') {
      state = 'floor';
    } else {
      state = 'beacon';
    }
    this.state = state;
    return $('.nav a.' + this.state).tab('show');
  },
  getObjects: function(func, do_active) {
    var group, new_id, new_ids, object, _i, _len, _ref;
    if (do_active == null) {
      do_active = true;
    }
    object = this.canvas.getActiveObject();
    if (object) {
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
        return this.activeGroup(new_ids);
      } else {
        return this.render();
      }
    }
  },
  activeGroup: function(new_ids) {
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
    this.getObjects((function(_this) {
      return function(object) {
        return _this.__remove(object);
      };
    })(this), false);
    return $(this).trigger('haika:remove');
  },
  __remove: function(object) {
    var count;
    this.canvas.remove(object);
    count = this.getCountFindById(object.id);
    this.objects.splice(count, 1);
    return object;
  },
  bringToFront: function() {
    return this.getObjects((function(_this) {
      return function(object) {
        var count, obj;
        count = _this.getCountFindById(object.id);
        object.bringToFront();
        obj = _this.objects[count];
        _this.objects.splice(count, 1);
        _this.objects.push(obj);
        return obj.id;
      };
    })(this));
  },
  duplicate: function() {
    var group, new_id, new_ids, o, object, _i, _len, _ref;
    object = this.canvas.getActiveObject();
    if (object) {
      o = fabric.util.object.clone(object);
      o.id = this.getId();
      o.top = this.transformTopY_cm2px(this.centerY);
      o.left = this.transformLeftX_cm2px(this.centerX);
      new_id = this.add(o);
    }
    group = this.canvas.getActiveGroup();
    if (group) {
      new_ids = [];
      _ref = group.getObjects();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        o = fabric.util.object.clone(object);
        o.id = this.getId();
        o.top = this.transformTopY_cm2px(this.centerY) + object.top;
        o.left = this.transformLeftX_cm2px(this.centerX) + object.left;
        new_id = this.add(o);
        new_ids.push(new_id);
      }
    }
    this.saveDelay();
    this.render();
    if (object) {
      $(this.canvas.getObjects()).each((function(_this) {
        return function(i, obj) {
          if (obj.id === new_id) {
            return _this.canvas.setActiveObject(obj);
          }
        };
      })(this));
    }
    if (group) {
      this.activeGroup(new_ids);
    }
    return $(this).trigger('haika:duplicate');
  },
  clipboard: [],
  clipboard_scale: 0,
  copy: function() {
    var group, object, _i, _len, _ref;
    this.clipboard = [];
    object = this.canvas.getActiveObject();
    if (object) {
      this.clipboard.push(fabric.util.object.clone(object));
    }
    group = this.canvas.getActiveGroup();
    if (group) {
      _ref = group.getObjects();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        this.clipboard.push(fabric.util.object.clone(object));
      }
    }
    this.clipboard_scale = this.scale;
    return $(this).trigger('haika:copy');
  },
  paste: function() {
    var new_id, new_ids, o, object, _i, _len, _ref;
    if (this.clipboard.length <= 0) {
      return;
    }
    if (this.clipboard.length === 1) {
      object = this.clipboard[0];
      o = fabric.util.object.clone(object);
      o.id = this.getId();
      o.top = this.transformTopY_cm2px(this.centerY);
      o.left = this.transformLeftX_cm2px(this.centerX);
      new_id = this.add(o);
      this.saveDelay();
      this.render();
      return $(this.canvas.getObjects()).each((function(_this) {
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
        o = fabric.util.object.clone(object);
        o.id = this.getId();
        o.top = this.transformTopY_cm2px(this.centerY) + object.top * this.scale / this.clipboard_scale;
        o.left = this.transformLeftX_cm2px(this.centerX) + object.left * this.scale / this.clipboard_scale;
        new_id = this.add(o);
        new_ids.push(new_id);
      }
      this.saveDelay();
      log('pre render' + this.clipboard[0].top);
      this.render();
      log('after render' + this.clipboard[0].top);
      this.activeGroup(new_ids);
      return $(this).trigger('haika:paste');
    }
  },
  selectAll: function() {
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
  unselectAll: function() {
    return this.canvas.deactivateAll().renderAll();
  },
  unselect: function() {
    var object;
    object = this.canvas.getActiveObject();
    if (!object) {
      object = this.canvas.getActiveGroup();
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
  getClass: function(classname) {
    if (classname === 'shelf') {
      return fabric.Shelf;
    } else if (classname === 'curved_shelf') {
      return fabric.curvedShelf;
    } else if (classname === 'beacon') {
      return fabric.Beacon;
    } else if (classname === 'wall') {
      return fabric.Wall;
    } else if (classname === 'floor') {
      return fabric.Floor;
    } else {
      return fabric.Shelf;
    }
  },
  render: function() {
    var beacons, floors, o, shelfs, walls, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _ref;
    if (!this.background_image && this.options.bgurl) {
      fabric.Image.fromURL(this.options.bgurl, (function(_this) {
        return function(img) {
          _this.background_image = img;
          _this.render();
        };
      })(this));
    }
    this.canvas.renderOnAddRemove = false;
    this.unselect();
    this.canvas._objects.length = 0;
    beacons = [];
    shelfs = [];
    walls = [];
    floors = [];
    _ref = this.objects;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      o = _ref[_i];
      if (o.type === 'beacon') {
        beacons.push(o);
      }
      if (o.type === 'wall') {
        walls.push(o);
      }
      if (o.type === 'floor') {
        floors.push(o);
      }
      if (o.type.match(/shelf$/)) {
        shelfs.push(o);
      }
    }
    if (this.state !== 'floor') {
      for (_j = 0, _len1 = floors.length; _j < _len1; _j++) {
        o = floors[_j];
        this.addObjectToCanvas(o);
      }
    }
    for (_k = 0, _len2 = walls.length; _k < _len2; _k++) {
      o = walls[_k];
      this.addObjectToCanvas(o);
    }
    if (this.state === 'floor') {
      for (_l = 0, _len3 = floors.length; _l < _len3; _l++) {
        o = floors[_l];
        this.addObjectToCanvas(o);
      }
    }
    for (_m = 0, _len4 = shelfs.length; _m < _len4; _m++) {
      o = shelfs[_m];
      this.addObjectToCanvas(o);
    }
    for (_n = 0, _len5 = beacons.length; _n < _len5; _n++) {
      o = beacons[_n];
      this.addObjectToCanvas(o);
    }
    if (this.background_image) {
      this.canvas.setBackgroundImage(this.background_image);
      this.background_image.left = Math.floor(this.transformLeftX_cm2px(this.background_image._originalElement.width / 2 * this.options.bgscale));
      this.background_image.top = Math.floor(this.transformTopY_cm2px(this.background_image._originalElement.height / 2 * this.options.bgscale));
      this.background_image.width = Math.floor(this.background_image._originalElement.width * this.options.bgscale * this.scale);
      this.background_image.height = Math.floor(this.background_image._originalElement.height * this.options.bgscale * this.scale);
      this.background_image.opacity = this.options.bgopacity;
    } else {
      this.canvas.setBackgroundImage(null);
    }
    this.canvas.renderAll();
    this.canvas.renderOnAddRemove = true;
    this.setCanvasProperty();
    return $(this).trigger('haika:render');
  },
  addObjectToCanvas: function(o) {
    var key, klass, object, schema;
    klass = this.getClass(o.type);
    object = new klass();
    if (o.type.match(/shelf$/)) {
      object.side = o.side;
      object.count = o.count;
      object.eachWidth = o.eachWidth;
      object.eachHeight = o.eachHeight;
    }
    object.selectable = o.type.match(this.state);
    if (!o.type.match(this.state)) {
      object.opacity = 0.5;
    }
    object.id = o.id;
    object.scaleX = object.scaleY = 1;
    if (o.type === 'wall' || o.type === 'floor') {
      object.width_scale = o.width_scale;
      object.height_scale = o.height_scale;
    }
    object.width = object.__width();
    object.height = object.__height();
    object.top = this.transformTopY_cm2px(o.top_cm);
    object.left = this.transformLeftX_cm2px(o.left_cm);
    object.top_cm = o.top_cm;
    object.left_cm = o.left_cm;
    object.angle = o.angle;
    object.originX = 'center';
    object.originY = 'center';
    if (o.type === 'beacon') {
      object.fill = "#000000";
      object.hasControls = false;
      object.padding = 10;
      object.borderColor = "#0000ee";
    } else if (o.type === 'wall') {
      object.fill = "#000000";
      object.borderColor = "#000000";
    } else if (o.type === 'floor') {
      object.fill = "";
      object.borderColor = "#000000";
    } else {
      object.borderColor = "#000000";
      object.fill = o.fill;
      object.padding = 0;
    }
    object.stroke = o.stroke;
    object.transparentCorners = false;
    object.cornerColor = "#488BD4";
    object.borderOpacityWhenMoving = 0.8;
    object.cornerSize = 10;
    schema = object.constructor.prototype.getJsonSchema();
    for (key in schema.properties) {
      object[key] = o[key];
    }
    return this.canvas.add(object);
  },
  setCanvasProperty: function() {
    $('#canvas_width').html(this.canvas.getWidth());
    $('#canvas_height').html(this.canvas.getHeight());
    $('#canvas_centerX').html(this.centerX);
    $('#canvas_centerY').html(this.centerY);
    $('#canvas_bgscale').val(this.options.bgscale);
    $('#canvas_bgopacity').val(this.options.bgopacity);
    $('#canvas_lon').val(this.options.lon);
    $('#canvas_lat').val(this.options.lat);
    $('#canvas_angle').val(this.canvas.angle);
    return $('#geojson_scale').val(this.canvas.geojson_scale);
  },
  getMovePixel: function(event) {
    if (event.shiftKey) {
      return 10;
    } else {
      return 1;
    }
  },
  up: function(event) {
    var object;
    object = this.canvas.getActiveObject();
    if (object) {
      object.top = object.top - this.getMovePixel(event);
      return this.canvas.renderAll();
    }
  },
  down: function(event) {
    var object;
    object = this.canvas.getActiveObject();
    if (object) {
      object.top = object.top + this.getMovePixel(event);
      return this.canvas.renderAll();
    }
  },
  left: function(event) {
    var object;
    object = this.canvas.getActiveObject();
    if (object) {
      object.left = object.left - this.getMovePixel(event);
      return this.canvas.renderAll();
    }
  },
  right: function(event) {
    var object;
    object = this.canvas.getActiveObject();
    if (object) {
      object.left = object.left + this.getMovePixel(event);
      return this.canvas.renderAll();
    }
  },
  alignLeft: function() {
    var bound, group, left, object, _i, _j, _len, _len1, _ref, _ref1;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      left = 0;
      _ref = group._objects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        bound = object.getBoundingRect();
        left = Math.min(bound.left, left);
      }
      _ref1 = group._objects;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        object = _ref1[_j];
        bound = object.getBoundingRect();
        object.left = left + bound.width / 2;
      }
      this.saveDelay();
      return this.canvas.renderAll();
    }
  },
  alignRight: function() {
    var bound, group, left, object, _i, _j, _len, _len1, _ref, _ref1;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      left = 0;
      _ref = group._objects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        bound = object.getBoundingRect();
        left = Math.max(bound.left + bound.width, left);
      }
      _ref1 = group._objects;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        object = _ref1[_j];
        bound = object.getBoundingRect();
        object.left = left - bound.width / 2;
      }
      return this.canvas.renderAll();
    }
  },
  alignCenter: function() {
    var group, object, _i, _len, _ref;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      _ref = group._objects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        object.left = 0;
      }
      return this.canvas.renderAll();
    }
  },
  alignTop: function() {
    var bound, group, object, top, _i, _j, _len, _len1, _ref, _ref1;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      top = 0;
      _ref = group._objects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        bound = object.getBoundingRect();
        top = Math.min(bound.top, top);
      }
      _ref1 = group._objects;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        object = _ref1[_j];
        bound = object.getBoundingRect();
        object.top = top + bound.height / 2;
      }
      return this.canvas.renderAll();
    }
  },
  alignBottom: function() {
    var bound, group, object, top, _i, _j, _len, _len1, _ref, _ref1;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      top = 0;
      _ref = group._objects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        bound = object.getBoundingRect();
        top = Math.max(bound.top + bound.height, top);
      }
      _ref1 = group._objects;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        object = _ref1[_j];
        bound = object.getBoundingRect();
        object.top = top - bound.height / 2;
      }
      return this.canvas.renderAll();
    }
  },
  alignVcenter: function() {
    var group, object, _i, _len, _ref;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      _ref = group._objects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        object.top = 0;
      }
      return this.canvas.renderAll();
    }
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
  reset: function() {
    this.objects = [];
    localStorage.clear();
    $(window).off('beforeunload');
    return location.reload();
  },
  setPropetyPanel: function(object) {
    var group, key, objects, properties, value;
    $('.canvas_panel, .object_panel, .group_panel').hide();
    object = this.canvas.getActiveObject();
    if (object && (object.getJsonSchema != null)) {
      this.editor.schema = object.getJsonSchema();
      properties = {};
      for (key in this.editor.schema.properties) {
        if (this.editor.schema.properties[key].type === 'integer') {
          value = parseInt(object[key]).toFixed(0);
        } else {
          value = object[key];
        }
        properties[key] = value;
      }
      this.editor.setValue(properties);
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

//# sourceMappingURL=haika.js.map
