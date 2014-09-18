$('#bgimg').change(function(e) {
  var data, files;
  files = e.target.files;
  if (files.length === 0) {
    return;
  }
  if (haika.isLocal()) {
    return haika.loadBgFromFile(files[0]);
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
  var cancel_default, timeout;
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
  $('#canvas_bgscale').change(function() {
    haika.options.bgscale = parseFloat($(this).val());
    return haika.render();
  });
  $('#bgreset').click(function() {
    return haika.resetBg();
  });
  $('#bgopacity_slider').slider({
    step: 1,
    min: 1,
    max: 100,
    value: haika.options.bgopacity * 100,
    formatter: function(value) {
      haika.options.bgopacity = value / 100;
      haika.render();
      return value / 100;
    }
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

//# sourceMappingURL=haika-event.js.map
