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
    readOnly: false
  },
  init: function(options) {
    var $hikaDiv, canvas, timeout;
    options = $.extend(this.options, options);
    this.html(options.containerSelector);
    $hikaDiv = $('#' + options.divId);
    this.readOnly = options.readOnly;
    $hikaDiv.prepend("<canvas id=\"" + options.canvasId + "\" unselectable=\"on\"></canvas>");
    this.scaleFactor = options.scaleFactor;
    this.layer = this.CONST_LAYERS.SHELF;
    canvas = new fabric.Canvas(options.canvasId, {
      width: $hikaDiv.width(),
      height: $hikaDiv.height(),
      rotationCursor: 'url("img/rotate.cur") 10 10, crosshair'
    });
    canvas.selectionBorderColor = 'black';
    canvas.selectionLineWidth = 1;
    canvas.selectionDashArray = [2, 2];
    $(window).resize((function(_this) {
      return function() {
        _this.canvas.setWidth($hikaDiv.width());
        _this.canvas.setHeight($hikaDiv.height());
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
    fabric.Canvas.prototype._shouldClearSelection = function(e, target) {
      var activeGroup;
      activeGroup = this.getActiveGroup();
      return !target || (target && activeGroup && !activeGroup.contains(target) && activeGroup !== target && !e.shiftKey) || (target && !target.evented) || (target && !target.selectable);
    };
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
    canvas._renderBackground = (function(_this) {
      return function(ctx) {
        var clip_path, clipper, convex, convex_path, geojson, i, is_first, item, items, j, k, l, len, len1, len2, len3, len4, len5, len6, m, n, object, p, path, q, r, ref, ref1, ref2, ref3, result_paths, ret;
        convex = new ConvexHullGrahamScan();
        ref = _this.canvas.getObjects();
        for (j = 0, len = ref.length; j < len; j++) {
          object = ref[j];
          geojson = object.toGeoJSON();
          if (geojson.properties.type === 'floor' && geojson.properties.is_negative) {
            continue;
          }
          ref1 = geojson.geometry.coordinates[0];
          for (k = 0, len1 = ref1.length; k < len1; k++) {
            item = ref1[k];
            convex.addPoint(item[0], -item[1]);
          }
        }
        ret = convex.getHull();
        if (ret.length > 0) {
          convex_path = [];
          for (l = 0, len2 = ret.length; l < len2; l++) {
            i = ret[l];
            p = {
              X: i.x,
              Y: i.y
            };
            convex_path.push(p);
          }
          clipper = new ClipperLib.Clipper();
          clipper.AddPaths([convex_path], ClipperLib.PolyType.ptSubject, true);
          ref2 = _this.canvas.getObjects();
          for (m = 0, len3 = ref2.length; m < len3; m++) {
            object = ref2[m];
            geojson = object.toGeoJSON();
            if (geojson.properties.type === 'floor' && geojson.properties.is_negative) {
              items = geojson.geometry.coordinates[0];
              clip_path = [];
              for (n = 0, len4 = items.length; n < len4; n++) {
                item = items[n];
                clip_path.push({
                  X: item[0],
                  Y: -item[1]
                });
              }
              clipper.AddPaths([clip_path], ClipperLib.PolyType.ptClip, true);
            }
          }
          result_paths = new ClipperLib.Paths();
          clipper.Execute(ClipperLib.ClipType.ctDifference, result_paths, ClipperLib.PolyFillType.pftNonZero, ClipperLib.PolyFillType.pftNonZero);
          _this.floor_cache = result_paths;
        } else {
          _this.floor_cache = null;
        }
        if (_this.floor_cache) {
          ctx.save();
          ctx.beginPath();
          ctx.lineWidth = Math.floor(Math.min(20, Math.max(3, 200 * _this.scaleFactor)));
          log(Math.floor(Math.min(20, Math.max(5, 20 * _this.scaleFactor))));
          ctx.strokeStyle = "#525252";
          ctx.fillStyle = "#ffffff";
          ref3 = _this.floor_cache;
          for (q = 0, len5 = ref3.length; q < len5; q++) {
            path = ref3[q];
            is_first = true;
            for (r = 0, len6 = path.length; r < len6; r++) {
              i = path[r];
              if (is_first) {
                ctx.moveTo(haika.cm2px_x(i.X), haika.cm2px_y(i.Y));
                is_first = false;
              } else {
                ctx.lineTo(haika.cm2px_x(i.X), haika.cm2px_y(i.Y));
              }
            }
            ctx.lineTo(haika.cm2px_x(path[0].X), haika.cm2px_y(path[0].Y));
            ctx.closePath();
          }
          ctx.stroke();
          ctx.fill();
          ctx.clip();
          haika_utils.drawBackground(_this, ctx);
          haika_utils.drawGridLines(_this, ctx);
          return ctx.restore();
        }
      };
    })(this);
    canvas._renderOverlay = (function(_this) {
      return function(ctx) {
        var i, is_first, j, k, len, len1, path, ref;
        haika_utils.drawScale(_this, ctx);
        if (_this.layer === _this.CONST_LAYERS.FLOOR) {
          if (_this.floor_cache) {
            ctx.save();
            ctx.beginPath();
            ctx.lineWidth = 4;
            ctx.strokeStyle = "#ff0000";
            ref = _this.floor_cache;
            for (j = 0, len = ref.length; j < len; j++) {
              path = ref[j];
              is_first = true;
              for (k = 0, len1 = path.length; k < len1; k++) {
                i = path[k];
                if (is_first) {
                  ctx.moveTo(haika.cm2px_x(i.X), haika.cm2px_y(i.Y));
                  is_first = false;
                } else {
                  ctx.lineTo(haika.cm2px_x(i.X), haika.cm2px_y(i.Y));
                }
              }
              ctx.lineTo(haika.cm2px_x(path[0].X), haika.cm2px_y(path[0].Y));
              ctx.closePath();
            }
            ctx.stroke();
            return ctx.restore();
          }
        }
      };
    })(this);
    if (!this.readOnly) {
      initAligningGuidelines(canvas);
    }
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
    this.canvas.on('object:modified', (function(_this) {
      return function(e) {
        var object;
        object = e.target;
        if (object.__modifiedShelf != null) {
          object.__modifiedShelf();
        }
        object.top_cm = _this.px2cm_y(object.top);
        object.left_cm = _this.px2cm_x(object.left);
        return _this.saveDelay();
      };
    })(this));
    timeout = false;
    $(this.canvas.wrapperEl).on("mousewheel", (function(_this) {
      return function(e) {
        var delta;
        delta = e.originalEvent.wheelDelta / 120;
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
    var j, lastId, len, object, ref;
    lastId = 0;
    ref = this.objects;
    for (j = 0, len = ref.length; j < len; j++) {
      object = ref[j];
      if (object.id > lastId) {
        lastId = object.id;
      }
    }
    return lastId + 1;
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
    var j, len, ref, results, target;
    if (this.canvas.getActiveObject()) {
      target = this.canvas.getActiveObject();
      return func(target);
    } else if (this.canvas.getActiveGroup()) {
      ref = this.canvas.getActiveGroup().getObjects();
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        target = ref[j];
        results.push(func(target));
      }
      return results;
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
    var group, j, k, len, len1, new_id, new_objects, object, ref;
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
    ref = this.canvas.getObjects();
    for (j = 0, len = ref.length; j < len; j++) {
      object = ref[j];
      for (k = 0, len1 = new_ids.length; k < len1; k++) {
        new_id = new_ids[k];
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
    var j, len, new_ids, object, ref;
    if (this.clipboard.length > 0) {
      new_ids = [];
      ref = this.clipboard;
      for (j = 0, len = ref.length; j < len; j++) {
        object = ref[j];
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
    var ids, j, len, object, ref;
    this.canvas.discardActiveGroup();
    ids = [];
    ref = this.canvas.getObjects();
    for (j = 0, len = ref.length; j < len; j++) {
      object = ref[j];
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
    var activeIds, beacons, floors, j, k, l, len, len1, len2, len3, len4, len5, len6, len7, len8, m, n, o, q, r, ref, s, shelfs, t, walls;
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
    ref = this.objects;
    for (j = 0, len = ref.length; j < len; j++) {
      o = ref[j];
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
    if (this.layer === this.CONST_LAYERS.FLOOR) {
      for (k = 0, len1 = walls.length; k < len1; k++) {
        o = walls[k];
        this.addObjectToCanvas(o);
      }
      for (l = 0, len2 = shelfs.length; l < len2; l++) {
        o = shelfs[l];
        this.addObjectToCanvas(o);
      }
      for (m = 0, len3 = beacons.length; m < len3; m++) {
        o = beacons[m];
        this.addObjectToCanvas(o);
      }
      for (n = 0, len4 = floors.length; n < len4; n++) {
        o = floors[n];
        this.addObjectToCanvas(o);
      }
    } else {
      for (q = 0, len5 = floors.length; q < len5; q++) {
        o = floors[q];
        this.addObjectToCanvas(o);
      }
      for (r = 0, len6 = walls.length; r < len6; r++) {
        o = walls[r];
        this.addObjectToCanvas(o);
      }
      for (s = 0, len7 = shelfs.length; s < len7; s++) {
        o = shelfs[s];
        this.addObjectToCanvas(o);
      }
      for (t = 0, len8 = beacons.length; t < len8; t++) {
        o = beacons[t];
        this.addObjectToCanvas(o);
      }
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
    object.top = this.cm2px_y(o.top_cm);
    object.left = this.cm2px_x(o.left_cm);
    object.selectable = o.selectable;
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
    var bound, group, j, k, left, len, len1, object, ref, ref1;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      left = 0;
      ref = group._objects;
      for (j = 0, len = ref.length; j < len; j++) {
        object = ref[j];
        bound = object.getBoundingRect();
        left = Math.min(bound.left, left);
      }
      ref1 = group._objects;
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        object = ref1[k];
        bound = object.getBoundingRect();
        object.left = left + bound.width / 2;
      }
      this.saveDelay();
      return this.canvas.renderAll();
    }
  },
  alignRight: function() {
    var bound, group, j, k, left, len, len1, object, ref, ref1;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      left = 0;
      ref = group._objects;
      for (j = 0, len = ref.length; j < len; j++) {
        object = ref[j];
        bound = object.getBoundingRect();
        left = Math.max(bound.left + bound.width, left);
      }
      ref1 = group._objects;
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        object = ref1[k];
        bound = object.getBoundingRect();
        object.left = left - bound.width / 2;
      }
      this.saveDelay();
      return this.canvas.renderAll();
    }
  },
  alignCenter: function() {
    var group, j, len, object, ref;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      ref = group._objects;
      for (j = 0, len = ref.length; j < len; j++) {
        object = ref[j];
        object.left = 0;
      }
      this.saveDelay();
      return this.canvas.renderAll();
    }
  },
  alignTop: function() {
    var bound, group, j, k, len, len1, object, ref, ref1, top;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      top = 0;
      ref = group._objects;
      for (j = 0, len = ref.length; j < len; j++) {
        object = ref[j];
        bound = object.getBoundingRect();
        top = Math.min(bound.top, top);
      }
      ref1 = group._objects;
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        object = ref1[k];
        bound = object.getBoundingRect();
        object.top = top + bound.height / 2;
      }
      this.saveDelay();
      return this.canvas.renderAll();
    }
  },
  alignBottom: function() {
    var bound, group, j, k, len, len1, object, ref, ref1, top;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      top = 0;
      ref = group._objects;
      for (j = 0, len = ref.length; j < len; j++) {
        object = ref[j];
        bound = object.getBoundingRect();
        top = Math.max(bound.top + bound.height, top);
      }
      ref1 = group._objects;
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        object = ref1[k];
        bound = object.getBoundingRect();
        object.top = top - bound.height / 2;
      }
      this.saveDelay();
      return this.canvas.renderAll();
    }
  },
  alignVcenter: function() {
    var group, j, len, object, ref;
    group = this.canvas.getActiveGroup();
    if (group._objects) {
      ref = group._objects;
      for (j = 0, len = ref.length; j < len; j++) {
        object = ref[j];
        object.top = 0;
      }
      this.saveDelay();
      return this.canvas.renderAll();
    }
  }
};
