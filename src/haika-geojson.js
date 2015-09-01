$.extend(haika, {
  loadFromGeoJson: function() {
    var header, i, len, object, ref, results;
    if (this._geojson.haika != null) {
      header = this._geojson.haika;
    } else {
      header = {};
    }
    this.backgroundScaleFactor = header.backgroundScaleFactor != null ? header.backgroundScaleFactor : 1;
    this.backgroundOpacity = header.backgroundOpacity != null ? header.backgroundOpacity : 1;
    this.backgroundUrl = header.backgroundUrl != null ? header.backgroundUrl : '';
    this.xyAngle = header.xyAngle != null ? header.xyAngle : 0;
    this.xyScaleFactor = header.xyScaleFactor != null ? header.xyScaleFactor : 1;
    this.xyLongitude = header.xyLongitude != null ? header.xyLongitude : null;
    this.xyLatitude = header.xyLatitude != null ? header.xyLatitude : null;
    this.objects = [];
    if (this._geojson.features != null) {
      ref = this._geojson.features;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        object = ref[i];
        results.push(this.objects.push(object.properties));
      }
      return results;
    }
  },
  prepareData: function() {
    var _data, count, i, len, object, ref, results;
    log('prepareData');
    if (!this.canvas) {
      return;
    }
    ref = this.canvas.getObjects();
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      object = ref[i];
      if (object.group != null) {
        object.top_cm = this.px2cm_y(object.top + object.group.top);
        object.left_cm = this.px2cm_x(object.left + object.group.left);
      } else {
        object.top_cm = this.px2cm_y(object.top);
        object.left_cm = this.px2cm_x(object.left);
      }
      count = this.getCountFindById(object.id);
      _data = object.toGeoJSON();
      results.push(this.objects[count] = _data.properties);
    }
    return results;
  },
  toGeoJSON: function() {
    var data, features, geojson, i, len, object, ref;
    if (this.canvas) {
      features = [];
      ref = this.canvas.getObjects();
      for (i = 0, len = ref.length; i < len; i++) {
        object = ref[i];
        geojson = object.toGeoJSON();
        features.push(geojson);
      }
    } else {
      features = this._geojson.features;
    }
    data = {
      "type": "FeatureCollection",
      "features": features,
      "haika": {
        backgroundUrl: this.backgroundUrl,
        backgroundScaleFactor: this.backgroundScaleFactor,
        backgroundOpacity: this.backgroundOpacity,
        xyLongitude: this.xyLongitude,
        xyLatitude: this.xyLatitude,
        xyAngle: this.xyAngle,
        xyScaleFactor: this.xyScaleFactor,
        version: 1
      }
    };
    return data;
  }
});
