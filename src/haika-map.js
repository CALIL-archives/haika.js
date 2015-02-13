$.extend(haika, {
  map: {
    map: null,
    geojson: null,
    draw: function() {
      log('map.draw');
      this.map.data.forEach((function(_this) {
        return function(feature) {
          return _this.map.data.remove(feature);
        };
      })(this));
      return this.map.data.addGeoJson(haika.createGeoJSON($.extend(true, {}, this.geojson)));
    },
    save: function() {
      log('map.save');
      haika._geojson = this.geojson;
      return haika.saveDelay();
    },
    init: function() {
      var centerLatLng, centerMarker, featureStyle, markerImage;
      log('map.init');
      this.geojson = haika._geojson;
      centerLatLng = {
        lat: this.geojson.haika.xyLatitude ? this.geojson.haika.xyLatitude : 0,
        lng: this.geojson.haika.xyLongitude ? this.geojson.haika.xyLongitude : 0
      };
      this.map = new google.maps.Map(document.getElementById('haika-map'), {
        zoom: 20,
        maxZoom: 28,
        scaleControl: true,
        center: centerLatLng
      });
      featureStyle = {
        fillColor: 'orange',
        strokeWeight: 1
      };
      this.map.data.setStyle(featureStyle);
      this.draw();
      markerImage = new google.maps.MarkerImage('img/mapCenterMarker.png', new google.maps.Size(50, 50), new google.maps.Point(0, 0), new google.maps.Point(25, 25));
      centerMarker = new google.maps.Marker({
        position: centerLatLng,
        map: this.map,
        icon: markerImage,
        draggable: true
      });
      google.maps.event.addListener(centerMarker, "dragend", (function(_this) {
        return function() {
          var position;
          log('centerMarker');
          position = centerMarker.getPosition();
          _this.geojson.haika.xyLongitude = position.lng();
          _this.geojson.haika.xyLatitude = position.lat();
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
              _this.geojson.haika.xyLongitude = results[0].geometry.location.lng();
              _this.geojson.haika.xyLatitude = results[0].geometry.location.lat();
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
        value: this.geojson.haika.xyAngle,
        formatter: (function(_this) {
          return function(value) {
            $('#haika-canvas-angle').find('.slider-handle').focus();
            if (_this.geojson.haika.xyAngle !== value) {
              _this.geojson.haika.xyAngle = value;
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
        value: this.geojson.haika.xyScaleFactor * 100,
        formatter: (function(_this) {
          return function(value) {
            $('#haika-geojson-scale').find('.slider-handle').focus();
            if (_this.geojson.haika.xyScaleFactor !== value / 100) {
              _this.geojson.haika.xyScaleFactor = value / 100;
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

//# sourceMappingURL=haika-map.js.map
