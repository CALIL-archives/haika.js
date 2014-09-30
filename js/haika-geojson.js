$.extend(haika, {
  loadFromGeoJson: function(geojson) {
    var key, klass, object, schema, shape, _i, _len, _ref, _results;
    if (geojson == null) {
      geojson = null;
    }
    if (!geojson) {
      geojson = this._geojson;
    }
    if (geojson.haika.backgroundScaleFactor != null) {
      this.backgroundScaleFactor = geojson.haika.backgroundScaleFactor;
    }
    if (!this.backgroundScaleFactor) {
      this.backgroundScaleFactor = 1;
    }
    if (geojson.haika.backgroundOpacity != null) {
      this.backgroundOpacity = geojson.haika.backgroundOpacity;
    }
    if (!this.backgroundOpacity) {
      this.backgroundOpacity = 1;
    }
    if (geojson.haika.backgroundUrl != null) {
      this.backgroundUrl = geojson.haika.backgroundUrl;
    } else {
      this.backgroundUrl = '';
    }
    if (geojson.haika.xyAngle != null) {
      this.xyAngle = geojson.haika.xyAngle;
    }
    if (geojson.haika.xyScaleFactor != null) {
      this.xyScaleFactor = geojson.haika.xyScaleFactor;
    }
    if ((geojson.haika.xyLongitude != null) && (geojson.haika.xyLatitude != null)) {
      this.xyLongitude = geojson.haika.xyLongitude;
      this.xyLatitude = geojson.haika.xyLatitude;
    }
    if (geojson && geojson.features.length > 0) {
      _ref = geojson.features;
      _results = [];
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
        _results.push(this.add(shape));
      }
      return _results;
    }
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
      "features": features,
      "haika": {
        backgroundUrl: this.backgroundUrl,
        backgroundScaleFactor: this.backgroundScaleFactor,
        backgroundOpacity: this.backgroundOpacity,
        xyLongitude: this.xyLongitude,
        xyLatitude: this.xyLatitude,
        xyAngle: this.xyAngle,
        xyScaleFactor: this.xyScaleFactor,
        version: 1
      }
    };
    return data;
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
      this.objects[count].left_cm = this.transformLeftX_px2cm(object.left);
      this.objects[count].scaleX = object.scaleX / this.scaleFactor;
      this.objects[count].scaleY = object.scaleY / this.scaleFactor;
      this.objects[count].angle = object.angle;
      this.objects[count].fill = object.fill;
      this.objects[count].stroke = object.stroke;
      object.top_cm = this.objects[count].top_cm;
      object.left_cm = this.objects[count].left_cm;
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
            coordinate = proj4('EPSG:3857', 'EPSG:4326', [x, y]);
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
      mapCenter = proj4("EPSG:4326", "EPSG:3857", [this.xyLongitude, this.xyLatitude]);
      if (mapCenter) {
        coordinates = [];
        _ref1 = object.geometry.coordinates[0];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          geometry = _ref1[_j];
          x = geometry[0] * this.xyScaleFactor;
          y = geometry[1] * this.xyScaleFactor;
          new_coordinate = fabric.util.rotatePoint(new fabric.Point(x, y), new fabric.Point(0, 0), fabric.util.degreesToRadians(-this.xyAngle));
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

//# sourceMappingURL=haika-geojson.js.map
