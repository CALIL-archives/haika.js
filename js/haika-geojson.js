$.extend(haika, {
  loadFromGeoJson: function() {
    var header, object, _i, _len, _ref, _results;
    if (this._geojson.haika != null) {
      header = this._geojson.haika;
    } else {
      header = {};
    }
    this.backgroundScaleFactor = header.backgroundScaleFactor != null ? header.backgroundScaleFactor : 1;
    this.backgroundOpacity = header.backgroundOpacity != null ? header.backgroundOpacity : 1;
    this.backgroundUrl = header.backgroundUrl != null ? header.backgroundUrl : '';
    this.xyAngle = header.xyAngle != null ? header.xyAngle : 0;
    this.xyScaleFactor = header.xyScaleFactor != null ? header.xyScaleFactor : 1;
    this.xyLongitude = header.xyLongitude != null ? header.xyLongitude : null;
    this.xyLatitude = header.xyLatitude != null ? header.xyLatitude : null;
    this.objects = [];
    if (this._geojson.features != null) {
      _ref = this._geojson.features;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        _results.push(this.objects.push(object.properties));
      }
      return _results;
    }
  },
  prepareData: function() {
    var count, object, _data, _i, _len, _ref, _results;
    log('prepareData');
    if (!this.canvas) {
      return;
    }
    _ref = this.canvas.getObjects();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      if (object.group != null) {
        object.top_cm = this.transformTopY_px2cm(object.top + object.group.top);
        object.left_cm = this.transformLeftX_px2cm(object.left + object.group.left);
      } else {
        object.top_cm = this.transformTopY_px2cm(object.top);
        object.left_cm = this.transformLeftX_px2cm(object.left);
      }
      count = this.getCountFindById(object.id);
      _data = object.toGeoJSON();
      _results.push(this.objects[count] = _data.properties);
    }
    return _results;
  },
  toGeoJSON: function() {
    var data, features, geojson, object, _i, _len, _ref;
    features = [];
    if (this.canvas) {
      _ref = this.canvas.getObjects();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        geojson = object.toGeoJSON();
        features.push(geojson);
      }
    }
    if (!this.canvas) {
      features = this._geojson.features;
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
  cloneGeoJSON: function() {
    var geojson;
    geojson = $.extend(true, {}, this.toGeoJSON());
    return geojson;
  },
  createGeoJSON: function(geojson) {
    geojson = this.rotateGeoJSON(geojson);
    geojson = this.mergeGeoJSON(geojson);
    geojson = this.scaleGeoJSON(geojson);
    geojson = this.transformGeoJSON(geojson);
    return geojson;
  },
  changeFeatures: function(geojson, func) {
    var coordinate, coordinates, features, geometry, object, x, y, _i, _j, _len, _len1, _ref, _ref1;
    features = [];
    _ref = geojson.features;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      coordinates = [];
      _ref1 = object.geometry.coordinates[0];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        geometry = _ref1[_j];
        x = geometry[0];
        y = geometry[1];
        coordinate = func(x, y, geojson);
        coordinates.push(coordinate);
      }
      object.geometry.coordinates = [coordinates];
      features.push(object);
    }
    geojson.features = features;
    return geojson;
  },
  rotateGeoJSON: function(geojson) {
    geojson = this.changeFeatures(geojson, function(x, y, geojson) {
      var cordinate;
      cordinate = fabric.util.rotatePoint(new fabric.Point(x, y), new fabric.Point(0, 0), fabric.util.degreesToRadians(-geojson.haika.xyAngle));
      return [cordinate.x, cordinate.y];
    });
    return geojson;
  },
  mergeGeoJSON: function(geojson) {
    var coordinates, cpr, features, first, first_coordinates, geometry, object, p, path, paths, solution_paths, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1;
    if (geojson.features.length <= 0) {
      return geojson;
    }
    features = [];
    paths = [];
    _ref = geojson.features;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      if (object.properties.type !== 'floor') {
        features.push(object);
      }
      if (object.properties.type === 'floor') {
        path = [];
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
    cpr = new ClipperLib.Clipper();
    for (_k = 0, _len2 = paths.length; _k < _len2; _k++) {
      path = paths[_k];
      cpr.AddPaths(path, ClipperLib.PolyType.ptSubject, true);
    }
    solution_paths = new ClipperLib.Paths();
    cpr.Execute(ClipperLib.ClipType.ctUnion, solution_paths, ClipperLib.PolyFillType.pftNonZero, ClipperLib.PolyFillType.pftNonZero);
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
      features.unshift({
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [coordinates]
        },
        "properties": {
          "type": "floor",
          "fill": "#FFFFFF",
          "stroke": "#000000"
        }
      });
    }
    geojson.features = features;
    return geojson;
  },
  scaleGeoJSON: function(geojson) {
    geojson = this.changeFeatures(geojson, function(x, y, geojson) {
      x = x * geojson.haika.xyScaleFactor;
      y = y * geojson.haika.xyScaleFactor;
      return [x, y];
    });
    return geojson;
  },
  transformGeoJSON: function(geojson) {

    /* 定数 */
    var PI, cos, earthCircumference, earthRadius, latSecPmetre, metreToLatitudeSecond, metreToLongitudeSecond, radian;
    PI = Math.PI;
    radian = (2 * PI) / 360;
    earthRadius = 6378150;
    earthCircumference = 2 * PI * earthRadius;
    latSecPmetre = (360 * 60 * 60) / earthCircumference;
    cos = Math.cos;
    metreToLatitudeSecond = function(metre) {
      return metre * latSecPmetre;
    };
    metreToLongitudeSecond = function(metre, lat) {
      return metre * ((360 * 60 * 60) / (earthCircumference * cos(lat * radian)));
    };
    geojson = this.changeFeatures(geojson, function(x, y, geojson) {
      var xHour, xSecond, yHour, ySecond;
      ySecond = metreToLatitudeSecond(y / 100);
      yHour = ySecond / 3600;
      xSecond = metreToLongitudeSecond(x / 100, geojson.haika.xyLatitude + yHour);
      xHour = xSecond / 3600;
      return [geojson.haika.xyLongitude + xHour, geojson.haika.xyLatitude + yHour];
    });
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
