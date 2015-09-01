haika.htmlStack.push("<ul class=\"haika-nav\">\n    <li><a href=\"#\" class=\"floor\">床</a></li>\n    <li><a href=\"#\" class=\"wall\">壁</a></li>\n    <li><a href=\"#\" class=\"beacon\">ビーコン</a></li>\n    <li class=\"active\"><a href=\"#\" class=\"shelf\">本棚</a></li>\n</ul>");

haika.eventStack.push(function() {
  return $('.haika-nav a').click(function(e) {
    var tabName;
    e.preventDefault();
    tabName = $(e.target).attr('class');
    haika.toolbar.show(tabName);
    if (tabName === 'beacon') {
      haika.layer = haika.CONST_LAYERS.BEACON;
    }
    if (tabName === 'wall') {
      haika.layer = haika.CONST_LAYERS.WALL;
    }
    if (tabName === 'floor') {
      haika.layer = haika.CONST_LAYERS.FLOOR;
    }
    if (tabName === 'shelf') {
      haika.layer = haika.CONST_LAYERS.SHELF;
    }
    haika.render();
    $('.haika-nav li').removeClass('active');
    return $(this).closest('li').addClass('active');
  });
});
