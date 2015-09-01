fabric.Object.prototype.createPropetyPanel = function() {
  var PropetyPanelHTML, json, prop, ref, val;
  json = this.getJSONSchema();
  PropetyPanelHTML = '<form class="form-horizontal" role="form">';
  PropetyPanelHTML += "<input type=\"hidden\" prop=\"id\" value=\"" + this.id + "\">";
  ref = json.properties;
  for (prop in ref) {
    val = ref[prop];
    if (val.type === 'string') {
      PropetyPanelHTML += "<div class=\"form-group\">\n  <label for=\"haika-object-" + prop + "\" class=\"col-sm-5 control-label\">" + prop + "</label>\n  <div class=\"col-sm-7\">\n    <input type=\"text\" prop=\"" + prop + "\" xtype=\"" + val.type + "\" value=\"" + this[prop] + "\" class=\"form-control " + val.type + "\">\n  </div>\n</div>";
    } else {
      PropetyPanelHTML += "<div class=\"form-group\">\n  <label for=\"haika-object-" + prop + "\" class=\"col-sm-5 control-label\">" + prop + "</label>\n  <div class=\"col-sm-7\">\n    <input type=\"number\" prop=\"" + prop + "\" xtype=\"" + val.type + "\" value=\"" + this[prop] + "\" class=\"form-control " + val.type + "\">\n  </div>\n</div>";
    }
  }
  return PropetyPanelHTML;
};

fabric.Object.prototype.getJSON = function(name) {
  var jsonSchema, key, property, ref;
  jsonSchema = this.getJSONSchema();
  ref = jsonSchema.properties;
  for (key in ref) {
    property = ref[key];
    if (key === name) {
      return property;
    }
  }
  return {};
};

fabric.Object.prototype.savePropetyPanel = function(propertyPanel) {
  var i, input, json, jsonSchema, len, name, ref, value, xtype;
  json = {};
  ref = propertyPanel.find('input, select, option');
  for (i = 0, len = ref.length; i < len; i++) {
    input = ref[i];
    name = $(input).attr('prop');
    xtype = $(input).attr('xtype');
    jsonSchema = this.getJSON(name);
    if (xtype !== 'string') {
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
    } else {
      json[name] = $(input).val();
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
