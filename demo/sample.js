var haikaId;

$(haika).on('haika:render', function() {
  $('#haika-canvas-width').html(haika.canvas.getWidth());
  $('#haika-canvas-height').html(haika.canvas.getHeight());
  $('#haika-canvas-centerX').html(haika.centerX.toFixed(0));
  $('#haika-canvas-centerY').html(haika.centerY.toFixed(0));
  $('#haika-canvas-bgscale').val(haika.backgroundScaleFactor);
  return $('#haika-canvas-bgopacity').val(haika.backgroundOpacity);
});

haikaId = 1000;

haika.html('.haika-container');

$(haika).on('haika:initialized', function() {
  return haika.openFromApi(haikaId, {
    success: function() {
      haika.render();
      haika.property.init();
      return haika.zoomFull();
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
