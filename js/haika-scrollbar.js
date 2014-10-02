var initScrollBar;

initScrollBar = function() {
  new Dragdealer('horizontal-scroller', {
    x: 0.5,
    animationCallback: function(x, y) {
      var maxWidth, viewWidth;
      maxWidth = 25000;
      viewWidth = haika.canvas.getWidth() * haika.scaleFactor;
      log('viewWidth:' + viewWidth);
      haika.centerX = ((x - 0.5) * ((maxWidth - viewWidth) / 2)).toFixed(0) * -1;
      return haika.render();
    }
  });
  return new Dragdealer('vertical-scroller', {
    y: 0.5,
    horizontal: false,
    vertical: true,
    animationCallback: function(x, y) {
      var _max;
      _max = haika.canvas.backgroundImage ? haika.canvas.backgroundImage.height : 2500;
      haika.centerY = ((y - 0.5) * _max).toFixed(0) * -1;
      return haika.render();
    }
  });
};

//# sourceMappingURL=haika-scrollbar.js.map
