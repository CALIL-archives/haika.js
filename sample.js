// Generated by CoffeeScript 1.8.0
var haikaId;

$.extend(haika, {
  "import": function(id, option) {
    var collision, dataId, revision;
    if (id.length !== 6) {
      alert('指定されたIDの形式が違います。6桁で指定して下さい。');
      return;
    }
    dataId = this._dataId;
    collision = this._collision;
    revision = this._revision;
    if (this._dataId) {
      this.close();
    }
    return $.ajax({
      url: 'https://app.haika.io/js/haika_json/' + id + '.json',
      type: 'POST',
      cache: false,
      dataType: 'json',
      error: (function(_this) {
        return function() {
          return option.error && option.error('データが読み込めませんでした');
        };
      })(this),
      success: (function(_this) {
        return function(data) {
          var geojson;
          log(data);
          geojson = _this.changeFeatures(data.geojson, function(x, y) {
            return [x * 100, y * 100];
          });
          geojson.haika = {
            backgroundScaleFactor: data.canvas.bgscale,
            backgroundOpacity: parseFloat(data.canvas.bgopacity),
            backgroundUrl: 'http://lab.calil.jp' + data.canvas.bgurl,
            backgroundScaleFactor: data.canvas.bgscale,
            xyAngle: data.canvas.angle,
            xyScaleFactor: data.canvas.scale,
            xyLongitude: data.canvas.lon,
            xyLatitude: data.canvas.lat
          };
          log(geojson);
          _this._dataId = dataId;
          _this._revision = revision;
          _this._collision = collision;
          _this._geojson = geojson;
          _this.loadFromGeoJson();
          $(_this).trigger('haika:load');
          option.success && option.success();
          $('#haika-canvas-bgscale').val(data.canvas.bgscale);
          return $('#haika-canvas-bgopacity').val(data.canvas.bgopacity);
        };
      })(this)
    });
  }
});

$('#haika-import').click(function() {
  var id;
  id = prompt('インポートするデータのIDを6桁で指定して下さい。');
  if (id) {
    return haika["import"](id, {
      success: function() {
        haika.render();
        return haika.save();
      },
      error: function(message) {
        return alert(message);
      }
    });
  }
});

$(haika).on('haika:render', function() {
  $('#canvas_width').html(haika.canvas.getWidth());
  $('#canvas_height').html(haika.canvas.getHeight());
  $('#canvas_centerX').html(haika.centerX);
  $('#canvas_centerY').html(haika.centerY);
  $('#canvas_bgscale').val(haika.backgroundScaleFactor);
  $('#canvas_bgopacity').val(haika.backgroundOpacity);
  $('#canvas_lon').val(haika.xyLongitude);
  $('#canvas_lat').val(haika.xyLatitude);
  $('#canvas_angle').val(haika.canvas.angle);
  return $('.zoom').html((haika.scaleFactor * 100).toFixed(0) + '%');
});

$('.fullscreen').click(function() {
  if ($('.haika-container')[0].requestFullScreen) {
    $('.haika-container')[0].requestFullScreen();
  }
  if ($('.haika-container')[0].webkitRequestFullScreen) {
    $('.haika-container')[0].webkitRequestFullScreen();
  }
  if ($('.haika-container')[0].mozRequestFullScreen) {
    return $('.haika-container')[0].mozRequestFullScreen();
  }
});

haikaId = location.hash.split('#')[1];

if (!haikaId) {
  alert('HaikaIDを指定して下さい');
} else {
  $(haika).on('haika:initialized', function() {
    return haika.openFromApi(haikaId, {
      success: function() {
        haika.render();
        return haika.property.init();
      },
      error: function(message) {
        return alert(message);
      }
    });
  });
  haika.init({
    divId: 'haika-canvas'
  });
  if (haika.readOnly) {
    haika.event.zoom();
  } else {
    haika.toolbar.init();
    haika.event.init();
    haika.undo.init();
    initScrollBar();
    haika.colorpicker.init();
  }
}

//# sourceMappingURL=sample.js.map
