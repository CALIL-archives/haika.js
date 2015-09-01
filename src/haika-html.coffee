# HTMLテンプレート
$.extend haika,
  htmlStack: ["""
<ul class="haika-nav">
    <li><a href="#" class="floor">床</a></li>
    <li><a href="#" class="wall">壁</a></li>
    <li><a href="#" class="beacon">ビーコン</a></li>
    <li class="active"><a href="#" class="shelf">本棚</a></li>
</ul>
""","""
<div class="haika-header">
    <div style="margin-top: 5px;" class="pull-left">
      <i class="fa fa-copy haika-copy btn btn-default"> copy</i>
      <i class="fa fa-paste haika-paste btn btn-default"> paste</i>
      <i class="fa fa-undobtn haika-undo btn btn-default"> undo</i>
    </div>
    <div class="pull-right" style="margin-top: 2px;">
      <span class="fullscreen btn btn-default">
        <span class="glyphicon glyphicon-fullscreen"></span>
        fullscreen
      </span>
    </div>
    <div style="display:none;">
        <input type="file" id="file"/>
    </div>
</div>
""","""
<div class="haika-toolbar-container">
  <ul class="toolbar-menu">
  </ul>
</div>
""","""
<div class="haika-buttons">
  <span class="haika-button haika-full">
    <i class="fa fa-arrows"></i>
  </span>
  <span class="haika-button haika-zoomin">
    <i class="fa fa-plus"></i>
  </span>
  <span class="haika-button haika-zoomout">
    <i class="fa fa-minus"></i>
  </span>
</div>
""","""
<div  id="vertical-scroller" class="content-scroller">
  <div class="dragdealer">
    <div class="handle scroller-gray-bar">
    </div>
  </div>
</div>
<div id="horizontal-scroller" class="dragdealer">
  <div class="handle scroller-gray-bar">
  </div>
</div>
""","""
<div style="bottom:0px;right:0px;width:16px;height:16px;background-color:#525252;position:absolute;border:1px solid #777">
</div>
""","""
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
"""]
  html : (container)->
    $(container).html("""<div id="haika-canvas">#{@htmlStack.join('\n')}</div>""")