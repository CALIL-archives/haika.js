// Generated by CoffeeScript 1.8.0
$.extend(haika, {
  _api_load_endpoint: '/api/floor/load',
  _api_save_endpoint: '/api/floor/save',
  _dataId: null,
  _revision: null,
  _collision: null,
  _nowSaving: false,
  _autoSaveTimerId: null,
  close: function() {
    this._dataId = null;
    this._revision = null;
    this._collision = null;
    this._geojson = {};
    this.objects.length = 0;
    return this.backgroundImage = null;
  },
  openFromApi: function(id, option) {
    if (this._dataId) {
      this.close();
    }
    if (this._nowSaving) {
      option.error && option.error('保存処理中のため読み込めませんでした');
    }
    return $.ajax({
      url: this._api_load_endpoint,
      type: 'POST',
      cache: false,
      dataType: 'json',
      data: {
        id: id,
        revision: option.revision
      },
      error: (function(_this) {
        return function() {
          return error && error('データが読み込めませんでした');
        };
      })(this),
      success: (function(_this) {
        return function(json) {
          if (json.locked) {
            return option.error && option.error('データはロックされています');
          }
          _this._dataId = json.id;
          _this._revision = json.revision;
          _this._collision = json.collision;
          _this._geojson = json.data;
          _this.loadFromGeoJson();
          $(_this).trigger('haika:load');
          return option.success && option.success();
        };
      })(this)
    });
  },
  save: function(success, error) {
    var data;
    if (success == null) {
      success = null;
    }
    if (error == null) {
      error = null;
    }
    log('save');
    this.prepareData();
    if (this._autoSaveTimerId) {
      clearTimeout(this._autoSaveTimerId);
      this._autoSaveTimerId = null;
    }
    if (this._nowSaving) {
      setTimeout((function(_this) {
        return function() {
          return _this.save(success, error);
        };
      })(this), 500);
      return;
    }
    this._nowSaving = true;
    data = {
      id: this._dataId,
      revision: this._revision,
      collision: this._collision,
      data: JSON.stringify(this.toGeoJSON())
    };
    return $.ajax({
      url: this._api_save_endpoint,
      type: 'POST',
      data: data,
      dataType: 'json',
      success: (function(_this) {
        return function(json) {
          _this._nowSaving = false;
          if (!json.success) {
            error && error(json.message);
            alert(json.message);
            return;
          }
          _this._revision = json.revision;
          _this._collision = json.collision;
          success && success();
          return $(_this).trigger('haika:save');
        };
      })(this),
      error: (function(_this) {
        return function() {
          _this._nowSaving = false;
          return error && error('データが保存できませんでした');
        };
      })(this)
    });
  },
  saveDelay: function(delay) {
    if (delay == null) {
      delay = 2000;
    }
    log('save-delay');
    this.prepareData();
    if (this._autoSaveTimerId) {
      clearTimeout(this._autoSaveTimerId);
      this._autoSaveTimerId = null;
    }
    return this._autoSaveTimerId = setTimeout((function(_this) {
      return function() {
        _this._autoSaveTimerId = null;
        return _this.save();
      };
    })(this), delay);
  }
});

//# sourceMappingURL=haika-io.js.map
