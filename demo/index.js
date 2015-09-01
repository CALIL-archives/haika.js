$(haika).on('haika:render', function() {
  $('#haika-canvas-width').html(haika.canvas.getWidth());
  $('#haika-canvas-height').html(haika.canvas.getHeight());
  $('#haika-canvas-centerX').html(haika.centerX.toFixed(0));
  $('#haika-canvas-centerY').html(haika.centerY.toFixed(0));
  $('#haika-canvas-bgscale').val(haika.backgroundScaleFactor);
  return $('#haika-canvas-bgopacity').val(haika.backgroundOpacity);
});

haika.html('.haika-container');

$(haika).on('haika:initialized', function() {
  return $.ajax({
    url: 'sabae.json',
    type: 'GET',
    cache: false,
    dataType: 'json',
    error: (function(_this) {
      return function() {
        return option.error && option.error('データが読み込めませんでした');
      };
    })(this),
    success: (function(_this) {
      return function(json) {
        if (json.locked) {
          _this.readOnly = true;
          return option.error && option.error('データはロックされています');
        }
        haika._dataId = json.id;
        haika._revision = json.revision;
        haika._collision = json.collision;
        haika._geojson = json.data;
        haika.loadFromGeoJson();
        $(haika).trigger('haika:load');
        haika.render();
        new Property();
        return haika.zoomFull();
      };
    })(this)
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
}

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
