$.extend(haika, {
  isLocal: function() {
    return location.protocol === 'file:' || location.port !== '';
  },
  setHashChange: function() {
    return $(window).bind("hashchange", function() {
      return location.reload();
    });
  },
  load: function() {
    var data;
    if (location.hash !== '' && location.hash.length !== 7) {
      location.hash = sprintf('%06d', location.hash.split('#')[1]);
      location.reload();
      return;
    }
    if (this.isLocal()) {
      data = {
        canvas: JSON.parse(localStorage.getItem('canvas')),
        geojson: JSON.parse(localStorage.getItem('geojson'))
      };
      log(data);
      this.loadRender(data);
      $(this).trigger('haika:load');
      return;
    }
    if (location.hash !== '') {
      this.id = location.hash.split('#')[1];
      this.load_server();
    } else {
      this.getHaikaId();
    }
    return $(this).trigger('haika:load');
  },
  loadRender: function(data) {
    var canvas, geojson, key, klass, object, schema, shape, _i, _len, _ref;
    log(data);
    canvas = data.canvas;
    geojson = data.geojson;
    if (canvas) {
      log(canvas);
      this.state = canvas.state;
      $('.nav a.' + this.state).tab('show');
      this.scale = canvas.scale;
      $('.zoom').html((this.scale * 100).toFixed(0) + '%');
      this.centerX = canvas.centerX;
      this.centerY = canvas.centerY;
      this.bgimg_data = canvas.bgimg_data;
      this.options.bgscale = canvas.bgscale ? canvas.bgscale : 4.425;
      this.options.bgopacity = canvas.bgopacity;
      this.options.angle = canvas.angle;
      if (canvas.geojson_scale != null) {
        this.options.geojson_scale = canvas.geojson_scale;
      }
      if (this.isLocal()) {
        this.setBg();
      } else {
        if (canvas.bgurl != null) {
          this.loadBgFromUrl(canvas.bgurl);
        }
      }
      if (canvas.lon != null) {
        this.options.lon = parseFloat(canvas.lon);
        this.options.lat = parseFloat(canvas.lat);
      }
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
  getHaikaId: function() {
    var url;
    url = '/haika_store/index.php';
    return $.ajax({
      url: url,
      type: "GET",
      cache: false,
      dataType: "json",
      error: function() {},
      success: (function(_this) {
        return function(data) {
          location.hash = data.id;
          _this.id = data.id;
          return _this.setHashChange();
        };
      })(this)
    });
  },
  load_server: function() {
    var url;
    url = "/haika_store/data/" + this.id + ".json";
    return $.ajax({
      url: url,
      type: "GET",
      cache: false,
      dataType: "text",
      error: (function(_this) {
        return function() {
          return alert('load error');
        };
      })(this),
      success: (function(_this) {
        return function(data) {
          log(data);
          try {
            data = JSON.parse(data);
          } catch (_error) {
            alert('parse error');
            $(window).off('beforeunload');
            location.href = "/haika_store/data/" + _this.id + ".json";
          }
          _this.loadRender(data);
          return _this.setHashChange();
        };
      })(this)
    });
  },
  getCanvasProperty: function() {
    return {
      state: this.state,
      scale: this.scale,
      centerX: this.centerX,
      centerY: this.centerY,
      bgimg_data: this.bgimg_data,
      bgurl: this.options.bgurl,
      bgscale: this.options.bgscale,
      bgopacity: this.options.bgopacity,
      lon: this.options.lon,
      lat: this.options.lat,
      angle: this.options.angle,
      geojson_scale: this.options.geojson_scale
    };
  },
  saveLocal: function() {
    var canvas;
    canvas = this.getCanvasProperty();
    localStorage.setItem('canvas', JSON.stringify(canvas));
    return localStorage.setItem('geojson', JSON.stringify(this.toGeoJSON(), null, 4));
  },
  saveServer: function() {
    var data, param, url;
    param = {
      canvas: this.getCanvasProperty(),
      geojson: this.toGeoJSON()
    };
    param = JSON.stringify(param);
    log(param);
    data = {
      ext: 'json',
      id: this.id,
      data: param
    };
    url = '/haika_store/index.php';
    $.ajax({
      url: url,
      type: "POST",
      data: data,
      dataType: "json",
      error: function() {},
      success: (function(_this) {
        return function(data) {
          return log(data);
        };
      })(this)
    });
    return this.saveGeoJson();
  },
  saveGeoJson: function() {
    var data, geojson, param, url;
    geojson = this.createGeoJson();
    param = JSON.stringify(geojson);
    data = {
      ext: 'geojson',
      id: this.id,
      data: param
    };
    url = '/haika_store/index.php';
    return $.ajax({
      url: url,
      type: "POST",
      data: data,
      dataType: "json",
      error: function() {},
      success: data > log(data)
    }, log('geojson save'));
  },
  save: function() {
    var object, _i, _len, _ref;
    log('save');
    _ref = this.canvas.getObjects();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      this.saveProperty(object);
    }
    this.saveLocal();
    if (!this.isLocal()) {
      this.saveServer();
    }
    return $(this).trigger('haika:save');
  },
  saveProperty: function(object, group) {
    var count, key, schema, _results;
    if (group == null) {
      group = false;
    }
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
    _results = [];
    for (key in schema.properties) {
      _results.push(this.objects[count][key] = object[key]);
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
  createGeoJson: function() {
    var EPSG3857_geojson, coordinate, coordinates, data, features, geojson, geometry, object, x, y, _i, _j, _len, _len1, _ref, _ref1;
    geojson = this.translateGeoJSON();
    features = [];
    if (geojson && geojson.features.length > 0) {
      _ref = geojson.features;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        if (object.properties.type !== 'floor') {
          coordinates = [];
          _ref1 = object.geometry.coordinates[0];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            geometry = _ref1[_j];
            x = geometry[0];
            y = geometry[1];
            coordinate = ol.proj.transform([x, y], "EPSG:3857", "EPSG:4326");
            coordinates.push(coordinate);
          }
          if (object.properties.type === 'merge_floor') {
            log(object.properties);
            object.properties.type = 'floor';
          }
          data = {
            "type": "Feature",
            "geometry": {
              "type": "Polygon",
              "coordinates": [coordinates]
            },
            "properties": object.properties
          };
          features.push(data);
        }
      }
    }
    EPSG3857_geojson = {
      "type": "FeatureCollection",
      "features": features
    };
    return EPSG3857_geojson;
  },
  translateGeoJSON: function() {
    var coordinate, coordinates, features, geojson, geometry, mapCenter, new_coordinate, object, x, y, _i, _j, _len, _len1, _ref, _ref1;
    geojson = this.toGeoJSON();
    geojson = this.mergeGeoJson(geojson);
    features = [];
    _ref = geojson.features;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      mapCenter = proj4("EPSG:4326", "EPSG:3857", [this.options.lon, this.options.lat]);
      if (mapCenter) {
        coordinates = [];
        _ref1 = object.geometry.coordinates[0];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          geometry = _ref1[_j];
          x = geometry[0] * this.options.geojson_scale;
          y = geometry[1] * this.options.geojson_scale;
          new_coordinate = fabric.util.rotatePoint(new fabric.Point(x, y), new fabric.Point(0, 0), fabric.util.degreesToRadians(-this.options.angle));
          coordinate = [mapCenter[0] + new_coordinate.x, mapCenter[1] + new_coordinate.y];
          coordinates.push(coordinate);
        }
        object.geometry.coordinates = [coordinates];
      }
      features.push(object);
    }
    geojson.features = features;
    return geojson;
  },
  mergeGeoJson: function(geojson) {
    var coordinates, cpr, first, first_coordinates, geometry, object, p, path, paths, solution_paths, succeeded, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1;
    paths = [];
    if (geojson && geojson.features.length > 0) {
      _ref = geojson.features;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        if (object.properties.type === 'floor') {
          path = [];
          log(object.geometry.coordinates[0]);
          _ref1 = object.geometry.coordinates[0];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            geometry = _ref1[_j];
            p = {
              X: geometry[0],
              Y: geometry[1]
            };
            path.push(p);
          }
          paths.push([path]);
        }
      }
      log(paths);
      cpr = new ClipperLib.Clipper();
      for (_k = 0, _len2 = paths.length; _k < _len2; _k++) {
        path = paths[_k];
        cpr.AddPaths(path, ClipperLib.PolyType.ptSubject, true);
      }
      solution_paths = new ClipperLib.Paths();
      succeeded = cpr.Execute(ClipperLib.ClipType.ctUnion, solution_paths, ClipperLib.PolyFillType.pftNonZero, ClipperLib.PolyFillType.pftNonZero);
      log(solution_paths);
      for (_l = 0, _len3 = solution_paths.length; _l < _len3; _l++) {
        path = solution_paths[_l];
        coordinates = [];
        first = true;
        for (_m = 0, _len4 = path.length; _m < _len4; _m++) {
          p = path[_m];
          if (first) {
            first_coordinates = [p.X, p.Y];
            first = false;
          }
          coordinates.push([p.X, p.Y]);
        }
        coordinates.push(first_coordinates);
        geojson.features.push({
          "type": "Feature",
          "geometry": {
            "type": "Polygon",
            "coordinates": [coordinates]
          },
          "properties": {
            "type": "merge_floor",
            "fill": "#FFFFFF",
            "stroke": "#FFFFFF"
          }
        });
      }
    }
    return geojson;
  }
});

//# sourceMappingURL=haika-io-v1.js.map
