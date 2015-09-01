# HTMLテンプレート
$.extend haika,
  htmlStack: []
  html : (container)->
    $(container).html("""<div id="haika-canvas">#{@htmlStack.join('\n')}</div>""")