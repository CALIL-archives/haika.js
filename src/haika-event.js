$.extend(haika, {
  event: {
    init: function() {
      this.shortcut();
      this.button();
      this.zoom();
      this.contextMenu();
      return this.etc();
    },
    button: function() {
      $('.haika-map-setting').click(function() {
        return location.href = 'map.html' + location.hash;
      });
      $('.haika-remove').click(function() {
        var object;
        object = haika.canvas.getActiveObject();
        haika.remove();
        if (object) {
          return haika.undo.remove(object);
        }
      });
      $('.haika-bringtofront').click(function() {
        return haika.bringToFront();
      });
      $('.haika-duplicate').click(function() {
        return haika.duplicate();
      });
      $('.haika-copy').click(function() {
        return haika.copy();
      });
      $('.haika-paste').click(function() {
        return haika.paste();
      });
      $('.haika-align-left').click(function() {
        return haika.alignLeft();
      });
      $('.haika-align-center').click(function() {
        return haika.alignCenter();
      });
      $('.haika-align-right').click(function() {
        return haika.alignRight();
      });
      $('.haika-align-top').click(function() {
        return haika.alignTop();
      });
      $('.haika-align-vcenter').click(function() {
        return haika.alignVcenter();
      });
      $('.haika-align-bottom').click(function() {
        return haika.alignBottom();
      });
      $('#haika-canvas-bgscale').change(function() {
        haika.backgroundScaleFactor = parseFloat($(this).val());
        return haika.render();
      });
      $('#haika-bgreset').click(function() {
        return haika.setBackgroundUrl('');
      });
      $('#haika-bgopacity-slider').slider({
        step: 1,
        min: 1,
        max: 100,
        value: haika.backgroundOpacity * 100,
        formatter: function(value) {
          haika.backgroundOpacity = value / 100;
          haika.render();
          return value / 100;
        }
      });
      $('#haika-bgimg').change(function(e) {
        var data, files;
        files = e.target.files;
        if (files.length === 0) {
          return;
        }
        data = new FormData();
        data.append('id', haika._dataId);
        data.append('userfile', files[0]);
        return $.ajax({
          url: 'http://lab.calil.jp/haika_store/upload.php',
          data: data,
          cache: false,
          contentType: false,
          processData: false,
          type: 'POST',
          success: function(data) {
            var url;
            url = 'http://lab.calil.jp/haika_store/image/' + haika._dataId + '_' + files[0].name;
            return haika.setBackgroundUrl(url);
          }
        });
      });
      return $('.haika-undo').click(function() {
        return haika.undo.undoManager.undo();
      });
    },
    shortcut: function() {
      var cancel_default;
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
        haika.undo.undoManager.undo();
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
      return $(document).unbind('keydown').bind('keydown', function(event) {
        var d, doPrevent;
        doPrevent = false;
        if (event.keyCode === 8 || event.keyCode === 46) {
          d = event.srcElement || event.target;
          if ((d.tagName.toUpperCase() === 'INPUT' && (d.type.toUpperCase() === 'TEXT' || d.type.toUpperCase() === 'PASSWORD' || d.type.toUpperCase() === 'FILE' || d.type.toUpperCase() === 'EMAIL')) || d.tagName.toUpperCase() === 'TEXTAREA') {
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
    },
    zoom: function() {
      $('.haika-full').click(function() {
        return haika.zoomFull();
      });
      $('.haika-zoomin').click(function() {
        return haika.zoomIn();
      });
      $('.haika-zoomout').click(function() {
        return haika.zoomOut();
      });
      return $('.zoomreset').click(function() {
        return haika.setScale(1);
      });
    },
    contextMenu: function() {
      return $('#haika-canvas').contextmenu({
        target: '#haika-context-menu',
        before: function(e, element, target) {
          e.preventDefault();
          if (e.target.tagName !== 'CANVAS') {
            this.closemenu();
            return false;
          }
          if (haika.canvas.getActiveObject()) {
            log('selected');
            $('#haika-context-menu').find('.haika-select-context-menu').show();
          } else {
            log('nonselect');
            $('#haika-context-menu').find('.haika-select-context-menu').hide();
          }
          return true;
        },
        onItem: function(context, e) {}
      });
    },
    etc: function() {
      $(window).on('beforeunload', (function(_this) {
        return function(event) {
          haika.render();
          haika.save();
        };
      })(this));
      return $('.haika-nav a').click(function(e) {
        var tabName;
        e.preventDefault();
        tabName = $(e.target).attr('class');
        haika.toolbar.show(tabName);
        if (tabName === 'beacon') {
          haika.layer = haika.CONST_LAYERS.BEACON;
        }
        if (tabName === 'wall') {
          haika.layer = haika.CONST_LAYERS.WALL;
        }
        if (tabName === 'floor') {
          haika.layer = haika.CONST_LAYERS.FLOOR;
        }
        if (tabName === 'shelf') {
          haika.layer = haika.CONST_LAYERS.SHELF;
        }
        haika.render();
        $('.haika-nav li').removeClass('active');
        return $(this).closest('li').addClass('active');
      });
    }
  }
});

//# sourceMappingURL=haika-event.js.map
