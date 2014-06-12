// Generated by CoffeeScript 1.3.1
var add, get_height;

app.init({
  canvas: 'canvas',
  canvas_width: window.innerWidth - 30,
  canvas_height: window.innerHeight - $('.header').height() - 30,
  scale: 1,
  max_width: 10000,
  max_height: 10000,
  bgurl: 'img/meidai2.png',
  bgopacity: 0.2,
  bgscale: 4.425
});

$('.main_container, .canvas_panel').css('width', window.innerWidth - 30);

get_height = function() {
  return window.innerHeight - $('.header').height() - 30;
};

$('#vertical-scroller, #vertical-scroller .dragdealer').css('height', get_height());

$(window).resize(function() {
  app.canvas.setWidth(window.innerWidth - 30);
  app.canvas.setHeight(window.innerHeight - $('.header').height() - 30);
  $('.main_container, .canvas_panel').css('width', window.innerWidth - 30);
  $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', get_height());
  return app.render();
});

add = function(left, top) {
  var klass, shape;
  if (left == null) {
    left = 0;
  }
  if (top == null) {
    top = 0;
  }
  if ($('#type').val() === 'Shelf') {
    klass = fabric.Shelf;
  }
  if ($('#type').val() === 'curvedShelf') {
    klass = fabric.curvedShelf;
  }
  if ($('#type').val() === 'Beacon') {
    klass = fabric.Beacon;
  }
  shape = new klass({
    count: parseInt($('#count').val()),
    side: parseInt($('#side').val()),
    top: app.transformX_cm2px(app.centerY),
    left: app.transformY_cm2px(app.centerX),
    fill: "#CFE2F3",
    stroke: "#000000",
    angle: parseInt($('#angle').val())
  });
  app.add(shape);
  return app.render();
};

$(function() {
  window.addmany = function() {
    var x, y;
    y = 0;
    while (y < 8) {
      x = 0;
      while (x < 22) {
        add(200 + 400 * y, 100 + 50 * x, 90);
        x++;
      }
      y++;
    }
    app.render();
  };
  new Dragdealer('horizontal-scroller', {
    x: 0.5,
    animationCallback: function(x, y) {
      var centerX, maxX;
      maxX = app.bgimg_width * app.options.bgscale / 2;
      centerX = x * 10000 - 5000;
      if (centerX > maxX - app.canvas.getWidth() / 2) {
        centerX = maxX - app.canvas.getWidth() / 2;
      }
      if (centerX < -maxX + app.canvas.getWidth() / 2) {
        centerX = -maxX + app.canvas.getWidth() / 2;
      }
      app.centerX = -centerX.toFixed(0);
      return app.render();
    }
  });
  new Dragdealer('vertical-scroller', {
    y: 0.5,
    horizontal: false,
    vertical: true,
    animationCallback: function(x, y) {
      var centerY, maxY;
      maxY = app.bgimg_height * app.options.bgscale / 2;
      centerY = y * 10000 - 5000;
      if (centerY > maxY - app.canvas.getHeight() / 2) {
        centerY = maxY - app.canvas.getHeight() / 2;
      }
      if (centerY < -maxY + app.canvas.getHeight() / 2) {
        centerY = -maxY + app.canvas.getHeight() / 2;
      }
      app.centerY = -centerY.toFixed(0);
      return app.render();
    }
  });
  $(".add").click(function() {
    add();
    return app.render();
  });
  $(".remove").click(function() {
    return app.remove();
  });
  $(".zoomin").click(function() {
    return app.zoomIn();
  });
  $(".zoomout").click(function() {
    return app.zoomOut();
  });
  $(".zoomreset").click(function() {
    return app.zoomReset();
  });
  $(".bringtofront").click(function() {
    return app.bringToFront();
  });
  $(".duplicate").click(function() {
    return app.duplicate();
  });
  $(".svg").click(function() {
    return app.getSVG();
  });
  $(".geojson").click(function() {
    return app.getGeoJSON();
  });
  $(".reset").click(function() {
    localStorage.clear();
    return location.reload();
  });
  $('#canvas_width').change(function() {
    return app.canvas.setWidth($(this).val());
  });
  $('#canvas_height').change(function() {
    return app.canvas.setHeight($(this).val());
  });
  $('#canvas_centerX').change(function() {
    return app.centerX = parseInt($(this).val());
  });
  $('#canvas_centerY').change(function() {
    return app.centerY = parseInt($(this).val());
  });
  $('#canvas_bgscale').change(function() {
    return app.options.bgscale = parseInt($(this).val());
  });
  return $('#canvas_render').click(function() {
    return app.render();
  });
});
