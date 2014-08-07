// Generated by CoffeeScript 1.7.1
var add, addPixel, addmany, bind, getHeight, getWidth, loadComplete, loadImg, property_panel_width, scrollbar_height, scrollbar_width, setScrollbar, undo;

scrollbar_width = $('#vertical-scroller').width();

scrollbar_height = $('#horizontal-scroller').height();

property_panel_width = $('.property_panel').width();

getWidth = function() {
  return window.innerWidth - scrollbar_width - property_panel_width - 20;
};

getHeight = function() {
  return window.innerHeight - $('.header').height() - scrollbar_height;
};

$('#bgimg').change(function(e) {
  var data, files;
  files = e.target.files;
  if (files.length === 0) {
    return;
  }
  if (haika.isLocal()) {
    return haika.loadBg(files[0]);
  } else {
    data = new FormData();
    data.append('id', haika.id);
    data.append('userfile', files[0]);
    return $.ajax({
      url: '/haika_store/upload.php',
      data: data,
      cache: false,
      contentType: false,
      processData: false,
      type: 'POST',
      success: function(data) {
        var url;
        url = '/haika_store/image/' + haika.id + '_' + files[0].name;
        return haika.loadBgFromUrl(url);
      }
    });
  }
});

setScrollbar = function() {
  var bgimg_height, bgimg_width, defaultX, defaultY, maxX, maxY, scroll_weight;
  scroll_weight = 5000;
  bgimg_width = haika.bgimg ? haika.bgimg_width : 2500;
  bgimg_height = haika.bgimg ? haika.bgimg_height : 2500;
  maxX = bgimg_width * haika.options.bgscale / 2;
  maxY = bgimg_height * haika.options.bgscale / 2;
  defaultX = -((haika.centerX - scroll_weight) / 10000);
  defaultY = -((haika.centerY - scroll_weight) / 10000);
  new Dragdealer('horizontal-scroller', {
    x: defaultX,
    animationCallback: function(x, y) {
      var centerX;
      haika.unselect();
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
      haika.unselect();
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

bind = function(func, do_active) {
  var group, object, _i, _len, _ref, _results;
  if (do_active == null) {
    do_active = true;
  }
  object = haika.canvas.getActiveObject();
  if (object) {
    func(object);
  }
  group = haika.canvas.getActiveGroup();
  if (group) {
    _ref = group.getObjects();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      _results.push(func(object));
    }
    return _results;
  }
};

$('#fill-color').colorselector({
  callback: function(value, color, title) {
    haika.fillColor = color;
    bind(function(object) {
      return object.fill = color;
    });
    return haika.canvas.renderAll();
  }
});

$('#stroke-color').colorselector({
  callback: function(value, color, title) {
    haika.strokeColor = color;
    bind(function(object) {
      return object.stroke = color;
    });
    return haika.canvas.renderAll();
  }
});

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
  var html, key, toolbar, val, _results;
  $('.nav-tabs a').click(function(e) {
    e.preventDefault();
    haika.state = $(e.target).attr('class');
    haika.render();
    return $(this).tab('show');
  });
  toolbar = {
    shelf: {
      icon: 'square-o',
      title: '一般本棚',
      eachWidth: 90,
      eachHeight: 26,
      count: 5,
      side: 1
    },
    big_shelf: {
      icon: 'square-o',
      title: '大型本棚',
      eachWidth: 90,
      eachHeight: 33,
      count: 5,
      side: 1
    },
    magazine_shelf: {
      icon: 'square-o',
      title: '雑誌本棚',
      eachWidth: 90,
      eachHeight: 45,
      count: 5,
      side: 1
    },
    kamishibai_shelf: {
      icon: 'square-o',
      title: '紙芝居',
      eachWidth: 90,
      eachHeight: 90,
      count: 1,
      side: 1
    },
    booktrack_shelf: {
      icon: 'square-o',
      title: 'ブックトラック',
      eachWidth: 60,
      eachHeight: 40,
      count: 1,
      side: 1,
      angle: 20
    },
    curved_shelf: {
      icon: 'dot-circle-o',
      title: '円形本棚',
      count: 3,
      side: 2
    },
    beacon: {
      icon: 'square',
      title: 'ビーコン'
    },
    wall: {
      icon: 'square',
      title: '壁'
    },
    floor: {
      icon: 'square',
      title: '床'
    }
  };
  _results = [];
  for (key in toolbar) {
    val = toolbar[key];
    html = "<li id=\"add_" + key + "\" key=\"" + key + "\"><i class=\"fa fa-" + val.icon + "\"></i> " + val.title + "</li>";
    $('.toolbar_container ul:first').append(html);
    _results.push($('#add_' + key).click(function(e) {
      var object;
      key = $(e.target).attr('key');
      object = toolbar[key];
      object.type = key;
      add(object);
      return haika.render();
    }));
  }
  return _results;
});

$(function() {
  $(".add_custom_shelf").click(function() {
    add('custom_shelf');
    return haika.render();
  });
  $(".add_beacon").click(function() {
    add('beacon');
    return haika.render();
  });
  $(".remove").click(function() {
    var object;
    object = haika.canvas.getActiveObject();
    haika.remove();
    if (object) {
      return undo.remove(object);
    }
  });
  $(".zoomin").click(function() {
    return haika.zoomIn();
  });
  $(".zoomout").click(function() {
    return haika.zoomOut();
  });
  $(".zoomreset").click(function() {
    return haika.zoomReset();
  });
  $(".bringtofront").click(function() {
    return haika.bringToFront();
  });
  $(".duplicate").click(function() {
    return haika.duplicate();
  });
  $(".copy").click(function() {
    return haika.copy();
  });
  $(".paste").click(function() {
    return haika.paste();
  });
  $(".align-left").click(function() {
    return haika.alignLeft();
  });
  $(".align-center").click(function() {
    return haika.alignCenter();
  });
  $(".align-right").click(function() {
    return haika.alignRight();
  });
  $(".align-top").click(function() {
    return haika.alignTop();
  });
  $(".align-vcenter").click(function() {
    return haika.alignVcenter();
  });
  return $(".align-bottom").click(function() {
    return haika.alignBottom();
  });
});

$(function() {
  var cancel_default, map_created, timeout, toggle_map;
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
        haika.zoomIn();
      }
      if (event.deltaY < 0) {
        return haika.zoomOut();
      }
    };
  })(this));
  $('#canvas_width').change(function() {
    return haika.canvas.setWidth($(this).val());
  });
  $('#canvas_height').change(function() {
    return haika.canvas.setHeight($(this).val());
  });
  $('#canvas_centerX').change(function() {
    return haika.centerX = parseInt($(this).val());
  });
  $('#canvas_centerY').change(function() {
    return haika.centerY = parseInt($(this).val());
  });
  $('#canvas_bgscale').change(function() {
    return haika.options.bgscale = parseFloat($(this).val());
  });
  $('#ex1').slider({
    formater: function(value) {
      value = parseFloat(value).toFixed(1);
      $('#canvas_bgopacity').val();
      haika.options.bgopacity = value;
      haika.render();
      return value;
    }
  });
  $('#canvas_render').click(function() {
    return haika.render();
  });
  $('#canvas_lat').change(function() {
    haika.options.lat = parseFloat($(this).val());
    return haika.save();
  });
  $('#canvas_lon').change(function() {
    haika.options.lon = parseFloat($(this).val());
    return haika.save();
  });
  $('#canvas_angle').change(function() {
    haika.options.angle = parseInt($(this).val());
    return haika.save();
  });
  map_created = false;
  toggle_map = function() {
    if ($('.haika_container').css('display') === 'block') {
      if (!map_created) {
        map_setting();
        map_created = true;
      }
      $('.haika_container').hide();
      $('.map_container').show();
      return $('#map_query').focus();
    } else {
      $('.haika_container').show();
      return $('.map_container').hide();
    }
  };
  $('.map_setting').click(toggle_map);
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
  Mousetrap.bind('mod+o', function() {
    $('#file').trigger('click');
    return false;
  });
  Mousetrap.bind('mod+c', function() {
    haika.copy();
    return false;
  });
  Mousetrap.bind('mod+v', function() {
    haika.paste();
    return false;
  });
  Mousetrap.bind('mod+d', function(e) {
    cancel_default(e);
    haika.duplicate();
    return false;
  });
  Mousetrap.bind('mod+a', function(e) {
    cancel_default(e);
    haika.selectAll();
    return false;
  });
  Mousetrap.bind('mod+z', function(e) {
    cancel_default(e);
    undo.undoManager.undo();
    return false;
  });
  Mousetrap.bind(['esc', 'escape'], function(e) {
    cancel_default(e);
    haika.unselectAll();
    return false;
  });
  Mousetrap.bind(['up', 'shift+up'], function(e) {
    cancel_default(e);
    haika.up(e);
    return false;
  });
  Mousetrap.bind(['down', 'shift+down'], function(e) {
    cancel_default(e);
    haika.down(e);
    return false;
  });
  Mousetrap.bind(['left', 'shift+left'], function(e) {
    cancel_default(e);
    haika.left(e);
    return false;
  });
  Mousetrap.bind(['right', 'shift+right'], function(e) {
    cancel_default(e);
    haika.right(e);
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
      haika.remove();
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
          object = _this.getObject(id);
          log(object);
          return haika.__remove(object);
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
          haika.add(object);
          return haika.render();
        };
      })(this),
      redo: (function(_this) {
        return function() {};
      })(this)
    });
  },
  init: function() {
    haika.canvas.on("object:selected", (function(_this) {
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
    haika.canvas.on("selection:cleared", (function(_this) {
      return function(e) {
        var object;
        return object = e.target;
      };
    })(this));
    return haika.canvas.on("object:modified", (function(_this) {
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
              haika.canvas.deactivateAll();
              state = _this.states[_this.states.length - 2];
              object = _this.getObject(state.id);
              if (object) {
                _this.setState(object, state);
                _this.states.pop();
                if (_this.states[_this.states.length - 1].state_type === 'selected') {
                  _this.states.pop();
                }
                _this.set_selected = false;
                haika.canvas.setActiveObject(object);
              }
              return log(_this.states);
            }
          },
          redo: function() {}
        });
      };
    })(this));
  },
  getObject: function(id) {
    var o, object, _i, _len, _ref;
    object = null;
    _ref = haika.canvas.getObjects();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      o = _ref[_i];
      if (o.id === id) {
        object = o;
        break;
      }
    }
    return object;
  },
  setState: function(object, state) {
    object.setOptions(state);
    return object.setCoords();
  }
};

