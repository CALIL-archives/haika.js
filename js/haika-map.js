$.extend(haika, {
  map: {
    map: null,
    created: false,
    features: [],
    initMap: function() {
      return $('.map_setting').click((function(_this) {
        return function() {
          if ($('.haika_container').css('display') === 'block') {
            if (!_this.created) {
              _this.setMap();
              _this.created = true;
            }
            $('.haika_container').hide();
            $(document.body).css('background', '#333333');
            _this.redrawMap();
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
      $('#canvas_lon').val(lon);
      $('#canvas_lat').val(lat);
      haika.xyLongitude = lon;
      haika.xyLatitude = lat;
      return haika.save();
    },
    setMap: function() {
      var featureStyle;
      this.map = new google.maps.Map(document.getElementById('map'), {
        zoom: 20,
        maxZoom: 28,
        center: {
          lat: haika.xyLatitude,
          lng: haika.xyLongitude
        }
      });
      featureStyle = {
        fillColor: 'orange',
        strokeWeight: 1
      };
      this.map.data.setStyle(featureStyle);
      this.features = this.map.data.addGeoJson(haika.createGeoJson());
      google.maps.event.addListener(this.map, 'dragend', (function(_this) {
        return function() {
          var lat, lon;
          log(_this.map.getCenter());
          lon = _this.map.getCenter().lng();
          lat = _this.map.getCenter().lat();
          _this.saveMap(lat, lon);
          return _this.redrawMap();
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
              _this.saveMap(results[0].geometry.location.lat(), results[0].geometry.location.lng());
              return _this.redrawMap();
            } else {
              return alert("ジオコーディングがうまくいきませんでした。: " + status);
            }
          });
          return false;
        };
      })(this));
      $('#canvas_lat').change(function() {
        haika.xyLatitude = parseFloat($(this).val());
        return haika.save();
      });
      $('#canvas_lon').change(function() {
        haika.xyLongitude = parseFloat($(this).val());
        return haika.save();
      });
      $('#canvas_angle').change((function(_this) {
        return function() {
          return _this.redrawMap();
        };
      })(this));
      $('#canvas_angle').slider({
        tooltip: 'always',
        step: 1,
        min: 0,
        max: 360,
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
      return $('#geojson_scale').slider({
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
