haika.htmlStack.push("<div class=\"haika-header\">\n    <div style=\"margin-top: 5px;\" class=\"pull-left\">\n      <i class=\"fa fa-copy haika-copy btn btn-default\"> copy</i>\n      <i class=\"fa fa-paste haika-paste btn btn-default\"> paste</i>\n      <i class=\"fa fa-undobtn haika-undo btn btn-default\"> undo</i>\n    </div>\n    <div class=\"pull-right\" style=\"margin-top: 2px;\">\n      <span class=\"fullscreen btn btn-default\">\n        <span class=\"glyphicon glyphicon-fullscreen\"></span>\n        fullscreen\n      </span>\n    </div>\n    <div style=\"display:none;\">\n        <input type=\"file\" id=\"file\"/>\n    </div>\n</div>");

haika.eventStack.push(function() {
  $('.haika-copy').click(function() {
    return haika.copy();
  });
  $('.haika-paste').click(function() {
    return haika.paste();
  });
  $('.haika-undo').click(function() {
    return haika.undo.undoManager.undo();
  });
  return $('.fullscreen').click(function() {
    if ($('.haika-container')[0].requestFullScreen) {
      $('.haika-container')[0].requestFullScreen();
    }
    if ($('.haika-container')[0].webkitRequestFullScreen) {
      $('.haika-container')[0].webkitRequestFullScreen();
    }
    if ($('.haika-container')[0].mozRequestFullScreen) {
      return $('.haika-container')[0].mozRequestFullScreen();
    }
  });
});
