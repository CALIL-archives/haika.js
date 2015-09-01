$.extend(haika, {
  toolbar: {
    init: function() {
      var addButtons, html, key, val;
      $('.haika-toolbar-container').show();
      addButtons = {
        shelf: {
          icon: 'square-o',
          title: '一般本棚',
          type: 'shelf',
          eachWidth: 90,
          eachHeight: 26,
          count: 5,
          side: 1
        },
        big_shelf: {
          icon: 'square-o',
          title: '大型本棚',
          type: 'shelf',
          eachWidth: 90,
          eachHeight: 33,
          count: 5,
          side: 1
        },
        magazine_shelf: {
          icon: 'square-o',
          title: '雑誌本棚',
          type: 'shelf',
          eachWidth: 90,
          eachHeight: 45,
          count: 5,
          side: 1
        },
        kamishibai_shelf: {
          icon: 'square-o',
          title: '紙芝居',
          type: 'shelf',
          eachWidth: 90,
          eachHeight: 90,
          count: 1,
          side: 1
        },
        booktrack_shelf: {
          icon: 'square-o',
          title: 'ブックトラック',
          type: 'shelf',
          eachWidth: 60,
          eachHeight: 40,
          count: 1,
          side: 1,
          angle: 20
        },
        curved_shelf: {
          icon: 'dot-circle-o',
          title: '円形本棚',
          type: 'curved_shelf',
          count: 3,
          side: 2
        },
        beacon: {
          type: 'beacon',
          icon: 'square',
          title: 'ビーコン',
          fill: '#000000',
          stroke: '#0000ee'
        },
        wall: {
          type: 'wall',
          icon: 'square',
          title: '壁',
          height_scale: 1,
          width_scale: 1,
          fill: '#000000'
        },
        floor: {
          type: 'floor',
          icon: 'square',
          title: '床',
          height_scale: 1,
          width_scale: 1,
          fill: ''
        }
      };
      if (!this.readOnly) {
        for (key in addButtons) {
          val = addButtons[key];
          html = "<li id=\"add_" + key + "\" key=\"" + key + "\" type=\"" + val.type + "\"><i class=\"fa fa-" + val.icon + "\"></i> " + val.title + "</li>";
          $('.toolbar-menu').append(html);
          $('#add_' + key).click(function(e) {
            var object;
            key = $(e.target).attr('key');
            object = addButtons[key];
            return haika.addObject(object);
          });
        }
      }
      return this.show('shelf');
    },
    show: function(type) {
      return $('.haika-toolbar-container ul:first>li').each(function(i, button) {
        if ($(button).attr('type').match(type)) {
          return $(button).show();
        } else {
          return $(button).hide();
        }
      });
    }
  }
});

haika.htmlStack.push("<div class=\"haika-toolbar-container\">\n  <ul class=\"toolbar-menu\">\n  </ul>\n</div>");
