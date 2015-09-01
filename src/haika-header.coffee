haika.htmlStack.push """
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
"""

haika.eventStack.push ->
  $('.haika-copy').click ->
    haika.copy()
  $('.haika-paste').click ->
    haika.paste()
  $('.haika-undo').click ->
    haika.undo.undoManager.undo()
  # フルスクリーンモードボタン
  $('.fullscreen').click ->
    if $('.haika-container')[0].requestFullScreen
      $('.haika-container')[0].requestFullScreen()
    if $('.haika-container')[0].webkitRequestFullScreen
      $('.haika-container')[0].webkitRequestFullScreen()
    if $('.haika-container')[0].mozRequestFullScreen
      $('.haika-container')[0].mozRequestFullScreen()
