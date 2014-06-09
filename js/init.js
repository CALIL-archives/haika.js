// Generated by CoffeeScript 1.7.1
var add;

app.init({
  canvas: 'canvas',
  canvas_width: window.innerWidth,
  canvas_height: window.innerHeight - 100,
  scale: 1,
  max_width: 10000,
  max_height: 10000,
  bgurl: 'img/meidai2.png',
  bgopacity: 0.2,
  bgscale: 4.425
});

$(window).resize(function() {
  app.canvas.setWidth(window.innerWidth);
  app.canvas.setHeight(window.innerHeight - 100);
  return app.render();
});

add = function(left, top) {
  var shelf;
  if (left == null) {
    left = 0;
  }
  if (top == null) {
    top = 0;
  }
  shelf = new fabric.Shelf({
    count: parseInt($('#count').val()),
    side: parseInt($('#side').val()),
    top: app.transformX_cm2px(app.centerY),
    left: app.transformY_cm2px(app.centerX),
    fill: "#CFE2F3",
    stroke: "#000000",
    angle: parseInt($('#angle').val())
  });
  app.add(shelf);
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
  $(".toright").click(function() {
    return app.toRight();
  });
  $(".toleft").click(function() {
    return app.toLeft();
  });
  $(".totop").click(function() {
    return app.toTop();
  });
  $(".tobottom").click(function() {
    return app.toBottom();
  });
  $(".rotate").slider({
    min: 0,
    max: 360,
    step: 10,
    value: 0,
    slide: function(event, ui) {
      var activeObject;
      activeObject = app.canvas.getActiveObject();
      if (activeObject) {
        activeObject.angle = ui.value;
        activeObject.setCoords();
        return app.canvas.renderAll();
      }
    }
  });
  $(".svg").click(function() {
    return app.getSVG();
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

//# sourceMappingURL=init.map
