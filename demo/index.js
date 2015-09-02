$(haika).on('haika:initialized', function() {
  return $.ajax({
    url: 'data/sabae.json',
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
        var i, len, plugin, ref;
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
        log('plugin');
        log(haika.plugins);
        ref = haika.plugins;
        for (i = 0, len = ref.length; i < len; i++) {
          plugin = ref[i];
          log(plugin);
          new plugin();
        }
        if (haika.zoomFull != null) {
          haika.zoomFull();
        }
        if (haika.readOnly) {
          haika.event.zoom();
        } else {
          if (haika.toolbar != null) {
            haika.toolbar.init();
          }
          if (haika.event != null) {
            haika.event.init();
          }
          if (haika.undo != null) {
            haika.undo.init();
          }
        }
        if (typeof initScrollBar !== "undefined" && initScrollBar !== null) {
          return initScrollBar();
        }
      };
    })(this)
  });
});

haika.init({
  divId: 'haika-canvas'
});