undo.init();

loadImg = function(file) {
  var reader;
  if (!file.type.match(/image\/.+/)) {
    return;
  }
  if (file.type === "image/svg+xml") {
    return;
  }
  reader = new FileReader();
  reader.onload = function() {
    return loadComplete(this.result);
  };
  return reader.readAsDataURL(file);
};

$('#file').change(function(e) {
  var files;
  files = e.target.files;
  if (files.length === 0) {
    return;
  }
  return loadImg(files[0]);
});

loadComplete = function(data) {
  var canvas, ctx, h, img, params, w, worker;
  img = new Image();
  img.src = data;
  canvas = document.createElement('canvas');
  ctx = canvas.getContext('2d');
  canvas.width = img.width;
  canvas.height = img.height;
  ctx.translate(0, img.height);
  ctx.scale(1, -1);
  ctx.drawImage(img, 0, 0);
  w = canvas.width;
  h = canvas.height;
  data = ctx.getImageData(0, 0, w, h).data;
  params = {
    image: data,
    w: w,
    h: h
  };
  worker = new Worker("js/worker.js");
  worker.onmessage = function(e) {
    var result, results, _i, _len;
    log(e.data);
    switch (e.data.status) {
      case "working":
        return log(e.data.count);
      case "end":
        results = e.data.result;
        for (_i = 0, _len = results.length; _i < _len; _i++) {
          result = results[_i];
          addPixel(result.x, result.y, result.color);
        }
        return haika.render();
    }
  };
  return worker.postMessage(params);
};

addPixel = function(x, y, color) {
  var dot, klass, object;
  dot = 10;
  klass = haika.getClass('shelf');
  object = new klass({
    top: haika.transformTopY_cm2px(y * dot),
    left: haika.transformLeftX_cm2px(x * dot),
    fill: color,
    stroke: color,
    angle: 0,
    count: 1,
    side: 1,
    eachWidth: dot,
    eachHeight: dot
  });
  return haika.add(object);
};

/*
//@ sourceMappingURL=init.map
*/
