var Property;

Property = (function() {
  function Property() {
    haika.canvas.on('object:selected', (function(_this) {
      return function(e) {
        return _this.setPropetyPanel();
      };
    })(this));
    haika.canvas.on('selection:cleared', (function(_this) {
      return function(e) {
        $('.haika-canvas-panel, .haika-object-panel, .haika-group-panel').hide();
        return $('.haika-canvas-panel').show();
      };
    })(this));
  }

  Property.prototype.createPanel = function(object) {
    log('createPanel');
    $('#haika-object-property').html(object.createPropetyPanel());
    return $('#haika-object-property').find('input, select, option').change((function(_this) {
      return function() {
        return _this.savePanel(object);
      };
    })(this));
  };

  Property.prototype.savePanel = function(object) {
    log('savePanel');
    return object.savePropetyPanel($('#haika-object-property'));
  };

  Property.prototype.setPropetyPanel = function(object) {
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
  };

  return Property;

})();

haika.htmlStack.push("<div class=\"haika-property-panel\">\n  <div class=\"haika-canvas-panel\">\n      <h3>キャンバスのプロパティ</h3>\n      <label for=\"haika-canvas-width\">\n          width: <span id=\"haika-canvas-width\"></span>\n      </label>\n      <label for=\"haika-canvas-height\">\n          height: <span id=\"haika-canvas-height\"></span>\n      </label><br/>\n      <label for=\"haika-canvas-centerX\">\n          centerX: <span id=\"haika-canvas-centerX\"></span>\n      </label>\n      <label for=\"haika-canvas-centerY\">\n          centerY: <span id=\"haika-canvas-centerY\"></span>\n      </label><br/>\n      <label for=\"haika-canvas-bgscale\">\n          bgscale:\n          <input type=\"number\" id=\"haika-canvas-bgscale\" class=\"form-control\" value=\"0\" step=\"0.01\"/>\n      </label><br/>\n      <label for=\"haika-canvas-bgopacity\">\n          bgopacity:\n          <input type=\"number\" id=\"haika-canvas-bgopacity\" class=\"form-control\" value=\"0\" step=\"0.1\"/>\n          <input id=\"haika-bgopacity-slider\" data-slider-id='haika-bgopacity-slider' type=\"text\" data-slider-min=\"0\" data-slider-max=\"1\" data-slider-step=\"0.1\" data-slider-value=\"0.2\"/>\n      </label><br/>\n      <label for=\"haika-bgimg\">\n          背景画像:\n          <input type=\"file\" id=\"haika-bgimg\" class=\"btn btn-default\"/>\n      </label>\n      <br/>\n      <br/>\n      <span class=\"haika-map-setting btn btn-default\">\n        <i class=\"fa fa-map-marker\"></i>\n        地図設定\n      </span>\n      <br/>\n      <br/>\n      <br/>\n      <br/>\n      <span id=\"haika-bgreset\" class=\"btn btn-default\">\n        <i class=\"fa fa-trash\"></i>\n        背景リセット\n      </span>\n      <br/>\n      <br/>\n      <br/>\n      <br/>\n      <span id=\"haika-import\" class=\"btn btn-default\">\n        <i class=\"fa fa-download\"></i>\n        データのインポート\n      </span>\n    </div>\n    <div class=\"haika-object-panel\">\n      <h3>オブジェクトのプロパティ</h3>\n\n      <p>id: <span id=\"haika-object-id\"></span></p>\n\n      <i class=\"fa fa-trash-o haika-remove btn btn-default\"> remove</i>\n      <i class=\"fa fa-files-o haika-duplicate btn btn-default\"> duplicate</i>\n      <input type=\"button\" class=\"haika-bringtofront btn btn-default\" value=\"bringToFront \"/>\n      <div id=\"haika-object-property\"></div>\n    </div>\n    <div class=\"haika-group-panel\">\n        <h3>グループのプロパティ</h3>\n\n        <p><span id=\"haika-group-count\"></span>個のオブジェクトを選択中。</p>\n\n        <p><i class=\"fa fa-trash-o haika-remove btn btn-default\"> remove</i></p>\n\n        <p>\n\n        <div class=\"btn-group\">\n            <i class=\"fa fa-align-left haika-align-left btn btn-default\"></i>\n            <i class=\"fa fa-align-center haika-align-center btn btn-default\"></i>\n            <i class=\"fa fa-align-right haika-align-right btn btn-default\"></i>\n        </div>\n        </p>\n        <p>\n\n        <div class=\"btn-group\">\n            <i class=\"fa fa-align-left fa-rotate-90 haika-align-top btn btn-default\"></i>\n            <i class=\"fa fa-align-center fa-rotate-90 haika-align-vcenter btn btn-default\"></i>\n            <i class=\"fa fa-align-right fa-rotate-90 haika-align-bottom btn btn-default\"></i>\n        </div>\n        </p>\n    </div>\n</div>");

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
