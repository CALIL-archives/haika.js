$.extend(haika, {
  setting: {
    navbar_height: function() {
      if ($('#navbar').length > 0) {
        return $('#navbar').height() + 45;
      } else {
        return 0;
      }
    },
    sidebar_width: function() {
      if ($('.sidebar-collapse').length > 0) {
        return $('.sidebar-collapse').width() + 45;
      } else {
        return 0;
      }
    },
    scrollbar_width: $('#vertical-scroller').width(),
    scrollbar_height: $('#horizontal-scroller').height(),
    toolbar_width: $('.toolbar_container').width() + 14,
    property_panel_width: $('.property_panel').width(),
    getWidth: function() {
      return window.innerWidth - this.sidebar_width() - this.toolbar_width - this.scrollbar_width - this.property_panel_width - 20;
    },
    getHeight: function() {
      return window.innerHeight - this.navbar_height() - $('.header').height() - this.scrollbar_height;
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
        canvas_id: 'canvas_area',
        canvas_width: this.getWidth(),
        canvas_height: this.getHeight(),
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
    haika.addbuttons.showAddButtons(haika.state);
    return $(this).tab('show');
  });
});

haika.setting.start();

//# sourceMappingURL=haika-init.js.map
