$.extend haika,
  eventStack: []
  event:
    init: ->
      @shortcut()
      @etc()
      for func in haika.eventStack
        func()

    # ショートカットキー
    shortcut: ->

      cancel_default = (e)->
        if e.preventDefault
          e.preventDefault()
        else
          # internet explorer
          e.returnValue = false;
      Mousetrap.bind 'mod+o', ->
        $('#file').trigger('click')
        return false
      Mousetrap.bind 'mod+c', ->
        haika.copy()
        return false
      Mousetrap.bind 'mod+v', ->
        haika.paste()
        return false
      Mousetrap.bind 'mod+d', (e)->
        cancel_default(e)
        haika.duplicate()
        return false
      Mousetrap.bind 'mod+a', (e)->
        cancel_default(e)
        haika.selectAll()
        return false
      Mousetrap.bind 'mod+z', (e)->
        cancel_default(e)
        haika.undo.undoManager.undo()
        return false
      Mousetrap.bind ['esc', 'escape'], (e)->
        cancel_default(e)
        haika.unselectAll()
        return false
      Mousetrap.bind ['up', 'shift+up'], (e)->
        cancel_default(e)
        haika.up(e)
        return false
      Mousetrap.bind ['down', 'shift+down'], (e)->
        cancel_default(e)
        haika.down(e)
        return false
      Mousetrap.bind ['left', 'shift+left'], (e)->
        cancel_default(e)
        haika.left(e)
        return false
      Mousetrap.bind ['right', 'shift+right'], (e)->
        cancel_default(e)
        haika.right(e)
        return false
      $(document).unbind('keydown').bind 'keydown', (event) ->
        doPrevent = false
        if event.keyCode is 8 or event.keyCode is 46
          d = event.srcElement or event.target
          if (d.tagName.toUpperCase() is 'INPUT' and (d.type.toUpperCase() is 'TEXT' or d.type.toUpperCase() is 'PASSWORD' or d.type.toUpperCase() is 'FILE' or d.type.toUpperCase() is 'EMAIL')) or d.tagName.toUpperCase() is 'TEXTAREA'
            doPrevent = d.readOnly or d.disabled
          else
            doPrevent = true
        if doPrevent
          event.preventDefault()
          haika.remove()
        return

    # その他
    etc: ->
      # 画面遷移時に保存
      $(window).on 'beforeunload', (event)=>
        haika.render()
        haika.save()
        return

