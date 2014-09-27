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
        return this.features = this.map.data.addGeoJson(haika.createGeoJson());
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
      this.features = this.map.data.addGeoJson(haika.createGeoJson());
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
    }
  }
});

haika.map.init();

//# sourceMappingURL=haika-map.js.map
