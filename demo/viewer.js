var haikaStart, hash, layer;

haika.addObject('shelf', 0, fabric.Shelf);

haika.addObject('curved_shelf', 0, fabric.curvedShelf);

haika.addObject('beacon', 1, fabric.Beacon);

haika.addObject('wall', 2, fabric.Wall);

haika.addObject('floor', 3, fabric.Floor);

hash = location.hash.split('#')[1];

if (hash) {
  layer = hash * 1;
} else {
  0;
}

haika.init({
  layer: layer
});

haika.save = function() {
  localStorage.setItem('haika', JSON.stringify(haika._geojson));
  return log('save local storage');
};

haikaStart = function() {
  haika.loadFromGeoJson();
  $(haika).trigger('haika:load');
  return haika.render();
};

if (localStorage.getItem('haika')) {
  log('load local storage');
  haika._geojson = JSON.parse(localStorage.getItem('haika'));
  haikaStart();
} else {
  $.ajax({
    url: 'data/calil.json',
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
        log('load ajax');
        haika._dataId = json.id;
        haika._revision = json.revision;
        haika._collision = json.collision;
        haika._geojson = json.data;
        return haikaStart();
      };
    })(this)
  });
}
