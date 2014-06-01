// Generated by CoffeeScript 1.3.1
var add;

app.init({
  canvas: 'canvas',
  bgurl: 'http://office.nanzan-u.ac.jp/TOSHOKAN/publication/bulletin/kiyo7/03-01.jpg',
  bgopacity: 0.5
});

app.scale = 1;

add = function(top, left, angle) {
  var shelf;
  if (top == null) {
    top = 300;
  }
  if (left == null) {
    left = 300;
  }
  if (angle == null) {
    angle = 0;
  }
  shelf = new fabric.Shelf({
    count: parseInt($('#count').val()),
    side: $('#side').val(),
    top: top,
    left: left,
    fill: "#CFE2F3",
    stroke: "#000000",
    angle: angle
  });
  return app.add(shelf);
};

setTimeout(function() {
  return addmany();
}, 500);

$(function() {
  window.addmany = function() {
    var x, y;
    y = 0;
    while (y < 8) {
      x = 0;
      while (x < 22) {
        add(100 + 200 * y, 100 + 50 * x, 90);
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
  return $(".rotate").slider({
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
});
