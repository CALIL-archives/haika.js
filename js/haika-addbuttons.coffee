# オブジェクト追加ボタン

# オブジェクトの追加
add = (val)->
  log val
  klass = haika.getClass(val.type)
  object = new klass(
    top: haika.transformTopY_cm2px(haika.centerY)
    left: haika.transformLeftX_cm2px(haika.centerX)
    fill: haika.fillColor
    stroke: haika.strokeColor
    angle: if val.angle? then val.angle else 0
    #lockScalingY: true
  )
  if val.count?
    object.count = val.count
  if val.side?
    object.side = val.side
  if val.type.match(/shelf$/)
    object.eachWidth = val.eachWidth
    object.eachHeight = val.eachHeight
  id = haika.add(object)
  haika.setState(object)
  haika.render()
  undo.add(id)
  $(haika.canvas.getObjects()).each (i, obj)=>
    if obj.id==object.id
      setTimeout ->
        haika.canvas.setActiveObject(haika.canvas.item(i))
        $('.add').blur()
      , 10
#setTimeout(->
  #addmany()
  #add(250, 250)
#, 500)

# テスト用
addmany = ->
  y = 0
  while y < 8
    x = 0
    while x < 22
      add 200 + 400 * y, 100 + 50 * x, 90
      x++
    y++
  haika.render()
  return

$ ->
  addButtons = 
    shelf :
      icon  : 'square-o'
      title : '一般本棚'
      eachWidth: 90
      eachHeight: 26
      count : 5
      side  : 1
    big_shelf :
      icon  : 'square-o'
      title : '大型本棚'
      eachWidth: 90
      eachHeight: 33
      count : 5
      side  : 1
    magazine_shelf :
      icon  : 'square-o'
      title : '雑誌本棚'
      eachWidth: 90
      eachHeight: 45
      count : 5
      side  : 1
    kamishibai_shelf :
      icon  : 'square-o'
      title : '紙芝居'
      eachWidth: 90
      eachHeight: 90
      count : 1
      side  : 1
    booktrack_shelf :
      icon  : 'square-o'
      title : 'ブックトラック'
      eachWidth: 60
      eachHeight: 40
      count : 1
      side  : 1
      angle : 20
    curved_shelf :
      icon  : 'dot-circle-o'
      title : '円形本棚'
      count : 3
      side  : 2
    beacon :
      icon  : 'square'
      title : 'ビーコン'
    wall :
      icon  : 'square'
      title : '壁'
    floor :
      icon  : 'square'
      title : '床'
  for key, val of addButtons
    html = """<li id="add_#{key}" key="#{key}"><i class="fa fa-#{val.icon}"></i> #{val.title}</li>"""
    $('.toolbar_container ul:first').append(html)
    $('#add_'+key).click (e)->
      key =  $(e.target).attr('key')
      object = addButtons[key]
      object.type = key
      add(object)
      haika.render()

