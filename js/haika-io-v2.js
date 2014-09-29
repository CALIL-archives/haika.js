$.extend(haika, {
  _dataId: null,
  _revision: null,
  _collision: null,
  _api_load_endpoint: '/api/floor/load',
  _api_save_endpoint: '/api/floor/save',
  _geojson: {},
  nowSaving: false,
  close: function() {
    this._dataId = null;
    this._revision = null;
    this._collision = null;
    this._geojson = {};
    this.objects.length = 0;
    return this.background_image = null;
  },
  openFromApi: function(id, revision, success, error) {
    if (revision == null) {
      revision = null;
    }
    if (success == null) {
      success = null;
    }
    if (error == null) {
      error = null;
    }
    if (this._dataId) {
      this.close();
    }
    if (this.nowSaving) {
      error && error('保存処理中のため読み込めませんでした');
    }
    return $.ajax({
      url: this._api_load_endpoint,
      type: 'POST',
      cache: false,
      dataType: 'json',
      data: {
        id: id,
        revision: revision
      },
      error: (function(_this) {
        return function() {
          return error && error('データが読み込めませんでした');
        };
      })(this),
      success: (function(_this) {
        return function(json) {
          if (json.locked) {
            return error && error('データはロックされています');
          }
          _this._dataId = json.id;
          _this._revision = json.revision;
          _this._collision = json.collision;
          _this._geojson = json.data;
          _this.loadFromGeoJson();
          $(_this).trigger('haika:load');
          return success && success();
        };
      })(this)
    });
  },
  loadFromGeoJson: function(geojson) {
    var key, klass, object, schema, shape, _i, _len, _ref;
    if (geojson == null) {
      geojson = null;
    }
    if (!geojson) {
      geojson = this._geojson;
    }
    this.options.bgscale = geojson.haika.bgscale ? geojson.haika.bgscale : 4.425;
    this.options.bgopacity = geojson.haika.bgopacity;
    if (geojson.haika.bgurl != null) {
      this.options.bgurl = geojson.haika.bgurl;
    } else {
      this.options.bgurl = '';
    }
    this.options.angle = geojson.haika.angle;
    if (geojson.haika.geojson_scale != null) {
      this.options.geojson_scale = geojson.haika.geojson_scale;
    }
    if ((geojson.haika.lon != null) && (geojson.haika.lat != null)) {
      this.options.lon = parseFloat(geojson.haika.lon);
      this.options.lat = parseFloat(geojson.haika.lat);
    }
    if (geojson && geojson.features.length > 0) {
      _ref = geojson.features;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        if (object.properties.id > this.lastId) {
          this.lastId = object.properties.id;
        }
        klass = this.getClass(object.properties.type);
        shape = new klass({
          id: object.properties.id,
          top: this.transformTopY_cm2px(object.properties.top_cm),
          left: this.transformLeftX_cm2px(object.properties.left_cm),
          top_cm: object.properties.top_cm,
          left_cm: object.properties.left_cm,
          fill: object.properties.fill,
          stroke: object.properties.stroke,
          angle: object.properties.angle
        });
        schema = shape.constructor.prototype.getJsonSchema();
        for (key in schema.properties) {
          shape[key] = object.properties[key];
        }
        this.add(shape);
      }
    }
    return this.render();
  },
  getCanvasProperty: function() {
    return {
      state: this.state,
      scale: this.scale,
      centerX: this.centerX,
      centerY: this.centerY,
      bgurl: this.options.bgurl,
      bgscale: this.options.bgscale,
      bgopacity: this.options.bgopacity,
      lon: this.options.lon,
      lat: this.options.lat,
      angle: this.options.angle,
      geojson_scale: this.options.geojson_scale
    };
  },
  saveTimeout: null,
  save: function() {
    var data, param;
    this.prepareData();
    log('save');
    if (this.nowSaving) {
      setTimeout((function(_this) {
        return function() {
          return _this.save();
        };
      })(this), 500);
      return;
    }
    this.nowSaving = true;
    param = this.toGeoJSON();
    param['haika'] = this.getCanvasProperty();
    param['haika']['version'] = 1;
    param = JSON.stringify(param);
    data = {
      id: this._dataId,
      revision: this._revision,
      collision: this._collision,
      data: param
    };
    $.ajax({
      url: this._api_save_endpoint,
      type: 'POST',
      data: data,
      dataType: 'text',
      success: (function(_this) {
        return function(data) {
          var json;
          json = JSON.parse(data);
          if (json.success === false) {
            alert(json.message);
            location.reload();
          } else {
            _this._revision = json.revision;
            _this._collision = json.collision;
          }
          _this.nowSaving = false;
          if (_this.saveTimeout) {
            clearTimeout(_this.saveTimeout);
            return _this.saveTimeout = null;
          }
        };
      })(this),
      error: (function(_this) {
        return function() {
          _this.nowSaving = false;
          if (_this.saveTimeout) {
            clearTimeout(_this.saveTimeout);
            _this.saveTimeout = null;
          }
          return alert('エラーが発生しました');
        };
      })(this)
    });
    return $(this).trigger('haika:save');
  },
  saveDelay: function() {
    this.prepareData();
    if (!this.saveTimeout) {
      clearTimeout(this.saveTimeout);
    }
    return this.saveTimeout = setTimeout((function(_this) {
      return function() {
        return _this.save();
      };
    })(this), 2000);
  },
  prepareData: function() {
    var count, key, object, schema, _i, _len, _ref, _results;
    _ref = this.canvas.getObjects();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      count = this.getCountFindById(object.id);
      this.objects[count].id = object.id;
      this.objects[count].type = object.type;
      this.objects[count].top_cm = this.transformTopY_px2cm(object.top);
      object.top_cm = this.objects[count].top_cm;
      this.objects[count].left_cm = this.transformLeftX_px2cm(object.left);
      object.left_cm = this.objects[count].left_cm;
      this.objects[count].scaleX = object.scaleX / this.scale;
      this.objects[count].scaleY = object.scaleY / this.scale;
      this.objects[count].angle = object.angle;
      this.objects[count].fill = object.fill;
      this.objects[count].stroke = object.stroke;
      schema = object.constructor.prototype.getJsonSchema();
      _results.push((function() {
        var _results1;
        _results1 = [];
        for (key in schema.properties) {
          _results1.push(this.objects[count][key] = object[key]);
        }
        return _results1;
      }).call(this));
    }
    return _results;
  },
  toGeoJSON: function() {
    var data, features, geojson, object, _i, _len, _ref;
    features = [];
    _ref = this.canvas.getObjects();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      geojson = object.toGeoJSON();
      features.push(geojson);
    }
    data = {
      "type": "FeatureCollection",
      "features": features
    };
    return data;
  },
  toSVG: function() {
    var data, end, object, start, svg, svgs, _i, _len, _ref;
    svgs = [];
    _ref = this.canvas.getObjects();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      svg = object.toSVG();
      svgs.push(svg);
    }
    log(svgs);
    start = '<svg viewBox="0 0 1024 768">';
    end = '</svg>';
    data = [start, svgs.join(''), end].join('');
    log(data);
    return data;
  },
  "import": function() {
    var id, url;
    id = window.prompt('idを入力してください', '');
    url = "http://lab.calil.jp/haika_store/data/" + this.id + ".json";
    return $.ajax({
      url: url,
      type: 'GET',
      cache: false,
      dataType: 'text',
      success: (function(_this) {
        return function(data) {
          var canvas, json;
          json = JSON.parse(data);
          canvas = json.canvas;
          json.geojson.haika = json.canvas;
          return _this.loadRender(json.geojson);
        };
      })(this),
      error: (function(_this) {
        return function() {
          return alert('読み込めません');
        };
      })(this)
    });
  }
});

//# sourceMappingURL=haika-io-v2.js.map
