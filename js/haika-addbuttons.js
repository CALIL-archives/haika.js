var add, addmany;

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
  var addButtons, html, key, val, _results;
  addButtons = {
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
  for (key in addButtons) {
    val = addButtons[key];
    html = "<li id=\"add_" + key + "\" key=\"" + key + "\"><i class=\"fa fa-" + val.icon + "\"></i> " + val.title + "</li>";
    $('.toolbar_container ul:first').append(html);
    _results.push($('#add_' + key).click(function(e) {
      var object;
      key = $(e.target).attr('key');
      object = addButtons[key];
      object.type = key;
      add(object);
      return haika.render();
    }));
  }
  return _results;
});

//# sourceMappingURL=haika-addbuttons.js.map
