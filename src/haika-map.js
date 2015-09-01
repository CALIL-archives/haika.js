$.extend(haika, {
  map: {
    map: null,
    convertLatLon: function(geojson) {

      /* 定数 */
      var PI, coordinates, cos, earthCircumference, earthRadius, features, geometry, i, j, latSecPmetre, len, len1, metreToLatitudeSecond, metreToLongitudeSecond, object, radian, ref, ref1, rx, ry, sin, x, xHour, xSecond, y, yHour, ySecond;
      PI = Math.PI;
      radian = (2 * PI) / 360;
      earthRadius = 6378150;
      earthCircumference = 2 * PI * earthRadius;
      latSecPmetre = (360 * 60 * 60) / earthCircumference;
      metreToLatitudeSecond = function(metre) {
        return metre * latSecPmetre;
      };
      metreToLongitudeSecond = function(metre, lat) {
        return metre * ((360 * 60 * 60) / (earthCircumference * Math.cos(lat * radian)));
      };
      features = [];
      ref = geojson.features;
      for (i = 0, len = ref.length; i < len; i++) {
        object = ref[i];
        if (object.properties.type === 'floor' || object.properties.type === 'beacon') {
          continue;
        }
        coordinates = [];
        ref1 = object.geometry.coordinates[0];
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          geometry = ref1[j];
          x = geometry[0];
          y = geometry[1];
          sin = Math.sin(fabric.util.degreesToRadians(-haika.xyAngle));
          cos = Math.cos(fabric.util.degreesToRadians(-haika.xyAngle));
          rx = x * cos - y * sin;
          ry = x * sin + y * cos;
          x = rx;
          y = ry;
          x = x * haika.xyScaleFactor;
          y = y * haika.xyScaleFactor;
          ySecond = metreToLatitudeSecond(y / 100);
          yHour = ySecond / 3600;
          xSecond = metreToLongitudeSecond(x / 100, haika.xyLatitude + yHour);
          xHour = xSecond / 3600;
          coordinates.push([haika.xyLongitude + xHour, haika.xyLatitude + yHour]);
        }
        object.geometry.coordinates = [coordinates];
        features.push(object);
      }
      geojson.features = features;
      return geojson;
    },
    draw: function() {
      this.map.data.forEach((function(_this) {
        return function(feature) {
          _this.map.data.remove(feature);
        };
      })(this));
      return this.map.data.addGeoJson(this.convertLatLon($.extend(true, {}, haika._geojson)));
    },
    save: function() {
      log('map.save');
      return haika.saveDelay();
    },
    init: function() {
      var centerLatLng, centerMarker, featureStyle, rotateMarker;
      log('map.init');
      centerLatLng = {
        lat: haika.xyLatitude ? haika.xyLatitude : 0,
        lng: haika.xyLongitude ? haika.xyLongitude : 0
      };
      this.map = new google.maps.Map(document.getElementById('haika-map'), {
        zoom: 19,
        maxZoom: 28,
        scaleControl: true,
        panControl: false,
        streetViewControl: false,
        center: centerLatLng
      });
      featureStyle = {
        fillColor: 'orange',
        strokeWeight: 1
      };
      this.map.data.setStyle(featureStyle);
      this.draw();
      centerMarker = new google.maps.Marker({
        position: centerLatLng,
        map: this.map,
        opacity: 0.8,
        title: '中心点(ドラッグで移動)',
        draggable: true,
        icon: {
          path: google.maps.SymbolPath.CIRCLE,
          scale: 10,
          strokeWeight: 5,
          strokeColor: '#ff3333'
        }
      });
      rotateMarker = new google.maps.Marker({
        position: centerLatLng,
        map: this.map,
        opacity: 0.8,
        title: '回転角度',
        draggable: true,
        icon: {
          path: google.maps.SymbolPath.CIRCLE,
          scale: 6,
          strokeWeight: 3,
          strokeColor: '#3333ff'
        }
      });
      google.maps.event.addListener(centerMarker, "dragend", (function(_this) {
        return function() {
          var position;
          log('centerMarker');
          position = centerMarker.getPosition();
          haika.xyLongitude = position.lng();
          haika.xyLatitude = position.lat();
          _this.draw();
          return _this.save();
        };
      })(this));
      $('#haika-map-search').submit((function(_this) {
        return function() {
          var address, geocoder;
          address = $('#haika-map-query').val();
          geocoder = new google.maps.Geocoder();
          geocoder.geocode({
            address: address
          }, function(results, status) {
            if (status === google.maps.GeocoderStatus.OK) {
              _this.map.setCenter(results[0].geometry.location);
              haika.xyLongitude = results[0].geometry.location.lng();
              haika.xyLatitude = results[0].geometry.location.lat();
              _this.draw();
              return _this.save();
            } else {
              return alert("ジオコーディングがうまくいきませんでした。: " + status);
            }
          });
          return false;
        };
      })(this));
      $('#haika-canvas-angle').slider({
        tooltip: 'always',
        step: 0.1,
        precision: 1,
        min: -180,
        max: 180,
        natural_arrow_keys: true,
        value: haika.xyAngle,
        formatter: (function(_this) {
          return function(value) {
            $('#haika-canvas-angle').find('.slider-handle').focus();
            if (haika.xyAngle !== value) {
              haika.xyAngle = value;
              _this.draw();
              _this.save();
            }
            return value + '度';
          };
        })(this)
      });
      return $('#haika-geojson-scale').slider({
        tooltip: 'always',
        step: 1,
        min: 80,
        max: 120,
        value: haika.xyScaleFactor * 100,
        formatter: (function(_this) {
          return function(value) {
            $('#haika-geojson-scale').find('.slider-handle').focus();
            if (haika.xyScaleFactor !== value / 100) {
              haika.xyScaleFactor = value / 100;
              _this.draw();
              _this.save();
            }
            return value + '%';
          };
        })(this)
      });
    }
  }
});
