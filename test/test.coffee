describe 'mochaのテスト', ->
  it '1 + 1 は2になること', ->
    assert 1 + 1, 2
    return

  it 'failするテスト', ->
    assert.ok false
    return

  it '後で書く'
  it 'haikaオブジェクトはあるか', ->
#    assert typeof haika, 'Object'
    expect(haika).to.be.a('Object')
  it 'haikaのstate値はshelfか', ->
    expect(haika.state).to.eql('shelf')
  it 'haikaのwidth値は800か', ->
    expect(haika.width>600).to.be.ok()