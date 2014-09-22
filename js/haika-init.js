var getHeight, getWidth, property_panel_width, scrollbar_height, scrollbar_width, toolbar_width;

scrollbar_width = $('#vertical-scroller').width();

scrollbar_height = $('#horizontal-scroller').height();

toolbar_width = $('.toolbar_container').width() + 14;

property_panel_width = $('.property_panel').width();

getWidth = function() {
  return window.innerWidth - toolbar_width - scrollbar_width - property_panel_width - 20;
};

getHeight = function() {
  return window.innerHeight - $('.header').height() - scrollbar_height;
};

$('.main_container, .canvas_panel').css('width', getWidth());

$('.main_container').css('margin-left', toolbar_width);

$('#vertical-scroller, #vertical-scroller .dragdealer').css('height', getHeight());

$('.toolbar_container,.property_panel').css('height', getHeight() + scrollbar_height);

$(window).resize(function() {
  haika.canvas.setWidth(getWidth());
  log(getWidth());
  haika.canvas.setHeight(getHeight());
  $('.main_container, .canvas_panel').css('width', getWidth());
  $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', getHeight());
  $('.toolbar_container,.property_panel').css('height', getHeight() + scrollbar_height);
  return haika.render();
});

haika.init({
  canvas: 'canvas',
  canvas_width: getWidth(),
  canvas_height: getHeight(),
  max_width: 10000,
  max_height: 10000,
  bgopacity: 0.2,
  bgscale: 4
});

$(function() {
  return $('.nav-tabs a').click(function(e) {
    e.preventDefault();
    haika.state = $(e.target).attr('class');
    haika.render();
    showAddButtons(haika.state);
    return $(this).tab('show');
  });
});

//# sourceMappingURL=haika-init.js.map
