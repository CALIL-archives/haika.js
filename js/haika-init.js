$.extend(haika, {
  setting: {
    scrollbar_width: $('#vertical-scroller').width(),
    scrollbar_height: $('#horizontal-scroller').height(),
    toolbar_width: $('.toolbar_container').width() + 14,
    property_panel_width: $('.property_panel').width(),
    getWidth: function() {
      return window.innerWidth - this.toolbar_width - this.scrollbar_width - this.property_panel_width - 20;
    },
    getHeight: function() {
      return window.innerHeight - $('.header').height() - this.scrollbar_height;
    },
    start: function() {
      $('.main_container, .canvas_panel').css('width', this.getWidth());
      $('.main_container').css('margin-left', this.toolbar_width);
      $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', this.getHeight());
      $('.toolbar_container,.property_panel').css('height', this.getHeight() + this.scrollbar_height);
      $(window).resize((function(_this) {
        return function() {
          haika.canvas.setWidth(_this.getWidth());
          haika.canvas.setHeight(_this.getHeight());
          $('.main_container, .canvas_panel').css('width', _this.getWidth());
          $('#vertical-scroller, #vertical-scroller .dragdealer').css('height', _this.getHeight());
          $('.toolbar_container,.property_panel').css('height', _this.getHeight() + _this.scrollbar_height);
          return haika.render();
        };
      })(this));
      return haika.init({
        canvas: 'canvas',
        canvas_width: this.getWidth(),
        canvas_height: this.getHeight(),
        max_width: 10000,
        max_height: 10000,
        bgopacity: 0.2,
        bgscale: 4
      });
    }
  }
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

haika.setting.start();

//# sourceMappingURL=haika-init.js.map
