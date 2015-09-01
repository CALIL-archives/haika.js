haika.htmlStack.push("<div id=\"haika-context-menu\">\n  <ul class=\"dropdown-menu\" role=\"menu\">\n    <li>\n      <a class=\"fa fa-undobtn haika-undo\"> undo</a>\n    </li>\n    <li role=\"presentation\" class=\"divider\"></li>\n    <li>\n      <a class=\"haika-zoomin\">\n        <i class=\"fa fa-plus\"></i> zoomin\n      </a>\n    </li>\n    <li>\n      <a class=\"haika-zoomout\">\n        <i class=\"fa fa-minus\"></i> zoomout\n      </a>\n    </li>\n    <li role=\"presentation\" class=\"divider\"></li>\n    <li class=\"haika-select-context-menu\">\n      <a class=\"fa fa-copy haika-copy\"> copy</a>\n    </li>\n    <li>\n      <a class=\"fa fa-paste haika-paste\"> paste</a>\n    </li>\n    <li role=\"presentation\" class=\"divider haika-select-context-menu\"></li>\n    <li class=\"haika-select-context-menu\">\n      <a class=\"haika-bringtofront\">bringToFront</a>\n    </li>\n  </ul>\n</div>");

haika.eventStack.push(function() {
  return $('#haika-canvas').contextmenu({
    target: '#haika-context-menu',
    before: function(e, element, target) {
      e.preventDefault();
      if (e.target.tagName !== 'CANVAS') {
        this.closemenu();
        return false;
      }
      if (haika.canvas.getActiveObject()) {
        log('selected');
        $('#haika-context-menu').find('.haika-select-context-menu').show();
      } else {
        log('nonselect');
        $('#haika-context-menu').find('.haika-select-context-menu').hide();
      }
      return true;
    },
    onItem: function(context, e) {}
  });
});
