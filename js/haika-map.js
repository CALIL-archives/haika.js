var map_created, map_setting;

$(function() {
  return setTimeout(function() {
    return $($('.map_setting')[0]).trigger('click');
  }, 1000);
});

map_created = false;

$('.map_setting').click(function() {
  if ($('.haika_container').css('display') === 'block') {
    if (!map_created) {
      map_setting();
      map_created = true;
    }
    $('.haika_container').hide();
    $('.map_container').show();
    return $('#map_query').focus();
  } else {
    $('.haika_container').show();
    return $('.map_container').hide();
  }
});

map_setting = function() {
  var featureStyle, features, map;
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
    var feature, lat, lon, _i, _len;
    log(map.getCenter());
    lon = map.getCenter().lng();
    lat = map.getCenter().lat();
    $('#canvas_lon').val(lon);
    $('#canvas_lat').val(lat);
    haika.options.lon = lon;
    haika.options.lat = lat;
    haika.save();
    for (_i = 0, _len = features.length; _i < _len; _i++) {
      feature = features[_i];
      map.data.remove(feature);
    }
    return features = map.data.addGeoJson(haika.createGeoJson());
  });
  $('#map_search').submit(function() {
    var address, geocoder;
    address = $('#map_query').val();
    geocoder = new google.maps.Geocoder();
    geocoder.geocode({
      address: address
    }, function(results, status) {
      if (status === google.maps.GeocoderStatus.OK) {
        return map.setCenter(results[0].geometry.location);
      } else {
        return alert("ジオコーディングがうまくいきませんでした。: " + status);
      }
    });
    return false;
  });
  return $('.canvas_angle').change(function() {
    var feature, _i, _len;
    $('#canvas_angle').val($('.canvas_angle').val());
    haika.options.angle = $('.canvas_angle').val();
    haika.save();
    if (features.length > 0) {
      for (_i = 0, _len = features.length; _i < _len; _i++) {
        feature = features[_i];
        map.data.remove(feature);
      }
    }
    return features = map.data.addGeoJson(haika.createGeoJson());
  });
};

//# sourceMappingURL=haika-map.js.map
