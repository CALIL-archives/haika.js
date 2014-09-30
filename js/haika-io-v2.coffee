# データの保存と読み込み

$.extend haika,
  _api_load_endpoint: '/api/floor/load' #データ読み込みAPIのエンドポイント (定数)
  _api_save_endpoint: '/api/floor/save' #データ保存APIのエンドポイント (定数)

  _dataId: null #編集中のデータのID (外部参照禁止)
  _revision: null #編集中のデータのリビジョン (外部参照禁止)
  _collision: null #衝突検出キー (外部参照禁止)
  _nowSaving: false #保存処理中フラグ(true..保存処理中) (外部参照禁止)
  _autoSaveTimerId: null #自動保存用のタイマーID (外部参照禁止)

  _geojson: {} #編集中のデータのGeoJSON (将来的にhaikaに移動する)


# API経由で開いたデータを閉じる
#
  close: ()->
    @_dataId = null
    @_revision = null
    @_collision = null
    @_geojson = {}
    @objects.length = 0
    @backgroundImage = null


# API経由でデータを開く
#
# @param {Number} id データのID
# @option {Number} id データのリビジョン(省略時は最新)
# @option {Function} success 成功時のコールバック関数
# @option {Function} error(message) エラー時のコールバック関数
#
  openFromApi: (id, revision = null, success = null, error = null) ->
    if @_dataId
      @close() #開いたデータがある場合は閉じる
    if @_nowSaving
      error and error('保存処理中のため読み込めませんでした')
    $.ajax
      url: @_api_load_endpoint
      type: 'POST'
      cache: false
      dataType: 'json'
      data:
        id: id
        revision: revision
      error: ()=>
        error and error('データが読み込めませんでした')
      success: (json)=>
        if json.locked
          # TODO : Read Onlyモードに切り替える
          return error and error('データはロックされています')
        @_dataId = json.id
        @_revision = json.revision
        @_collision = json.collision
        @_geojson = json.data
        @loadFromGeoJson()
        $(@).trigger('haika:load')
        success and success()



# API経由で開いたデータを保存
#
# @option {Function} success 成功時のコールバック関数
# @option {Function} error(message) エラー時のコールバック関数
#
  save: (success = null, error = null) ->
    log 'save'
    @prepareData()
    # 遅延タイマーより先に明示的な保存があった場合はタイマーを解除
    if @_autoSaveTimerId
      clearTimeout(@_autoSaveTimerId)
      @_autoSaveTimerId = null
    # 保存処理中の場合は500ms後に再実行
    if @_nowSaving
      setTimeout =>
        @save(success, error)
      , 500
      return
    @_nowSaving = true
    data =
      id: @_dataId
      revision: @_revision
      collision: @_collision
      data: JSON.stringify(@toGeoJSON())
    $.ajax
      url: @_api_save_endpoint
      type: 'POST'
      data: data
      dataType: 'json'
      success: (json)=>
        @_nowSaving = false
        if not json.success
          error and error(json.message)
          # Todo: コンポーネント内からのalertは撤去する方針
          alert json.message
          location.reload()
          return
        @_revision = json.revision
        @_collision = json.collision
        success and success()
        $(@).trigger('haika:save')
      error: ()=>
        @_nowSaving = false
        error and error('データが保存できませんでした')


# API経由で開いたデータを遅延して保存
#
# @option {Number} delay 遅延時間(ミリ秒)
#
  saveDelay: (delay = 2000) ->
    log 'save-delay'
    @prepareData()
    if @_autoSaveTimerId
      clearTimeout(@_autoSaveTimerId)
      @_autoSaveTimerId = null
    @_autoSaveTimerId = setTimeout =>
      @_autoSaveTimerId = null
      @save()
    , delay