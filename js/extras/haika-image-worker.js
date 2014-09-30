var onmessage;

onmessage = function(e) {
  var convert, hex_color, result;
  convert = function(data) {
    var a, b, color, colors, g, h, n, r, result, w, x, y;
    colors = [];
    w = data.w;
    h = data.h;
    y = 0;
    while (y < h) {
      x = 0;
      while (x < w) {
        n = x * 4 + y * w * 4;
        r = data.image[n];
        g = data.image[n + 1];
        b = data.image[n + 2];
        a = data.image[n + 3];
        if (a !== 0) {
          color = hex_color(r, g, b);
          colors.push({
            color: color,
            x: x,
            y: y
          });
        }
        x++;
      }
      y++;
      result = {
        status: "working",
        count: y
      };
      postMessage(result);
    }
    return colors;
  };
  hex_color = function(r, g, b) {
    return '#' + [r, g, b].map(function(a) {
      return ("0" + parseInt(a).toString(16)).slice(-2);
    }).join('');
  };
  result = {
    status: "end",
    result: convert(e.data)
  };
  return postMessage(result);
};

//# sourceMappingURL=haika-image-worker.js.map
