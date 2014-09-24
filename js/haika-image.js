var addPixel, loadComplete, loadImg;

loadImg = function(file) {
  var reader;
  if (!file.type.match(/image\/.+/)) {
    return;
  }
  if (file.type === "image/svg+xml") {
    return;
  }
  reader = new FileReader();
  reader.onload = function() {
    return loadComplete(this.result);
  };
  return reader.readAsDataURL(file);
};

$('#file').change(function(e) {
  var files;
  files = e.target.files;
  if (files.length === 0) {
    return;
  }
  return loadImg(files[0]);
});

loadComplete = function(data) {
  var canvas, ctx, h, img, params, w, worker;
  img = new Image();
  img.src = data;
  canvas = document.createElement('canvas');
  ctx = canvas.getContext('2d');
  canvas.width = img.width;
  canvas.height = img.height;
  ctx.translate(0, img.height);
  ctx.scale(1, -1);
  ctx.translate(img.width, 0);
  ctx.scale(-1, 1);
  ctx.drawImage(img, 0, 0);
  w = canvas.width;
  h = canvas.height;
  data = ctx.getImageData(0, 0, w, h).data;
  params = {
    image: data,
    w: w,
    h: h
  };
  worker = new Worker("js/haika-image-worker.js");
  worker.onmessage = function(e) {
    var result, results, _i, _len;
    log(e.data);
    switch (e.data.status) {
      case "working":
        return log(e.data.count);
      case "end":
        results = e.data.result;
        for (_i = 0, _len = results.length; _i < _len; _i++) {
          result = results[_i];
          addPixel(result.x, result.y, result.color);
        }
        return haika.render();
    }
  };
  return worker.postMessage(params);
};

addPixel = function(x, y, color) {
  var dot, klass, object;
  dot = 10;
  klass = haika.getClass('shelf');
  object = new klass({
    top: haika.transformTopY_cm2px(y * dot),
    left: haika.transformLeftX_cm2px(x * dot),
    fill: color,
    stroke: color,
    angle: 0,
    count: 1,
    side: 1,
    eachWidth: dot,
    eachHeight: dot
  });
  return haika.add(object);
};

//# sourceMappingURL=haika-image.js.map
