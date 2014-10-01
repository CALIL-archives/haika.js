var haika, log;

log = function(obj) {
  try {
    return console.log(obj);
  } catch (_error) {}
};

haika = {
  CONST_LAYERS: {
    SHELF: 0,
    WALL: 1,
    FLOOR: 2,
    BEACON: 3
  },
  INSTALLED_OBJECTS: {
    'shelf': fabric.Shelf,
    'curved_shelf': fabric.curvedShelf,
    'beacon': fabric.Beacon,
    'wall': fabric.Wall,
    'floor': fabric.Floor
  },
  canvas: null,
  centerX: 0,
  centerY: 0,
  scaleFactor: 1,
  layer: null,
  objects: [],
  _geojson: {},
  fillColor: "#CFE2F3",
  strokeColor: "#000000",
  backgroundUrl: null,
  backgroundOpacity: 1,
  backgroundScaleFactor: 1,
  xyLongitude: null,
  xyLatitude: null,
  xyAngle: 0,
  xyScaleFactor: 1,
  clipboard: [],
  clipboard_scale: 0,
  transformLeftX_cm2px: function(cm) {
    return this.canvas.getWidth() / 2 + (this.centerX - cm) * this.scaleFactor;
  },
  transformTopY_cm2px: function(cm) {
    return this.canvas.getHeight() / 2 + (this.centerY - cm) * this.scaleFactor;
  },
  transformLeftX_px2cm: function(px) {
    return this.centerX - (px - this.canvas.getWidth() / 2) / this.scaleFactor;
  },
  transformTopY_px2cm: function(px) {
    return this.centerY - (px - this.canvas.getHeight() / 2) / this.scaleFactor;
  },
  init: function(options) {
    var canvas;
    if (options.canvasId == null) {
      throw 'CanvasのIDが未定義です';
    }
    if (canvas) {
      throw '既に初期化されています';
    }
    this.scaleFactor = options.scaleFactor != null ? options.scaleFactor : 1;
    this.layer = this.CONST_LAYERS.SHELF;
    canvas = new fabric.Canvas(options.canvasId, {
      width: options.width != null ? options.width : 500,
      height: options.height != null ? options.height : 500,
      rotationCursor: 'url("img/rotate.cur") 10 10, crosshair'
    });
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
        this.backgroundImage.left = Math.floor(this.parentHaika.transformLeftX_cm2px(this.backgroundImage._originalElement.width / 2 * this.parentHaika.backgroundScaleFactor));
        this.backgroundImage.top = Math.floor(this.parentHaika.transformTopY_cm2px(this.backgroundImage._originalElement.height / 2 * this.parentHaika.backgroundScaleFactor));
        this.backgroundImage.width = Math.floor(this.backgroundImage._originalElement.width * this.parentHaika.backgroundScaleFactor * this.parentHaika.scaleFactor);
        this.backgroundImage.height = Math.floor(this.backgroundImage._originalElement.height * this.parentHaika.backgroundScaleFactor * this.parentHaika.scaleFactor);
        this.backgroundImage.opacity = this.parentHaika.backgroundOpacity;
        this.backgroundImage.render(ctx);
      }
      ctx.mozImageSmoothingEnabled = true;
      return fabric.drawGridLines(ctx);
    };
    initAligningGuidelines(canvas);
    this.canvas = canvas;
    this.canvas.parentHaika = this;
    this.canvas.on('object:selected', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        if (object._objects != null) {
          object.lockScalingX = true;
          object.lockScalingY = true;
        }
        return _this.setPropetyPanel();
      };
    })(this));
    this.canvas.on('before:selection:cleared', (function(_this) {
      return function(e) {
        _this.canvas.deactivateAll();
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
        object.top_cm = _this.transformTopY_px2cm(object.top);
        object.left_cm = _this.transformLeftX_px2cm(object.left);
        _this.saveDelay();
        return _this.setPropetyPanel();
      };
    })(this));
    return $(this).trigger('haika:initialized');
  },
  setScale: function(newScale) {
    this.canvas.deactivateAll();
    if (newScale >= 4) {
      newScale = 4;
    } else if (newScale <= 0.05) {
      newScale = 0.05;
    }
    this.scaleFactor = (newScale * 100).toFixed(0) / 100;
    this.render();
    return newScale;
  },
  zoomIn: function() {
    var newScale, prevScale;
    prevScale = this.scaleFactor;
    newScale = prevScale + Math.pow(prevScale + 1, 2) / 20;
    if (newScale < 1 && prevScale > 1) {
      newScale = 1;
    }
    return this.setScale(newScale);
  },
  zoomOut: function() {
    var newScale, prevScale;
    prevScale = this.scaleFactor;
    newScale = prevScale - Math.pow(prevScale + 1, 2) / 20;
    if (prevScale > 1 && newScale < 1) {
      newScale = 1;
    }
    return this.setScale(newScale);
  },
  zoomReset: function() {
    return this.setScale(1);
  },
  setBackgroundUrl: function(url) {
    this.canvas.backgroundImage = null;
    this.backgroundUrl = url;
    return this.render();
  },
  loadBgFromUrl: function(url) {
    return this.setBackgroundUrl(url);
  },
  resetBg: function() {
    return this.setBackgroundUrl('');
  },
  _getLatestId: function() {
    var lastId, object, _i, _len, _ref;
    if (this.objects.length === 0) {
      return 0;
    }
    lastId = 0;
    _ref = this.objects;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      if (object.id > lastId) {
        lastId = object.id;
      }
    }
    lastId += 1;
    return lastId;
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
    object.id = this._getLatestId();
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
    this.clipboard_scale = this.scaleFactor;
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
        o.top = this.transformTopY_cm2px(this.centerY) + object.top * this.scaleFactor / this.clipboard_scale;
        o.left = this.transformLeftX_cm2px(this.centerX) + object.left * this.scaleFactor / this.clipboard_scale;
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
  getClass: function(type) {
    if (this.INSTALLED_OBJECTS[type] != null) {
      return this.INSTALLED_OBJECTS[type];
    } else {
      throw '認識できないオブジェクトが含まれています';
    }
  },
  render: function() {
    var beacons, floors, o, shelfs, walls, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _ref;
    if (!this.canvas.backgroundImage && this.backgroundUrl) {
      fabric.Image.fromURL(this.backgroundUrl, (function(_this) {
        return function(img) {
          _this.canvas.backgroundImage = img;
          _this.render();
        };
      })(this));
    }
    this.canvas.renderOnAddRemove = false;
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
      if (o.type === 'shelf' || o.type === 'curvedShelf') {
        shelfs.push(o);
      }
    }
    if (this.layer !== this.CONST_LAYERS.FLOOR) {
      for (_j = 0, _len1 = floors.length; _j < _len1; _j++) {
        o = floors[_j];
        this.addObjectToCanvas(o);
      }
    }
    for (_k = 0, _len2 = walls.length; _k < _len2; _k++) {
      o = walls[_k];
      this.addObjectToCanvas(o);
    }
    if (this.layer === this.CONST_LAYERS.FLOOR) {
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
    if (((o.type === 'shelf' || o.type === 'curvedShelf') && this.layer === this.CONST_LAYERS.SHELF) || (o.type === 'wall' && this.layer === this.CONST_LAYERS.WALL) || (o.type === 'beacon' && this.layer === this.CONST_LAYERS.BEACON) || (o.type === 'floor' && this.layer === this.CONST_LAYERS.FLOOR)) {
      object.selectable = true;
    } else {
      object.selectable = false;
      object.opacity = 0.5;
    }
    return this.canvas.add(object);
  },
  setCanvasProperty: function() {
    $('#canvas_width').html(this.canvas.getWidth());
    $('#canvas_height').html(this.canvas.getHeight());
    $('#canvas_centerX').html(this.centerX);
    $('#canvas_centerY').html(this.centerY);
    $('#canvas_bgscale').val(this.backgroundScaleFactor);
    $('#canvas_bgopacity').val(this.backgroundOpacity);
    $('#canvas_lon').val(this.xyLongitude);
    $('#canvas_lat').val(this.xyLatitude);
    $('#canvas_angle').val(this.canvas.angle);
    return $('.zoom').html((this.scaleFactor * 100).toFixed(0) + '%');
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
