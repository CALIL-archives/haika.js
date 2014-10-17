$.extend(haika, {
  colorpicker: {
    init: function() {
      var bind, count, hex, hexColor, html, i, j, k, l;
      html = '';
      hex = new Array("f", "c", "9", "6", "3", "0");
      count = 2;
      j = 0;
      while (j < 6) {
        k = 0;
        while (k < 6) {
          l = 0;
          while (l < 6) {
            hexColor = hex[j] + hex[j] + hex[k] + hex[k] + hex[l] + hex[l];
            html += "<option data-color=\"#" + hexColor + "\" value=\"" + count + "\"></option>";
            l++;
            count++;
          }
          k++;
        }
        j++;
      }
      i = 0;
      while (i < 6) {
        hexColor = hex[i] + hex[i] + hex[i] + hex[i] + hex[i] + hex[i];
        html += "<option data-color=\"#" + hexColor + "\" value=\"" + count + "\"></option>";
        i++;
      }
      $('#fill-color').append(html);
      $('#stroke-color').append(html);
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
      return $('#stroke-color').colorselector({
        callback: function(value, color, title) {
          haika.strokeColor = color;
          bind(function(object) {
            return object.stroke = color;
          });
          return haika.canvas.renderAll();
        }
      });
    }
  }
});

//# sourceMappingURL=haika-colorpicker.js.map
