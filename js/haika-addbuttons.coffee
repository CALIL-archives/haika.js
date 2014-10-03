# オブジェクト追加ボタン

$.extend haika,
  addbuttons:
  # テスト用
    addmany: ->
      y = 0
      while y < 8
        x = 0
        while x < 22
          haika.addObject 200 + 400 * y, 100 + 50 * x, 90
          x++
        y++
      haika.render()
      return

    showAddButtons: (type)->
      $('.toolbar_container ul:first>li').each (i, button)->
        if $(button).attr('type').match(type)
          $(button).show()
        else
          $(button).hide()

$ ->
  addButtons =
    shelf:
      icon: 'square-o'
      title: '一般本棚'
      type: 'shelf'
      eachWidth: 90
      eachHeight: 26
      count: 5
      side: 1
    big_shelf:
      icon: 'square-o'
      title: '大型本棚'
      type: 'shelf'
      eachWidth: 90
      eachHeight: 33
      count: 5
      side: 1
    magazine_shelf:
      icon: 'square-o'
      title: '雑誌本棚'
      type: 'shelf'
      eachWidth: 90
      eachHeight: 45
      count: 5
      side: 1
    kamishibai_shelf:
      icon: 'square-o'
      title: '紙芝居'
      type: 'shelf'
      eachWidth: 90
      eachHeight: 90
      count: 1
      side: 1
    booktrack_shelf:
      icon: 'square-o'
      title: 'ブックトラック'
      type: 'shelf'
      eachWidth: 60
      eachHeight: 40
      count: 1
      side: 1
      angle: 20
    curved_shelf:
      icon: 'dot-circle-o'
      title: '円形本棚'
      type: 'curved_shelf'
      count: 3
      side: 2
    beacon:
      type: 'beacon'
      icon: 'square'
      title: 'ビーコン'
      fill : '#000000'
      stroke : '#0000ee'
    wall:
      type: 'wall'
      icon: 'square'
      title: '壁'
      height_scale: 1
      width_scale: 1
      fill: '#000000'
    floor:
      type: 'floor'
      icon: 'square'
      title: '床'
      height_scale: 1
      width_scale: 1
      fill : ''
  for key, val of addButtons
    # オブジェクト追加ボタンを生成
    html = """<li id="add_#{key}" key="#{key}" type="#{val.type}"><i class="fa fa-#{val.icon}"></i> #{val.title}</li>"""
    $('.toolbar_container ul:first').append(html)
    # 追加ボタンにイベントを設定
    $('#add_' + key).click (e)->
      key = $(e.target).attr('key')
      object = addButtons[key]
      # GeoJSONに不要なプロパティを削除
      delete object.title
      delete object.icon
      haika.addObject(object)
  haika.addbuttons.showAddButtons('shelf')
