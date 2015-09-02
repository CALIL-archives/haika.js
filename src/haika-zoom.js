$.extend(haika, {
  zoomFull: function() {
    var bottom, canvasHeight, canvasWidth, geojson, height, heightScale, i, j, left, len, len1, object, point, ref, ref1, right, scale, top, width, widthScale;
    if (this.objects.length <= 0) {
      return;
    }
    geojson = this.toGeoJSON();
    ref = geojson.features;
    for (i = 0, len = ref.length; i < len; i++) {
      object = ref[i];
      if (this.layer !== this.CONST_LAYERS.FLOOR && object.properties.type === 'floor' && object.properties.is_negative) {
        continue;
      }
      ref1 = object.geometry.coordinates[0];
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        point = ref1[j];
        if (typeof left === "undefined" || left === null) {
          left = point[0];
          right = point[0];
          top = point[1];
          bottom = point[1];
          continue;
        }
        left = Math.min(point[0], left);
        right = Math.max(point[0], right);
        top = Math.min(point[1], top);
        bottom = Math.max(point[1], bottom);
      }
    }
    this.centerX = -(right + left) / 2;
    this.centerY = (bottom + top) / 2;
    width = right - left;
    height = bottom - top;
    canvasWidth = this.canvas.getWidth();
    canvasHeight = this.canvas.getHeight();
    widthScale = canvasWidth / width;
    heightScale = canvasHeight / height;
    scale = widthScale < heightScale ? widthScale : heightScale;
    return this.setScale(scale * 0.8);
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

haika.htmlStack.push("<div class=\"haika-buttons\">\n  <span class=\"haika-button haika-full\">\n    <i class=\"fa fa-arrows\"></i>\n  </span>\n  <span class=\"haika-button haika-zoomin\">\n    <i class=\"fa fa-plus\"></i>\n  </span>\n  <span class=\"haika-button haika-zoomout\">\n    <i class=\"fa fa-minus\"></i>\n  </span>\n</div>");

haika.eventStack.push(function() {
  $('.haika-full').click(function() {
    return haika.zoomFull();
  });
  $('.haika-zoomin').click(function() {
    return haika.zoomIn();
  });
  $('.haika-zoomout').click(function() {
    return haika.zoomOut();
  });
  return $('.zoomreset').click(function() {
    return haika.setScale(1);
  });
});
