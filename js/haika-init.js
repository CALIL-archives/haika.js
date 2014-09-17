var add, addmany, getHeight, getWidth, property_panel_width, scrollbar_height, scrollbar_width;

scrollbar_width = $('#vertical-scroller').width();

scrollbar_height = $('#horizontal-scroller').height();

property_panel_width = $('.property_panel').width();

getWidth = function() {
  return window.innerWidth - scrollbar_width - property_panel_width - 20;
};

getHeight = function() {
  return window.innerHeight - $('.header').height() - scrollbar_height;
};

$('.main_container, .canvas_panel').css('width', getWidth());

$('#vertical-scroller, #vertical-scroller .dragdealer').css('height', getHeight());

$('.property_panel').css('height', getHeight() + scrollbar_height);

$(window).resize(function() {
  haika.canvas.setWidth(getWidth());
  haika.canvas.setHeight(getHeight());
  $('.main_container, .canvas_panel').css('width', getWidth());
  $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', getHeight());
  $('.property_panel').css('height', getHeight() + scrollbar_height);
  return haika.render();
});

haika.init({
  canvas: 'canvas',
  canvas_width: getWidth(),
  canvas_height: getHeight(),
  scale: 1,
  max_width: 10000,
  max_height: 10000,
  bgopacity: 0.2,
  bgscale: 4.425,
  callback: setScrollbar
});

add = function(val) {
  var id, klass, object;
  log(val);
  klass = haika.getClass(val.type);
  object = new klass({
    top: haika.transformTopY_cm2px(haika.centerY),
    left: haika.transformLeftX_cm2px(haika.centerX),
    fill: haika.fillColor,
    stroke: haika.strokeColor,
    angle: val.angle != null ? val.angle : 0
  });
  if (val.count != null) {
    object.count = val.count;
  }
  if (val.side != null) {
    object.side = val.side;
  }
  if (val.type.match(/shelf$/)) {
    object.eachWidth = val.eachWidth;
    object.eachHeight = val.eachHeight;
  }
  id = haika.add(object);
  haika.setState(object);
  haika.render();
  undo.add(id);
  return $(haika.canvas.getObjects()).each((function(_this) {
    return function(i, obj) {
      if (obj.id === object.id) {
        return setTimeout(function() {
          haika.canvas.setActiveObject(haika.canvas.item(i));
          return $('.add').blur();
        }, 10);
      }
    };
  })(this));
};

addmany = function() {
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
  haika.render();
};

$(function() {
  return $('.nav-tabs a').click(function(e) {
    e.preventDefault();
    haika.state = $(e.target).attr('class');
    haika.render();
    return $(this).tab('show');
  });
});

//# sourceMappingURL=haika-init.js.map
