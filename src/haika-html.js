$.extend(haika, {
  htmlStack: [],
  html: function(container) {
    return $(container).html("<div id=\"haika-canvas\">" + (this.htmlStack.join('\n')) + "</div>");
  }
});
