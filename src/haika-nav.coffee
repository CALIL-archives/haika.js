haika.htmlStack.push("""
<ul class="haika-nav">
    <li><a href="#" class="floor">床</a></li>
    <li><a href="#" class="wall">壁</a></li>
    <li><a href="#" class="beacon">ビーコン</a></li>
    <li class="active"><a href="#" class="shelf">本棚</a></li>
</ul>
""")

haika.eventStack.push ->
  # レイヤータブ
  $('.haika-nav a').click (e)->
    e.preventDefault()
    tabName= $(e.target).attr('class')
    haika.toolbar.show(tabName)
    if tabName=='beacon'
        haika.layer=haika.CONST_LAYERS.BEACON
    if tabName=='wall'
        haika.layer=haika.CONST_LAYERS.WALL
    if tabName=='floor'
        haika.layer=haika.CONST_LAYERS.FLOOR
    if tabName=='shelf'
        haika.layer=haika.CONST_LAYERS.SHELF
    haika.render()
    $('.haika-nav li').removeClass('active')
    $(this).closest('li').addClass('active')

