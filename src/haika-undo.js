$.extend(haika, {
  undo: {
    undoManager: new UndoManager(),
    states: [],
    set_selected: true,
    add: function(id) {
      log('add set');
      return this.undoManager.add({
        undo: (function(_this) {
          return function() {
            var object;
            log('undo add ' + id);
            object = _this.getObject(id);
            log(object);
            return haika.__remove(object);
          };
        })(this),
        redo: (function(_this) {
          return function() {};
        })(this)
      });
    },
    remove: function(object) {
      log('remove set');
      return this.undoManager.add({
        undo: (function(_this) {
          return function() {
            log('undo remove ' + object.id);
            log(object);
            haika.add(object);
            return haika.render();
          };
        })(this),
        redo: (function(_this) {
          return function() {};
        })(this)
      });
    },
    init: function() {
      haika.canvas.on("object:selected", (function(_this) {
        return function(e) {
          var object, originalState;
          object = e.target;
          if (!_this.set_selected) {
            _this.set_selected = true;
            return;
          }
          if (_this.states.length === 0 || object.id !== _this.states[_this.states.length - 1].id) {
            object.saveState();
            originalState = $.extend(true, {}, object.originalState);
            originalState.state_type = 'selected';
            return _this.states.push(originalState);
          }
        };
      })(this));
      haika.canvas.on("selection:cleared", (function(_this) {
        return function(e) {
          var object;
          return object = e.target;
        };
      })(this));
      return haika.canvas.on("object:modified", (function(_this) {
        return function(e) {
          var object, originalState;
          object = e.target;
          object.saveState();
          originalState = $.extend(true, {}, object.originalState);
          originalState.state_type = 'modified';
          _this.states.push(originalState);
          _this.undoManager.add({
            undo: function() {
              var state;
              if (_this.states.length > 0) {
                haika.canvas.deactivateAll();
                state = _this.states[_this.states.length - 2];
                object = _this.getObject(state.id);
                if (object) {
                  _this.setState(object, state);
                  _this.states.pop();
                  if (_this.states[_this.states.length - 1].state_type === 'selected') {
                    _this.states.pop();
                  }
                  _this.set_selected = false;
                  haika.canvas.setActiveObject(object);
                }
                return log(_this.states);
              }
            },
            redo: function() {}
          });
        };
      })(this));
    },
    getObject: function(id) {
      var i, len, o, object, ref;
      object = null;
      ref = haika.canvas.getObjects();
      for (i = 0, len = ref.length; i < len; i++) {
        o = ref[i];
        if (o.id === id) {
          object = o;
          break;
        }
      }
      return object;
    },
    setState: function(object, state) {
      object.setOptions(state);
      return object.setCoords();
    }
  }
});
