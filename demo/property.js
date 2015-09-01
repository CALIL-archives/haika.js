var haikaId;

$(haika).on('haika:render', function() {
  $('#haika-canvas-width').html(haika.canvas.getWidth());
  $('#haika-canvas-height').html(haika.canvas.getHeight());
  $('#haika-canvas-centerX').html(haika.centerX.toFixed(0));
  $('#haika-canvas-centerY').html(haika.centerY.toFixed(0));
  $('#haika-canvas-bgscale').val(haika.backgroundScaleFactor);
  return $('#haika-canvas-bgopacity').val(haika.backgroundOpacity);
});

haikaId = 15;

haika.html('.haika-container');

$(haika).on('haika:initialized', function() {
  haika.render();
  return haika.property.init();
});

haika.init({
  divId: 'haika-canvas'
});

if (haika.readOnly) {
  haika.event.zoom();
} else {

}
