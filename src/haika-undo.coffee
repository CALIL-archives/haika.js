# Undo
$.extend haika, 
  undo :
    undoManager : new UndoManager()
    states : []
    set_selected : true
    add : (id)->
      log 'add set'
      @undoManager.add
        undo: =>
          log 'undo add '+id
          object = @getObject(id)
          log object
          haika.__remove(object)
  #        haika.save()
  #        haika.render()
        redo: =>
    remove : (object)->
      log 'remove set'
      @undoManager.add
        undo: =>
          log 'undo remove '+object.id
          log object
          haika.add(object)
          haika.render()
        redo: =>
    init : ->
      haika.canvas.on "object:selected", (e) =>
        object = e.target
  #      console.log "object:selected"
        if not @set_selected
          @set_selected = true
          return
        if @states.length==0 or object.id!=@states[@states.length-1].id
          object.saveState()
          originalState = $.extend(true, {}, object.originalState)
          originalState.state_type = 'selected'
          @states.push(originalState)
  #        log @states

      haika.canvas.on "selection:cleared", (e) =>
        object = e.target


      haika.canvas.on "object:modified", (e) =>
        object = e.target
      #  console.log "object:modified"
  #      log object
  #      group = haika.canvas.getActiveGroup()
  #      if group
  #        objects = group.getObjects()
  #        log group.top
  #      else
  #        log object.top
  #        objects = [object]
  #      for object in objects
        object.saveState()
        originalState = $.extend(true, {}, object.originalState)
        originalState.state_type = 'modified'
  #        log originalState
  #        if objects.length>1
  #          originalState.top += group.top
  #          originalState.left += group.left
        @states.push(originalState)
  #      log @states
        @undoManager.add
          undo: =>
      #      log 'undo'
            if @states.length>0
              haika.canvas.deactivateAll()
              state = @states[@states.length-2]
              object = @getObject(state.id)
      #        log object
              if object
                @setState(object, state)
                @states.pop()
  #              log @states[@states.length-1].state_type
                if @states[@states.length-1].state_type=='selected'
                  @states.pop()
      #          haika.canvas.renderAll()
                @set_selected = false
                haika.canvas.setActiveObject(object)
              log @states
          redo: =>
      #      redo()
        return
    getObject : (id)->
      object = null
      for o in haika.canvas.getObjects()
        if o.id==id
          object = o
          break
      return object
    setState : (object, state)->
      object.setOptions state
      object.setCoords()

