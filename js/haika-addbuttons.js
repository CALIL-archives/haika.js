$.extend(haika, {
  addbuttons: {
    add: function(val) {
      var id, klass, object;
      log(val);
      if (val.type.match(/shelf$/)) {
        val.type = 'shelf';
      }
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
      if (val.type === 'shelf') {
        object.eachWidth = val.eachWidth;
        object.eachHeight = val.eachHeight;
      }
      id = haika.add(object);
      haika.render();
      haika.undo.add(id);
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
    },
    addmany: function() {
      var x, y;
      y = 0;
      while (y < 8) {
        x = 0;
        while (x < 22) {
          this.add(200 + 400 * y, 100 + 50 * x, 90);
          x++;
        }
        y++;
      }
      haika.render();
    },
    showAddButtons: function(state) {
      return $('.toolbar_container ul:first>li').each(function(i, button) {
        if ($(button).attr('state') === state) {
          return $(button).show();
        } else {
          return $(button).hide();
        }
      });
    }
  }
});

$(function() {
  var addButtons, html, key, val, _results;
  addButtons = {
    shelf: {
      icon: 'square-o',
      title: '一般本棚',
      eachWidth: 90,
      eachHeight: 26,
      count: 5,
      side: 1,
      state: 'shelf'
    },
    big_shelf: {
      icon: 'square-o',
      title: '大型本棚',
      eachWidth: 90,
      eachHeight: 33,
      count: 5,
      side: 1,
      state: 'shelf'
    },
    magazine_shelf: {
      icon: 'square-o',
      title: '雑誌本棚',
      eachWidth: 90,
      eachHeight: 45,
      count: 5,
      side: 1,
      state: 'shelf'
    },
    kamishibai_shelf: {
      icon: 'square-o',
      title: '紙芝居',
      eachWidth: 90,
      eachHeight: 90,
      count: 1,
      side: 1,
      state: 'shelf'
    },
    booktrack_shelf: {
      icon: 'square-o',
      title: 'ブックトラック',
      eachWidth: 60,
      eachHeight: 40,
      count: 1,
      side: 1,
      angle: 20,
      state: 'shelf'
    },
    curved_shelf: {
      icon: 'dot-circle-o',
      title: '円形本棚',
      count: 3,
      side: 2,
      state: 'shelf'
    },
    beacon: {
      icon: 'square',
      title: 'ビーコン',
      state: 'beacon'
    },
    wall: {
      icon: 'square',
      title: '壁',
      state: 'wall'
    },
    floor: {
      icon: 'square',
      title: '床',
      state: 'floor'
    }
  };
  _results = [];
  for (key in addButtons) {
    val = addButtons[key];
    html = "<li id=\"add_" + key + "\" key=\"" + key + "\" state=\"" + val.state + "\"><i class=\"fa fa-" + val.icon + "\"></i> " + val.title + "</li>";
    $('.toolbar_container ul:first').append(html);
    haika.addbuttons.showAddButtons('shelf');
    _results.push($('#add_' + key).click(function(e) {
      var object;
      key = $(e.target).attr('key');
      object = addButtons[key];
      object.type = key;
      haika.addbuttons.add(object);
      return haika.render();
    }));
  }
  return _results;
});

//# sourceMappingURL=haika-addbuttons.js.map
