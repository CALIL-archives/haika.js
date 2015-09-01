# 右クリックメニュー

haika.htmlStack.push """
<div id="haika-context-menu">
  <ul class="dropdown-menu" role="menu">
    <li>
      <a class="fa fa-undobtn haika-undo"> undo</a>
    </li>
    <li role="presentation" class="divider"></li>
    <li>
      <a class="haika-zoomin">
        <i class="fa fa-plus"></i> zoomin
      </a>
    </li>
    <li>
      <a class="haika-zoomout">
        <i class="fa fa-minus"></i> zoomout
      </a>
    </li>
    <li role="presentation" class="divider"></li>
    <li class="haika-select-context-menu">
      <a class="fa fa-copy haika-copy"> copy</a>
    </li>
    <li>
      <a class="fa fa-paste haika-paste"> paste</a>
    </li>
    <li role="presentation" class="divider haika-select-context-menu"></li>
    <li class="haika-select-context-menu">
      <a class="haika-bringtofront">bringToFront</a>
    </li>
  </ul>
</div>
"""

haika.eventStack.push ->
  $('#haika-canvas').contextmenu(
    target: '#haika-context-menu'
    before: (e, element, target) ->
      e.preventDefault()
      # Canvas上か？
      if e.target.tagName != 'CANVAS'
        @closemenu()
        return false
      # 選択中か？
      if haika.canvas.getActiveObject()
        log 'selected'
        $('#haika-context-menu').find('.haika-select-context-menu').show()
      else
        log 'nonselect'
        $('#haika-context-menu').find('.haika-select-context-menu').hide()
      return true
    onItem: (context, e) ->
      return
  )
