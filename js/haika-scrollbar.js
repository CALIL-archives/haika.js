var initScrollBar;

initScrollBar = function() {
  var bgimg_height, bgimg_width, defaultX, defaultY, maxX, maxY, scroll_weight;
  scroll_weight = 5000;
  bgimg_width = haika.backgroundImage ? haika.backgroundImage.width : 2500;
  bgimg_height = haika.backgroundImage ? haika.backgroundImage.height : 2500;
  maxX = bgimg_width * haika.backgroundScaleFactor / 2;
  maxY = bgimg_height * haika.backgroundScaleFactor / 2;
  defaultX = -((haika.centerX - scroll_weight) / 10000);
  defaultY = -((haika.centerY - scroll_weight) / 10000);
  new Dragdealer('horizontal-scroller', {
    x: defaultX,
    animationCallback: function(x, y) {
      var centerX;
      centerX = x * 10000 - scroll_weight;
      if (centerX > maxX - haika.canvas.getWidth() / 2) {
        centerX = maxX - haika.canvas.getWidth() / 2;
      }
      if (centerX < -maxX + haika.canvas.getWidth() / 2) {
        centerX = -maxX + haika.canvas.getWidth() / 2;
      }
      haika.centerX = -centerX.toFixed(0);
      return haika.render();
    }
  });
  return new Dragdealer('vertical-scroller', {
    y: defaultY,
    horizontal: false,
    vertical: true,
    animationCallback: function(x, y) {
      var centerY;
      centerY = y * 10000 - scroll_weight;
      if (centerY > maxY - haika.canvas.getHeight() / 2) {
        centerY = maxY - haika.canvas.getHeight() / 2;
      }
      if (centerY < -maxY + haika.canvas.getHeight() / 2) {
        centerY = -maxY + haika.canvas.getHeight() / 2;
      }
      haika.centerY = -centerY.toFixed(0);
      return haika.render();
    }
  });
};

//# sourceMappingURL=haika-scrollbar.js.map
