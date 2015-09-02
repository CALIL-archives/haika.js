var haikaId;

haikaId = 15;

haika.html('.haika-container');

$(haika).on('haika:initialized', function() {
  return haika.openFromApi(haikaId, {
    success: function() {
      haika.render();
      haika.property.init();
      haika.zoomFull();
      if (haika.readOnly) {
        return haika.event.zoom();
      } else {
        haika.toolbar.init();
        haika.event.init();
        haika.undo.init();
        return initScrollBar();
      }
    },
    error: function(message) {
      return alert(message);
    }
  });
});

haika.init({
  divId: 'haika-canvas'
});
