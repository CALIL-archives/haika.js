// Generated by CoffeeScript 1.8.0
(function(global) {
  "use strict";
  var haika_utils;
  haika_utils = global.haika_utils || (global.haika_utils = {});
  haika_utils.drawGridLines = function(ctx) {
    var gapX, gapY, height, i, size, sx, sy, width;
    ctx.save();
    ctx.opacity = 1;
    width = ctx.canvas.width;
    height = ctx.canvas.height;
    ctx.strokeStyle = '#cccccc';
    size = 100 * haika.scaleFactor;
    gapX = (haika.transformLeftX_cm2px(0) * 1000 % Math.floor(size * 1000)) / 1000;
    gapY = (haika.transformTopY_cm2px(0) * 1000 % Math.floor(size * 1000)) / 1000;
    ctx.beginPath();
    ctx.lineWidth = Math.max(Math.min(haika.scaleFactor, 1), 0.3);
    i = 0;
    while (i < Math.ceil(width / size) + 1) {
      ctx.moveTo(Math.floor(size * i) + gapX + 0.5, 0);
      ctx.lineTo(Math.floor(size * i) + gapX + 0.5, height);
      ++i;
    }
    i = 0;
    while (i < Math.ceil(height / size) + 1) {
      ctx.moveTo(0, Math.floor(size * i) + gapY + 0.5);
      ctx.lineTo(width, Math.floor(size * i) + gapY + 0.5);
      ++i;
    }
    ctx.stroke();
    size = 500 * haika.scaleFactor;
    gapX = (haika.transformLeftX_cm2px(0) * 1000 % Math.floor(size * 1000)) / 1000;
    gapY = (haika.transformTopY_cm2px(0) * 1000 % Math.floor(size * 1000)) / 1000;
    ctx.beginPath();
    ctx.lineWidth = Math.max(Math.min(haika.scaleFactor * 2, 2), 0.5);
    i = 0;
    while (i < Math.ceil(width / size) + 1) {
      ctx.moveTo(Math.floor(size * i) + gapX + 0.5, 0);
      ctx.lineTo(Math.floor(size * i) + gapX + 0.5, height);
      ++i;
    }
    i = 0;
    while (i < Math.ceil(height / size) + 1) {
      ctx.moveTo(0, Math.floor(size * i) + gapY + 0.5);
      ctx.lineTo(width, Math.floor(size * i) + gapY + 0.5);
      ++i;
    }
    ctx.stroke();
    ctx.lineWidth = Math.max(Math.min(haika.scaleFactor * 2, 2), 0.5);
    ctx.strokeStyle = '#aaaaaa';
    ctx.beginPath();
    sx = haika.transformLeftX_cm2px(0);
    sy = haika.transformTopY_cm2px(0);
    ctx.moveTo(Math.floor(sx), 0);
    ctx.lineTo(Math.floor(sx), height);
    ctx.moveTo(0, Math.floor(sy));
    ctx.lineTo(width, Math.floor(sy));
    ctx.stroke();
    ctx.restore();
  };
  haika_utils.drawScale = function(ctx) {
    var height, posy, scale;
    ctx.save();
    ctx.opacity = 1;
    height = ctx.canvas.height;
    posy = 20;
    ctx.font = "10px Open Sans";
    if (100 * haika.scaleFactor <= 50) {
      scale = 500;
      ctx.fillText("5m", 25, height - 66 + posy);
    } else {
      scale = 100;
      ctx.fillText("1m", 25, height - 66 + posy);
    }
    ctx.lineWidth = 2;
    ctx.strokeStyle = '#666666';
    ctx.beginPath();
    ctx.moveTo(20, height - 65 + posy);
    ctx.lineTo(20, height - 60 + posy);
    ctx.lineTo(20 + scale * haika.scaleFactor, height - 60 + posy);
    ctx.lineTo(20 + scale * haika.scaleFactor, height - 65 + posy);
    ctx.stroke();
    ctx.restore();
  };
})((typeof exports !== "undefined" ? exports : this));

//# sourceMappingURL=grid.js.map
