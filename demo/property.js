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
        return new Property();
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

}
