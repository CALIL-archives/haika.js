// Generated by CoffeeScript 1.7.1
var add, get_height, get_width, property_panel_width, scrollbar_height, scrollbar_width, undo;

scrollbar_width = $('#vertical-scroller').width();

scrollbar_height = $('#horizontal-scroller').height();

property_panel_width = $('.property_panel').width();

get_width = function() {
  return window.innerWidth - scrollbar_width - property_panel_width - 20;
};

get_height = function() {
  return window.innerHeight - $('.header').height() - scrollbar_height;
};

app.init({
  canvas: 'canvas',
  canvas_width: get_width(),
  canvas_height: get_height(),
  scale: 1,
  max_width: 10000,
  max_height: 10000,
  bgurl: 'img/meidai2.png',
  bgopacity: 0.2,
  bgscale: 4.425,
  callback: function() {
    var defaultX, defaultY, maxX, maxY, scroll_weight;
    scroll_weight = 5000;
    maxX = app.bgimg_width * app.options.bgscale / 2;
    maxY = app.bgimg_height * app.options.bgscale / 2;
    defaultX = -((app.centerX - scroll_weight) / 10000);
    defaultY = -((app.centerY - scroll_weight) / 10000);
    window.xscrollbar = new Dragdealer('horizontal-scroller', {
      x: defaultX,
      animationCallback: function(x, y) {
        var centerX;
        app.unselect();
        centerX = x * 10000 - scroll_weight;
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
    return new Dragdealer('vertical-scroller', {
      y: defaultY,
      horizontal: false,
      vertical: true,
      animationCallback: function(x, y) {
        var centerY;
        app.unselect();
        centerY = y * 10000 - scroll_weight;
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
  }
});

$('.main_container, .canvas_panel').css('width', get_width());

$('#vertical-scroller, #vertical-scroller .dragdealer').css('height', get_height());

$('.property_panel').css('height', get_height() + scrollbar_height);

$(window).resize(function() {
  app.canvas.setWidth(get_width());
  app.canvas.setHeight(get_height());
  $('.main_container, .canvas_panel').css('width', get_width());
  $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', get_height());
  $('.property_panel').css('height', get_height() + scrollbar_height);
  return app.render();
});

add = function(left, top) {
  var id, klass, object;
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
  object = new klass({
    count: parseInt($('#count').val()),
    side: parseInt($('#side').val()),
    top: app.transformTopY_cm2px(app.centerY),
    left: app.transformLeftX_cm2px(app.centerX),
    fill: "#CFE2F3",
    stroke: "#000000",
    angle: parseInt($('#angle').val())
  });
  id = app.add(object);
  app.set_state(object);
  app.render();
  undo.add(id);
  return $(app.canvas.getObjects()).each((function(_this) {
    return function(i, obj) {
      if (obj.id === object.id) {
        return setTimeout(function() {
          app.canvas.setActiveObject(app.canvas.item(i));
          return $('.add').blur();
        }, 10);
      }
    };
  })(this));
};

$(function() {
  var cancel_default, timeout;
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
  $('.nav-tabs a').click(function(e) {
    e.preventDefault();
    app.state = $(e.target).attr('class');
    app.render();
    return $(this).tab('show');
  });
  $(".add").click(function() {
    add();
    return app.render();
  });
  $(".add_shelf").click(function() {
    $('#type').val('Shelf');
    add();
    return app.render();
  });
  $(".add_curved_shelf").click(function() {
    $('#type').val('curvedShelf');
    add();
    return app.render();
  });
  $(".add_beacon").click(function() {
    $('#type').val('Beacon');
    add();
    return app.render();
  });
  $(".remove").click(function() {
    var object;
    object = app.canvas.getActiveObject();
    app.remove();
    if (object) {
      return undo.remove(object);
    }
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
  $(".copy").click(function() {
    return app.copy();
  });
  $(".paste").click(function() {
    return app.paste();
  });
  $(".svg").click(function() {
    return app.getSVG();
  });
  $(".loadsvg").click(function() {
    return loadSVG('http://fabreasy.com/demo_front.svg', app.canvas, function() {
      return alert('done');
    });
  });
  $(".geojson").click(function() {
    return app.getGeoJSON();
  });
  $(".reset").click(function() {
    app.objects = [];
    localStorage.clear();
    return location.reload();
  });
  timeout = false;
  $('canvas').on('mousewheel', (function(_this) {
    return function(event) {
      if (timeout) {
        return;
      } else {
        timeout = setTimeout(function() {
          return timeout = false;
        }, 100);
      }
      if (event.deltaY > 0) {
        app.zoomIn();
      }
      if (event.deltaY < 0) {
        return app.zoomOut();
      }
    };
  })(this));
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
  $('#canvas_render').click(function() {
    return app.render();
  });
  $('.undo').click(function() {
    return undo.undoManager.undo();
  });
  cancel_default = function(e) {
    if (e.preventDefault) {
      return e.preventDefault();
    } else {
      return e.returnValue = false;
    }
  };
  Mousetrap.bind('mod+c', function() {
    app.copy();
    return false;
  });
  Mousetrap.bind('mod+v', function() {
    app.paste();
    return false;
  });
  Mousetrap.bind('mod+d', function(e) {
    cancel_default(e);
    app.duplicate();
    return false;
  });
  Mousetrap.bind('mod+a', function(e) {
    cancel_default(e);
    app.select_all();
    return false;
  });
  Mousetrap.bind('mod+z', function(e) {
    cancel_default(e);
    undo.undoManager.undo();
    return false;
  });
  Mousetrap.bind(['esc', 'escape'], function(e) {
    cancel_default(e);
    app.unselect_all();
    return false;
  });
  Mousetrap.bind(['up', 'shift+up'], function(e) {
    cancel_default(e);
    app.up(e);
    return false;
  });
  Mousetrap.bind(['down', 'shift+down'], function(e) {
    cancel_default(e);
    app.down(e);
    return false;
  });
  Mousetrap.bind(['left', 'shift+left'], function(e) {
    cancel_default(e);
    app.left(e);
    return false;
  });
  Mousetrap.bind(['right', 'shift+right'], function(e) {
    cancel_default(e);
    app.right(e);
    return false;
  });
  return $(document).unbind("keydown").bind("keydown", function(event) {
    var d, doPrevent;
    doPrevent = false;
    if (event.keyCode === 8 || event.keyCode === 46) {
      d = event.srcElement || event.target;
      if ((d.tagName.toUpperCase() === "INPUT" && (d.type.toUpperCase() === "TEXT" || d.type.toUpperCase() === "PASSWORD" || d.type.toUpperCase() === "FILE" || d.type.toUpperCase() === "EMAIL")) || d.tagName.toUpperCase() === "TEXTAREA") {
        doPrevent = d.readOnly || d.disabled;
      } else {
        doPrevent = true;
      }
    }
    if (doPrevent) {
      event.preventDefault();
      app.remove();
    }
  });
});

undo = {
  undoManager: new UndoManager(),
  states: [],
  set_selected: true,
  add: function(id) {
    log('add set');
    return this.undoManager.add({
      undo: (function(_this) {
        return function() {
          var object;
          log('undo add ' + id);
          object = _this.get_object(id);
          log(object);
          return app.__remove(object);
        };
      })(this),
      redo: (function(_this) {
        return function() {};
      })(this)
    });
  },
  remove: function(object) {
    log('remove set');
    return this.undoManager.add({
      undo: (function(_this) {
        return function() {
          log('undo remove ' + object.id);
          log(object);
          app.add(object);
          return app.render();
        };
      })(this),
      redo: (function(_this) {
        return function() {};
      })(this)
    });
  },
  init: function() {
    app.canvas.on("object:selected", (function(_this) {
      return function(e) {
        var object, originalState;
        object = e.target;
        if (!_this.set_selected) {
          _this.set_selected = true;
          return;
        }
        if (_this.states.length === 0 || object.id !== _this.states[_this.states.length - 1].id) {
          object.saveState();
          originalState = $.extend(true, {}, object.originalState);
          originalState.state_type = 'selected';
          return _this.states.push(originalState);
        }
      };
    })(this));
    app.canvas.on("selection:cleared", (function(_this) {
      return function(e) {
        var object;
        return object = e.target;
      };
    })(this));
    return app.canvas.on("object:modified", (function(_this) {
      return function(e) {
        var object, originalState;
        object = e.target;
        object.saveState();
        originalState = $.extend(true, {}, object.originalState);
        originalState.state_type = 'modified';
        _this.states.push(originalState);
        _this.undoManager.add({
          undo: function() {
            var state;
            if (_this.states.length > 0) {
              app.canvas.deactivateAll();
              state = _this.states[_this.states.length - 2];
              object = _this.get_object(state.id);
              if (object) {
                _this.set_state(object, state);
                _this.states.pop();
                if (_this.states[_this.states.length - 1].state_type === 'selected') {
                  _this.states.pop();
                }
                _this.set_selected = false;
                app.canvas.setActiveObject(object);
              }
              return log(_this.states);
            }
          },
          redo: function() {}
        });
      };
    })(this));
  },
  get_object: function(id) {
    var o, object, _i, _len, _ref;
    object = null;
    _ref = app.canvas.getObjects();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      o = _ref[_i];
      if (o.id === id) {
        object = o;
        break;
      }
    }
    return object;
  },
  set_state: function(object, state) {
    object.setOptions(state);
    return object.setCoords();
  }
};

undo.init();

//# sourceMappingURL=init.map
