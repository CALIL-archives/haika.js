fabric.Object.prototype.createPropetyPanel = function() {
  var PropetyPanelHTML, json, prop, val, _ref;
  json = this.getJSONSchema();
  PropetyPanelHTML = '<form class="form-horizontal" role="form">';
  PropetyPanelHTML += "<input type=\"hidden\" prop=\"id\" value=\"" + this.id + "\">";
  _ref = json.properties;
  for (prop in _ref) {
    val = _ref[prop];
    PropetyPanelHTML += "<div class=\"form-group\">\n  <label for=\"haika-object-" + prop + "\" class=\"col-sm-5 control-label\">" + prop + "</label>\n  <div class=\"col-sm-7\">\n    <input type=\"number\" prop=\"" + prop + "\" value=\"" + this[prop] + "\" class=\"form-control " + val.type + "\">\n  </div>\n</div>";
  }
  return PropetyPanelHTML;
};

fabric.Object.prototype.getJSON = function(name) {
  var jsonSchema, key, property, _ref;
  jsonSchema = this.getJSONSchema();
  _ref = jsonSchema.properties;
  for (key in _ref) {
    property = _ref[key];
    if (key === name) {
      return property;
    }
  }
  return {};
};

fabric.Object.prototype.savePropetyPanel = function(propertyPanel) {
  var input, json, jsonSchema, name, value, _i, _len, _ref;
  json = {};
  _ref = propertyPanel.find('input, select, option');
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    input = _ref[_i];
    name = $(input).attr('prop');
    jsonSchema = this.getJSON(name);
    value = parseInt($(input).val());
    if (value) {
      if ((jsonSchema.minimum != null) && value < jsonSchema.minimum) {
        value = jsonSchema.minimum;
      }
      if ((jsonSchema.maximum != null) && value > jsonSchema.maximum) {
        value = jsonSchema.maximum;
      }
      json[name] = value;
    }
  }
  return haika.changeObject(this.id, json);
};

$.extend(haika, {
  property: {
    init: function() {
      haika.canvas.on('object:selected', (function(_this) {
        return function(e) {
          return _this.setPropetyPanel();
        };
      })(this));
      return haika.canvas.on('selection:cleared', (function(_this) {
        return function(e) {
          $('.haika-canvas-panel, .haika-object-panel, .haika-group-panel').hide();
          return $('.haika-canvas-panel').show();
        };
      })(this));
    },
    createPanel: function(object) {
      log('createPanel');
      $('#haika-object-property').html(object.createPropetyPanel());
      return $('#haika-object-property').find('input, select, option').change((function(_this) {
        return function() {
          return _this.savePanel(object);
        };
      })(this));
    },
    savePanel: function(object) {
      log('savePanel');
      return object.savePropetyPanel($('#haika-object-property'));
    },
    setPropetyPanel: function(object) {
      var group, objects;
      log('setPropetyPanel');
      $('.haika-canvas-panel, .haika-object-panel, .haika-group-panel').hide();
      object = haika.canvas.getActiveObject();
      if (object) {
        $('.haika-object-panel').show();
        $('#haika-object-id').html(object.id);
        this.createPanel(object);
        return;
      }
      group = haika.canvas.getActiveGroup();
      if (group) {
        objects = group._objects;
        $('#haika-group-count').html(objects.length);
        $('.haika-group-panel').show();
      }
    }
  }
});

//# sourceMappingURL=haika-property.js.map
