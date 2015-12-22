# オブジェクト追加ボタン
class ToolBar
  # 初期設定
  constructor: ->
    $('.haika-toolbar-container').show()
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
        fill: '#000000'
        stroke: '#0000ee'
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
        fill: ''
    if not @readOnly
      for key, val of addButtons
        # オブジェクト追加ボタンを生成
        html = """<li id="add_#{key}" key="#{key}" type="#{val.type}"><i class="fa fa-#{val.icon}"></i> #{val.title}</li>"""
        $('.toolbar-menu').append(html)
        # 追加ボタンにイベントを設定
        $('#add_' + key).click (e)->
          key = $(e.target).attr('key')
          object = addButtons[key]
          haika.addObject(object)
    $('.haika-toolbar-container ul:first>li').each (i, button)->
      if $(button).attr('type').match('shelf')
        $(button).show()
      else
        $(button).hide()
  show: (type)->
    $('.haika-toolbar-container ul:first>li').each (i, button)->
      if $(button).attr('type').match(type)
        $(button).show()
      else
        $(button).hide()


haika.plugins.push(ToolBar)

haika.htmlStack.push """
    <ul class="haika-nav">
        <li><a href="#" class="floor">床</a></li>
        <li><a href="#" class="wall">壁</a></li>
        <li><a href="#" class="beacon">ビーコン</a></li>
        <li class="active"><a href="#" class="shelf">本棚</a></li>
    </ul>

<div class="haika-toolbar-container">
  <ul class="toolbar-menu">
  </ul>
</div>
"""