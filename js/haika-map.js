var features, map, map_created, map_redraw, map_set, map_setting;

map_created = false;

$('.map_setting').click(function() {
  if ($('.haika_container').css('display') === 'block') {
    if (!map_created) {
      map_setting();
      map_created = true;
    }
    $('.haika_container').hide();
    $(document.body).css('background', '#333333');
    map_redraw();
    $('.map_container').show();
    return $('#map_query').focus();
  } else {
    $(document.body).css('background', '#FFFFFF');
    $('.haika_container').show();
    return $('.map_container').hide();
  }
});

map = null;

features = [];

map_redraw = function() {
  var feature, _i, _len;
  if (features.length > 0) {
    for (_i = 0, _len = features.length; _i < _len; _i++) {
      feature = features[_i];
      map.data.remove(feature);
    }
    return features = map.data.addGeoJson(haika.createGeoJson());
  }
};

map_set = function(lat, lon) {
  $('#canvas_lon').val(lon);
  $('#canvas_lat').val(lat);
  haika.options.lon = lon;
  haika.options.lat = lat;
  return haika.save();
};

log(haika.options.angle);

map_setting = function() {
  var featureStyle;
  log(haika.options.angle);
  map = new google.maps.Map(document.getElementById('map'), {
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
  map.data.setStyle(featureStyle);
  features = map.data.addGeoJson(haika.createGeoJson());
  google.maps.event.addListener(map, 'dragend', function() {
    var lat, lon;
    log(map.getCenter());
    lon = map.getCenter().lng();
    lat = map.getCenter().lat();
    map_set(lat, lon);
    return map_redraw();
  });
  $('#map_search').submit(function() {
    var address, geocoder;
    address = $('#map_query').val();
    geocoder = new google.maps.Geocoder();
    geocoder.geocode({
      address: address
    }, function(results, status) {
      if (status === google.maps.GeocoderStatus.OK) {
        map.setCenter(results[0].geometry.location);
        map_set(results[0].geometry.location.lat(), results[0].geometry.location.lng());
        return map_redraw();
      } else {
        return alert("ジオコーディングがうまくいきませんでした。: " + status);
      }
    });
    return false;
  });
  $('#canvas_lat').change(function() {
    haika.options.lat = parseFloat($(this).val());
    return haika.save();
  });
  $('#canvas_lon').change(function() {
    haika.options.lon = parseFloat($(this).val());
    return haika.save();
  });
  $('#canvas_angle').change(function() {
    return map_redraw();
  });
  $('#canvas_angle').slider({
    tooltip: 'always',
    step: 1,
    min: 0,
    max: 360,
    value: haika.options.angle,
    formatter: function(value) {
      haika.options.angle = parseFloat(value);
      haika.save();
      map_redraw();
      return value + '度';
    }
  });
  return $('#geojson_scale').slider({
    tooltip: 'always',
    step: 1,
    min: 0,
    max: 400,
    value: haika.options.geojson_scale * 100,
    formatter: function(value) {
      haika.options.geojson_scale = parseFloat(value) / 100;
      haika.save();
      map_redraw();
      return value + '%';
    }
  });
};

//# sourceMappingURL=haika-map.js.map
