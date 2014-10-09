$.extend haika,
  event:
    init: ->
      $('.haika-header').show()
      @shortcut()
      @button()
      @zoom()
      @etc()

    # ボタン類のイベントバインド
    button: ->

      $(".haika-remove").click ->
        object = haika.canvas.getActiveObject()
        haika.remove()
        if object
          haika.undo.remove(object)
      $(".haika-bringtofront").click ->
        haika.bringToFront()
      $(".haika-duplicate").click ->
        haika.duplicate()
      $(".haika-copy").click ->
        haika.copy()
      $(".haika-paste").click ->
        haika.paste()
      $(".haika-align-left").click ->
        haika.alignLeft()
      $(".haika-align-center").click ->
        haika.alignCenter()
      $(".haika-align-right").click ->
        haika.alignRight()
      $(".haika-align-top").click ->
        haika.alignTop()
      $(".haika-align-vcenter").click ->
        haika.alignVcenter()
      $(".haika-align-bottom").click ->
        haika.alignBottom()

      $('#haika-canvas-bgscale').change ->
        haika.backgroundScaleFactor = parseFloat($(this).val())
        haika.render()
    #    haika.save()

      $('#haika-bgreset').click ->
        haika.setBackgroundUrl('')

      $('#haika-bgopacity-slider').slider
        step: 1
        min: 1
        max: 100
        value: haika.backgroundOpacity * 100
        formatter: (value) ->
          haika.backgroundOpacity = value / 100
          haika.render()
    #      haika.save()
          return value / 100

      #背景画像ボタンクリック時
      $('#haika-bgimg').change (e)->
        files = e.target.files
        if files.length==0
          return
        # IE10以降のみ対応
        data = new FormData()
        data.append 'id', haika._dataId
        data.append 'userfile', files[0]
        $.ajax
          url: 'http://lab.calil.jp/haika_store/upload.php'
          data: data
          cache: false
          contentType: false
          processData: false
          type: 'POST'
          success: (data) ->
            url = 'http://lab.calil.jp/haika_store/image/'+haika._dataId+'_'+files[0].name
            haika.setBackgroundUrl(url)

      $('.haika-undo').click ->
        haika.undo.undoManager.undo()

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
      $(document).unbind("keydown").bind "keydown", (event) ->
        doPrevent = false
        if event.keyCode is 8 or event.keyCode is 46
          d = event.srcElement or event.target
          if (d.tagName.toUpperCase() is "INPUT" and (d.type.toUpperCase() is "TEXT" or d.type.toUpperCase() is "PASSWORD" or d.type.toUpperCase() is "FILE" or d.type.toUpperCase() is "EMAIL")) or d.tagName.toUpperCase() is "TEXTAREA"
            doPrevent = d.readOnly or d.disabled
          else
            doPrevent = true
        if doPrevent
          event.preventDefault()
          haika.remove()
        return

    # ズーム関連
    zoom: ->
      $(".haika-full").click ->
        haika.zoomFull()
      $(".haika-zoomin").click ->
        haika.zoomIn()
      $(".haika-zoomout").click ->
        haika.zoomOut()
      $(".zoomreset").click ->
        haika.setScale 1
      # マウスホイール
      timeout = false
      $('canvas').on 'mousewheel', (event)=>
        if timeout
          return
        else
          timeout = setTimeout ->
              timeout = false
          , 100
        if event.deltaY>0
          haika.zoomIn()
        if event.deltaY<0
          haika.zoomOut()

    # その他
    etc: ->
            # 画面遷移時に保存
      $(window).on 'beforeunload', (event)=>
        haika.render()
        haika.save()
        return

      # レイヤータブ
      $('.haika-nav a').click (e)->
        e.preventDefault()
        tabName= $(e.target).attr('class')
        haika.toolbar.show(tabName)
        if tabName=='beacon'
            haika.layer=haika.CONST_LAYERS.BEACON
        if tabName=='wall'
            haika.layer=haika.CONST_LAYERS.WALL
        if tabName=='floor'
            haika.layer=haika.CONST_LAYERS.FLOOR
        if tabName=='shelf'
            haika.layer=haika.CONST_LAYERS.SHELF
        haika.render()
        $(this).tab('show')

