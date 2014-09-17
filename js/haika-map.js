var map_setting;

map_setting = function() {
  var center, featureStyle, gmap, olMapDiv, view;
  gmap = new google.maps.Map(document.getElementById("gmap"), {
    disableDefaultUI: true,
    keyboardShortcuts: false,
    draggable: false,
    disableDoubleClickZoom: true,
    scrollwheel: false,
    streetViewControl: false
  });
  featureStyle = {
    fillColor: 'orange',
    strokeWeight: 1
  };
  gmap.data.setStyle(featureStyle);
  gmap.data.addGeoJson(haika.createGeoJson());
  center = ol.proj.transform([haika.options.lon, haika.options.lat], "EPSG:4326", "EPSG:3857");
  view = new ol.View2D({
    center: center,
    zoom: 2,
    maxZoom: 21
  });
  view.on("change:center", function() {
    center = ol.proj.transform(view.getCenter(), "EPSG:3857", "EPSG:4326");
    return gmap.setCenter(new google.maps.LatLng(center[1], center[0]));
  });
  view.on("change:resolution", function() {
    return gmap.setZoom(view.getZoom());
  });
  olMapDiv = document.getElementById("olmap");
  window.map = new ol.Map({
    target: "map",
    ol3Logo: false,
    layers: [],
    interactions: ol.interaction.defaults({
      altShiftDragRotate: false,
      dragPan: false,
      rotate: false
    }).extend([
      new ol.interaction.DragPan({
        kinetic: null
      })
    ]),
    target: olMapDiv,
    view: view
  });
  view.setCenter(center);
  view.setZoom(20);
  olMapDiv.parentNode.removeChild(olMapDiv);
  gmap.controls[google.maps.ControlPosition.TOP_LEFT].push(olMapDiv);
  return map.on('moveend', function(e) {
    var new_center;
    center = map.getView().getCenter();
    new_center = ol.proj.transform(center, "EPSG:3857", "EPSG:4326");
    $('#canvas_lon').val(new_center[0]);
    haika.options.lon = new_center[0];
    $('#canvas_lat').val(new_center[1]);
    haika.options.lat = new_center[1];
    return haika.save();
  });
};

$('#map_search').submit(function() {
  var url;
  url = 'http://nominatim.openstreetmap.org/search';
  $.ajax({
    url: url,
    type: "GET",
    data: {
      q: $('#map_query').val(),
      format: "json"
    },
    dataType: "jsonp",
    jsonp: "json_callback",
    error: function() {},
    success: (function(_this) {
      return function(data) {
        var center, view;
        log(data);
        if (data.length > 0) {
          haika.options.lon = parseFloat(data[0].lon);
          haika.options.lat = parseFloat(data[0].lat);
          haika.save();
          $('#canvas_lon').val(haika.options.lon);
          $('#canvas_lat').val(haika.options.lat);
          center = ol.proj.transform([haika.options.lon, haika.options.lat], "EPSG:4326", "EPSG:3857");
          view = map.getView();
          view.setCenter(center);
          return view.setZoom(20);
        } else {
          return alert('見つかりませんでした。');
        }
      };
    })(this)
  });
  return false;
});

//# sourceMappingURL=haika-map.js.map
