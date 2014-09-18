# 色・カラーピッカーの設定

html = ''
hex = new Array("f", "c", "9", "6", "3", "0")
count = 2
j = 0
while j < 6
  k = 0
  while k < 6
    l = 0
    while l < 6
      hexColor = hex[j] + hex[j] + hex[k] + hex[k] + hex[l] + hex[l]
      html += """<option data-color="##{hexColor}" value="#{count}"></option>"""
      l++
      count++
    k++
  j++
i = 0
while i < 6
  hexColor = hex[i] + hex[i] + hex[i] + hex[i] + hex[i] + hex[i]
  html += """<option data-color="##{hexColor}" value="#{count}"></option>"""
  i++
$('#fill-color').append(html)
$('#stroke-color').append(html)

bind = (func, do_active=true)->
  object = haika.canvas.getActiveObject()
  if object
    func(object)
  group = haika.canvas.getActiveGroup()
  if group
    for object in group.getObjects()
      func(object)
$('#fill-color').colorselector(
  callback: (value, color, title)->
    haika.fillColor = color
    bind (object)->
      object.fill = color
    haika.canvas.renderAll()
)
$('#stroke-color').colorselector(
  callback: (value, color, title)->
    haika.strokeColor = color
    bind (object)->
      object.stroke = color
    haika.canvas.renderAll()
)
