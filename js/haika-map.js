// Generated by CoffeeScript 1.8.0
$.extend(haika, {
  map: {
    map: null,
    created: false,
    features: [],
    initMap: function() {
      return $('.haika-map-setting').click((function(_this) {
        return function() {
          if ($('.haika-container').css('display') === 'block') {
            if (!_this.created) {
              _this.setMap();
              _this.created = true;
            }
            $('.haika-container').hide();
            $(document.body).css('background', '#333333');
            _this.redrawMap();
            $('.haika-map-container').show();
            return $('#haika-map-query').focus();
          } else {
            $(document.body).css('background', '#FFFFFF');
            $('.haika-container').show();
            return $('.haika-map-container').hide();
          }
        };
      })(this));
    },
    redrawMap: function() {
      var feature, _i, _len, _ref;
      if (this.features.length > 0) {
        _ref = this.features;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          feature = _ref[_i];
          this.map.data.remove(feature);
        }
        return this.features = this.map.data.addGeoJson(haika.createGeoJson());
      }
    },
    saveMap: function(lat, lon) {
      $('#haika-canvas-lon').val(lon);
      $('#haika-canvas-lat').val(lat);
      haika.xyLongitude = lon;
      haika.xyLatitude = lat;
      return haika.save();
    },
    setMap: function() {
      var centerMarker, featureStyle, markerImage;
      this.map = new google.maps.Map(document.getElementById('haika-map'), {
        zoom: 20,
        maxZoom: 28,
        center: {
          lat: haika.xyLatitude ? haika.xyLatitude : 0,
          lng: haika.xyLongitude ? haika.xyLongitude : 0
        }
      });
      featureStyle = {
        fillColor: 'orange',
        strokeWeight: 1
      };
      this.map.data.setStyle(featureStyle);
      this.features = this.map.data.addGeoJson(haika.createGeoJson());
      markerImage = new google.maps.MarkerImage('img/mapCenterMarker.png', new google.maps.Size(50, 50), new google.maps.Point(0, 0), new google.maps.Point(25, 25));
      centerMarker = new google.maps.Marker({
        position: this.map.getCenter(),
        map: this.map,
        icon: markerImage,
        draggable: false
      });
      google.maps.event.addListener(this.map, "center_changed", (function(_this) {
        return function() {
          var lat, lon, position;
          position = _this.map.getCenter();
          centerMarker.setPosition(position);
          lon = _this.map.getCenter().lng();
          lat = _this.map.getCenter().lat();
          _this.saveMap(lat, lon);
          return _this.redrawMap();
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
              _this.saveMap(results[0].geometry.location.lat(), results[0].geometry.location.lng());
              return _this.redrawMap();
            } else {
              return alert("ジオコーディングがうまくいきませんでした。: " + status);
            }
          });
          return false;
        };
      })(this));
      $('#haika-canvas-lat').change(function() {
        haika.xyLatitude = parseFloat($(this).val());
        return haika.save();
      });
      $('#haika-canvas-lon').change(function() {
        haika.xyLongitude = parseFloat($(this).val());
        return haika.save();
      });
      $('#haika-canvas-angle').change((function(_this) {
        return function() {
          return _this.redrawMap();
        };
      })(this));
      $('#haika-canvas-angle').slider({
        tooltip: 'always',
        step: 1,
        min: -180,
        max: 180,
        value: haika.xyAngle,
        formatter: (function(_this) {
          return function(value) {
            haika.xyAngle = parseFloat(value);
            haika.saveDelay();
            _this.redrawMap();
            return value + '度';
          };
        })(this)
      });
      return $('#haika-geojson-scale').slider({
        tooltip: 'always',
        step: 1,
        min: 0,
        max: 400,
        value: haika.xyScaleFactor * 100,
        formatter: (function(_this) {
          return function(value) {
            haika.xyScaleFactor = parseFloat(value) / 100;
            haika.saveDelay();
            _this.redrawMap();
            return value + '%';
          };
        })(this)
      });
    }
  }
});

//# sourceMappingURL=haika-map.js.map
