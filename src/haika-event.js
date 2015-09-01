$.extend(haika, {
  eventStack: [],
  event: {
    init: function() {
      var func, i, len, ref, results;
      this.shortcut();
      this.etc();
      ref = haika.eventStack;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        func = ref[i];
        results.push(func());
      }
      return results;
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
    etc: function() {
      return $(window).on('beforeunload', (function(_this) {
        return function(event) {
          haika.render();
          haika.save();
        };
      })(this));
    }
  }
});
