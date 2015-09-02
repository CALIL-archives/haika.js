var ScrollBar;

ScrollBar = (function() {
  function ScrollBar() {
    new Dragdealer('horizontal-scroller', {
      x: 0.5,
      animationCallback: function(x, y) {
        var maxWidth, viewWidth;
        maxWidth = 25000;
        viewWidth = haika.canvas.getWidth() * haika.scaleFactor;
        haika.centerX = ((x - 0.5) * ((maxWidth - viewWidth) / 2)).toFixed(0) * -1;
        return haika.render();
      }
    });
    new Dragdealer('vertical-scroller', {
      y: 0.5,
      horizontal: false,
      vertical: true,
      animationCallback: function(x, y) {
        var maxHeight, viewHeight;
        maxHeight = 25000;
        viewHeight = haika.canvas.getHeight() * haika.scaleFactor;
        haika.centerY = ((y - 0.5) * ((maxHeight - viewHeight) / 2)).toFixed(0) * -1;
        return haika.render();
      }
    });
  }

  return ScrollBar;

})();

haika.plugins.push(ScrollBar);

haika.htmlStack.push("<div  id=\"vertical-scroller\" class=\"content-scroller\">\n  <div class=\"dragdealer\">\n    <div class=\"handle scroller-gray-bar\">\n    </div>\n  </div>\n</div>\n<div id=\"horizontal-scroller\" class=\"dragdealer\">\n  <div class=\"handle scroller-gray-bar\">\n  </div>\n</div>");
