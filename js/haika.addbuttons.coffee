# オブジェクト追加ボタン
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

