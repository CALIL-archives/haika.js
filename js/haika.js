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
  readOnly: false,
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
    var canvas, timeout;
    if (options.divId == null) {
      throw 'CanvasのIDが未定義です';
    } else {
      this.divId = '#' + options.divId;
    }
    if (options.canvasId == null) {
      options.canvasId = 'haika-canvas-area';
    }
    if (options.readOnly != null) {
      this.readOnly = options.readOnly;
    }
    if (canvas) {
      throw '既に初期化されています';
    }
    $(this.divId).prepend("<canvas id=\"" + options.canvasId + "\" unselectable=\"on\"></canvas>");
    this.scaleFactor = options.scaleFactor != null ? options.scaleFactor : 1;
    this.layer = this.CONST_LAYERS.SHELF;
    canvas = new fabric.Canvas(options.canvasId, {
      width: $(this.divId).width(),
      height: $(this.divId).height(),
      rotationCursor: 'url("img/rotate.cur") 10 10, crosshair'
    });
    canvas.selectionBorderColor = 'black';
    canvas.selectionLineWidth = 1;
    canvas.selectionDashArray = [2, 2];
    $(window).resize((function(_this) {
      return function() {
        _this.canvas.setWidth($(_this.divId).width());
        _this.canvas.setHeight($(_this.divId).height());
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
    if (this.readOnly) {
      fabric.Object.prototype.padding = 5;
      fabric.Object.prototype.borderColor = '#0000FF';
      fabric.Object.prototype.cornerColor = '#0000FF';
    }
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
    if (!this.readOnly) {
      initAligningGuidelines(canvas);
    }
    this.canvas = canvas;
    this.canvas.parentHaika = this;
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
    this.canvas.on('object:modified', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        if (object.__modifiedShelf != null) {
          object.__modifiedShelf();
        }
        object.top_cm = _this.transformTopY_px2cm(object.top);
        object.left_cm = _this.transformLeftX_px2cm(object.left);
        return _this.saveDelay();
      };
    })(this));
    timeout = false;
    $(this.canvas.wrapperEl).on("mousewheel", (function(_this) {
      return function(e) {
        var delta;
        delta = e.originalEvent.wheelDelta / 120;
        log(delta);
        if (timeout) {
          return;
        } else {
          timeout = setTimeout(function() {
            return timeout = false;
          }, 100);
        }
        if (delta > 0) {
          _this.zoomIn();
        }
        if (delta < 0) {
          return _this.zoomOut();
        }
      };
    })(this));
    return $(this).trigger('haika:initialized');
  },
  setScale: function(newScale) {
    if (newScale >= 4) {
      newScale = 4;
    } else if (newScale <= 0.05) {
      newScale = 0.05;
    }
    this.scaleFactor = (newScale * 100).toFixed(0) / 100;
    this.render();
    return newScale;
  },
  setBackgroundUrl: function(url) {
    this.canvas.backgroundImage = null;
    this.backgroundUrl = url;
    return this.render();
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
  changeObject: function(id, json) {
    var changed, count, key, object, value;
    count = this.getCountFindById(id);
    object = this.objects[count];
    changed = false;
    for (key in json) {
      value = json[key];
      if (object[key] !== value) {
        object[key] = value;
        changed = true;
      }
    }
    if (changed) {
      this.render();
      return this.saveDelay();
    }
  },
  addObject: function(object) {
    object.id = this._getLatestId();
    object.top_cm = this.centerY;
    object.left_cm = this.centerX;
    if (object.fill == null) {
      object.fill = this.fillColor;
    }
    if (object.stroke == null) {
      object.stroke = this.strokeColor;
    }
    if (object.angle == null) {
      object.angle = 0;
    }
    this.objects.push(object);
    $(this).trigger('haika:add');
    this.render();
    this.saveDelay();
    this.activeGroup([object.id]);
    return this.undo.add(object.id);
  },
  applyActiveObjects: function(func) {
    var target, _i, _len, _ref, _results;
    if (this.canvas.getActiveObject()) {
      target = this.canvas.getActiveObject();
      return func(target);
    } else if (this.canvas.getActiveGroup()) {
      _ref = this.canvas.getActiveGroup().getObjects();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        target = _ref[_i];
        _results.push(func(target));
      }
      return _results;
    }
  },
  remove: function() {
    this.applyActiveObjects((function(_this) {
      return function(object) {
        _this.canvas.remove(object);
        return _this.objects.splice(_this.getCountFindById(object.id), 1);
      };
    })(this));
    this.canvas.deactivateAll();
    this.canvas.renderAll();
    this.saveDelay();
    return $(this).trigger('haika:remove');
  },
  bringToFront: function() {
    this.applyActiveObjects((function(_this) {
      return function(object) {
        var count, obj;
        object.bringToFront();
        count = _this.getCountFindById(object.id);
        obj = _this.objects[count];
        _this.objects.splice(count, 1);
        return _this.objects.push(obj);
      };
    })(this));
    this.canvas.renderAll();
    return this.saveDelay();
  },
  copy: function() {
    this.clipboard = [];
    this.applyActiveObjects((function(_this) {
      return function(object) {
        return _this.clipboard.push(object.toGeoJSON().properties);
      };
    })(this));
    return $(this).trigger('haika:copy');
  },
  duplicate: function() {
    var _clipboard;
    _clipboard = this.clipboard;
    this.copy();
    this.paste();
    this.clipboard = _clipboard;
    return $(this).trigger('haika:duplicate');
  },
  activeGroup: function(new_ids) {
    var group, new_id, new_objects, object, _i, _j, _len, _len1, _ref;
    if (new_ids.length === 0) {
      return;
    }
    if (new_ids.length === 1) {
      $(this.canvas.getObjects()).each((function(_this) {
        return function(i, obj) {
          if (obj.id === new_ids[0]) {
            return _this.canvas.setActiveObject(obj);
          }
        };
      })(this));
      return;
    }
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
    return this.canvas.setActiveGroup(group.setCoords()).renderAll();
  },
  paste: function() {
    var new_ids, object, _i, _len, _ref;
    if (this.clipboard.length > 0) {
      new_ids = [];
      _ref = this.clipboard;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        object.id = this._getLatestId();
        if (this.clipboard.length === 1) {
          this.clipboard[0].top_cm = this.centerY;
          this.clipboard[0].left_cm = this.centerX;
        }
        new_ids.push(object.id);
        this.objects.push(object);
      }
      this.render();
      this.saveDelay();
      this.activeGroup(new_ids);
    }
    return $(this).trigger('haika:paste');
  },
  selectAll: function() {
    var ids, object, _i, _len, _ref;
    this.canvas.discardActiveGroup();
    ids = [];
    _ref = this.objects;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      ids.push(object.id);
    }
    return this.activeGroup(ids);
  },
  unselectAll: function() {
    return this.canvas.deactivateAll().renderAll();
  },
  getClass: function(type) {
    if (this.INSTALLED_OBJECTS[type] != null) {
      return this.INSTALLED_OBJECTS[type]["class"];
    } else {
      throw '認識できないオブジェクトが含まれています';
    }
  },
  render: function() {
    var activeIds, beacons, floors, o, shelfs, walls, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref;
    if (!this.canvas.backgroundImage && this.backgroundUrl) {
      fabric.Image.fromURL(this.backgroundUrl, (function(_this) {
        return function(img) {
          img.set({
            originX: 'left',
            originY: 'top'
          });
          _this.canvas.backgroundImage = img;
          return _this.canvas.renderAll();
        };
      })(this));
    }
    activeIds = [];
    this.applyActiveObjects((function(_this) {
      return function(object) {
        return activeIds.push(object.id);
      };
    })(this));
    this.canvas.renderOnAddRemove = false;
    this.canvas._objects.length = 0;
    beacons = [];
    shelfs = [];
    walls = [];
    floors = [];
    _ref = this.objects;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      o = _ref[_i];
      if (this.layer === this.INSTALLED_OBJECTS[o.type].layer) {
        o.selectable = true;
      } else {
        o.selectable = false;
      }
      if (o.type === 'beacon') {
        beacons.push(o);
      }
      if (o.type === 'wall') {
        walls.push(o);
      }
      if (o.type === 'floor') {
        floors.push(o);
      }
      if (o.type === 'shelf' || o.type === 'curved_shelf') {
        shelfs.push(o);
      }
    }
    for (_j = 0, _len1 = floors.length; _j < _len1; _j++) {
      o = floors[_j];
      this.addObjectToCanvas(o);
    }
    for (_k = 0, _len2 = walls.length; _k < _len2; _k++) {
      o = walls[_k];
      this.addObjectToCanvas(o);
    }
    for (_l = 0, _len3 = shelfs.length; _l < _len3; _l++) {
      o = shelfs[_l];
      this.addObjectToCanvas(o);
    }
    for (_m = 0, _len4 = beacons.length; _m < _len4; _m++) {
      o = beacons[_m];
      this.addObjectToCanvas(o);
    }
    if (activeIds.length > 0) {
      this.activeGroup(activeIds);
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
    object.top = this.transformTopY_cm2px(o.top_cm);
    object.left = this.transformLeftX_cm2px(o.left_cm);
    object.selectable = o.selectable;
    if (!object.selectable) {
      object.opacity = 0.5;
    }
    if (this.readOnly) {
      object.lockMovementX = true;
      object.lockMovementY = true;
      object.lockRotation = true;
      object.lockScalingX = true;
      object.lockScalingY = true;
      object.lockUniScaling = true;
      object.hasControls = false;
      object.hoverCursor = 'pointer';
    }
    return this.canvas.add(object);
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
    object = this.canvas.getActiveObject() ? this.canvas.getActiveObject() : this.canvas.getActiveGroup();
    if (object) {
      object.top = object.top - this.getMovePixel(event);
      this.canvas.renderAll();
      return this.saveDelay();
    }
  },
  down: function(event) {
    var object;
    object = this.canvas.getActiveObject() ? this.canvas.getActiveObject() : this.canvas.getActiveGroup();
    if (object) {
      object.top = object.top + this.getMovePixel(event);
      this.canvas.renderAll();
      return this.saveDelay();
    }
  },
  left: function(event) {
    var object;
    object = this.canvas.getActiveObject() ? this.canvas.getActiveObject() : this.canvas.getActiveGroup();
    if (object) {
      object.left = object.left - this.getMovePixel(event);
      this.canvas.renderAll();
      return this.saveDelay();
    }
  },
  right: function(event) {
    var object;
    object = this.canvas.getActiveObject() ? this.canvas.getActiveObject() : this.canvas.getActiveGroup();
    if (object) {
      object.left = object.left + this.getMovePixel(event);
      this.canvas.renderAll();
      return this.saveDelay();
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
      this.saveDelay();
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
      this.saveDelay();
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
      this.saveDelay();
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
      this.saveDelay();
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
      this.saveDelay();
      return this.canvas.renderAll();
    }
  }
};

//# sourceMappingURL=haika.js.map
