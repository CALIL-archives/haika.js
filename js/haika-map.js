$.extend(haika, {
  map: {
    map: null,
    created: false,
    features: [],
    init: function() {
      return $('.map_setting').click((function(_this) {
        return function() {
          if ($('.haika_container').css('display') === 'block') {
            if (!_this.created) {
              _this.set();
              _this.created = true;
            }
            $('.haika_container').hide();
            $(document.body).css('background', '#333333');
            _this.redraw();
            $('.map_container').show();
            return $('#map_query').focus();
          } else {
            $(document.body).css('background', '#FFFFFF');
            $('.haika_container').show();
            return $('.map_container').hide();
          }
        };
      })(this));
    },
    redraw: function() {
      var feature, _i, _len, _ref;
      if (this.features.length > 0) {
        _ref = this.features;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          feature = _ref[_i];
          this.map.data.remove(feature);
        }
        return this.features = this.map.data.addGeoJson(this.createGeoJson());
      }
    },
    save: function(lat, lon) {
      $('#canvas_lon').val(lon);
      $('#canvas_lat').val(lat);
      haika.options.lon = lon;
      haika.options.lat = lat;
      return haika.save();
    },
    set: function() {
      var featureStyle;
      this.map = new google.maps.Map(document.getElementById('map'), {
        zoom: 20,
        maxZoom: 28,
        center: {
          lat: haika.options.lat,
          lng: haika.options.lon
        }
      });
      featureStyle = {
        fillColor: 'orange',
        strokeWeight: 1
      };
      this.map.data.setStyle(featureStyle);
      this.features = this.map.data.addGeoJson(haika.map.createGeoJson());
      google.maps.event.addListener(this.map, 'dragend', (function(_this) {
        return function() {
          var lat, lon;
          log(_this.map.getCenter());
          lon = _this.map.getCenter().lng();
          lat = _this.map.getCenter().lat();
          _this.save(lat, lon);
          return _this.redraw();
        };
      })(this));
      $('#map_search').submit((function(_this) {
        return function() {
          var address, geocoder;
          address = $('#map_query').val();
          geocoder = new google.maps.Geocoder();
          geocoder.geocode({
            address: address
          }, function(results, status) {
            if (status === google.maps.GeocoderStatus.OK) {
              _this.map.setCenter(results[0].geometry.location);
              _this.save(results[0].geometry.location.lat(), results[0].geometry.location.lng());
              return _this.redraw();
            } else {
              return alert("ジオコーディングがうまくいきませんでした。: " + status);
            }
          });
          return false;
        };
      })(this));
      $('#canvas_lat').change(function() {
        haika.options.lat = parseFloat($(this).val());
        return haika.save();
      });
      $('#canvas_lon').change(function() {
        haika.options.lon = parseFloat($(this).val());
        return haika.save();
      });
      $('#canvas_angle').change((function(_this) {
        return function() {
          return _this.redraw();
        };
      })(this));
      $('#canvas_angle').slider({
        tooltip: 'always',
        step: 1,
        min: 0,
        max: 360,
        value: haika.options.angle,
        formatter: (function(_this) {
          return function(value) {
            haika.options.angle = parseFloat(value);
            haika.save();
            _this.redraw();
            return value + '度';
          };
        })(this)
      });
      return $('#geojson_scale').slider({
        tooltip: 'always',
        step: 1,
        min: 0,
        max: 400,
        value: haika.options.geojson_scale * 100,
        formatter: (function(_this) {
          return function(value) {
            haika.options.geojson_scale = parseFloat(value) / 100;
            haika.save();
            _this.redraw();
            return value + '%';
          };
        })(this)
      });
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
  }
});

haika.map.init();

//# sourceMappingURL=haika-map.js.map
