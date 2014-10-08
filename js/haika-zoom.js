$.extend(haika, {
  zoomFull: function() {
    var bottom, canvasHeight, canvasWidth, geojson, height, heightScale, left, object, point, right, scale, top, width, widthScale, _i, _j, _len, _len1, _ref, _ref1;
    if (this.objects.length <= 0) {
      return;
    }
    geojson = this.toGeoJSON();
    _ref = geojson.features;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      _ref1 = object.geometry.coordinates[0];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        point = _ref1[_j];
        if (typeof left === "undefined" || left === null) {
          left = point[0];
          right = point[0];
          top = point[1];
          bottom = point[1];
          continue;
        }
        left = Math.min(point[0] * 100, left);
        right = Math.max(point[0] * 100, right);
        top = Math.min(point[1] * 100, top);
        bottom = Math.max(point[1] * 100, bottom);
      }
    }
    log(left);
    log(right);
    this.centerX = -(right + left) / 2;
    this.centerY = (bottom + top) / 2;
    width = right - left;
    height = bottom - top;
    log(width);
    log(height);
    canvasWidth = this.canvas.getWidth();
    canvasHeight = this.canvas.getHeight();
    log(canvasWidth);
    log(canvasHeight);
    widthScale = canvasWidth / width;
    heightScale = canvasHeight / height;
    log(widthScale);
    log(heightScale);
    scale = widthScale < heightScale ? widthScale : heightScale;
    log(scale);
    return this.setScale(scale * 0.5);
  },
  zoomIn: function() {
    var newScale, prevScale;
    prevScale = this.scaleFactor;
    newScale = prevScale + Math.pow(prevScale + 1, 2) / 20;
    if (newScale < 1 && prevScale > 1) {
      newScale = 1;
    }
    return this.setScale(newScale);
  },
  zoomOut: function() {
    var newScale, prevScale;
    prevScale = this.scaleFactor;
    newScale = prevScale - Math.pow(prevScale + 1, 2) / 20;
    if (prevScale > 1 && newScale < 1) {
      newScale = 1;
    }
    return this.setScale(newScale);
  }
});

//# sourceMappingURL=haika-zoom.js.map
