# HTMLテンプレート
$.extend haika,
  html : (container)->
    $(container).html("""
<div id="haika-canvas">
  <ul class="haika-nav">
      <li><a href="#" class="floor">床</a></li>
      <li><a href="#" class="wall">壁</a></li>
      <li><a href="#" class="beacon">ビーコン</a></li>
      <li class="active"><a href="#" class="shelf">本棚</a></li>
  </ul>
  <div class="haika-header">
      <div style="margin-top: 5px;" class="pull-left">
        <i class="fa fa-copy haika-copy btn btn-default"> copy</i>
        <i class="fa fa-paste haika-paste btn btn-default"> paste</i>
        <i class="fa fa-undobtn haika-undo btn btn-default"> undo</i>
      </div>
      <div class="pull-right" style="margin-top: 2px;">
        <span class="fullscreen btn btn-default">
          <span class="glyphicon glyphicon-fullscreen"></span>
          fullscreen
        </span>
      </div>
      <div style="display:none;">
          <input type="file" id="file"/>
      </div>
  </div>
  <div class="haika-toolbar-container">
    <ul class="toolbar-menu">
    </ul>
    <select id="fill-color">
        <option value="1" data-color="#CFE2F3" selected="selected">lightblue</option>
    </select>
    <select id="stroke-color">
        <option value="1" data-color="#000000" selected="selected">balck</option>
    </select>
  </div>
  <div class="haika-buttons">
    <span class="haika-button haika-full">
      <span class="glyphicon glyphicon-resize-full"></span>
    </span>
    <span class="haika-button haika-zoomin">
      <i class="fa fa-plus"></i>
    </span>
    <span class="haika-button haika-zoomout">
      <i class="fa fa-minus"></i>
    </span>
  </div>
  <div  id="vertical-scroller" class="content-scroller">
    <div class="dragdealer">
      <div class="handle scroller-gray-bar">
        <span class="value"><i class="fa fa-bars"></i></span>
      </div>
    </div>
  </div>
  <div id="horizontal-scroller" class="dragdealer">
    <div class="handle scroller-gray-bar">
      <span class="value"><i class="fa fa-bars fa-rotate-90"></i></span>
    </div>
  </div>
  <div class="haika-property-panel">
    <div class="haika-canvas-panel">
        <h3>キャンバスのプロパティ</h3>
        <label for="haika-canvas-width">
            width: <span id="haika-canvas-width"></span>
        </label>
        <label for="haika-canvas-height">
            height: <span id="haika-canvas-height"></span>
        </label><br/>
        <label for="haika-canvas-centerX">
            centerX: <span id="haika-canvas-centerX"></span>
        </label>
        <label for="haika-canvas-centerY">
            centerY: <span id="haika-canvas-centerY"></span>
        </label><br/>
        <label for="haika-canvas-bgscale">
            bgscale:
            <input type="number" id="haika-canvas-bgscale" class="form-control" value="0" step="0.01"/>
        </label><br/>
        <label for="haika-canvas-bgopacity">
            bgopacity:
            <input type="number" id="haika-canvas-bgopacity" class="form-control" value="0" step="0.1"/>
            <input id="haika-bgopacity-slider" data-slider-id='haika-bgopacity-slider' type="text" data-slider-min="0" data-slider-max="1" data-slider-step="0.1" data-slider-value="0.2"/>
        </label><br/>
        <label for="haika-bgimg">
            背景画像:
            <input type="file" id="haika-bgimg" class="btn btn-default"/>
        </label>
        <br/>
        <br/>
        <span class="haika-map-setting btn btn-default">
          <i class="fa fa-map-marker"></i>
          地図設定
        </span>
        <br/>
        <br/>
        <br/>
        <br/>
        <span id="haika-bgreset" class="btn btn-default">
          <i class="fa fa-trash"></i>
          背景リセット
        </span>
        <br/>
        <br/>
        <br/>
        <br/>
        <span id="haika-import" class="btn btn-default">
          <i class="fa fa-download"></i>
          データのインポート
        </span>
      </div>
      <div class="haika-object-panel">
        <h3>オブジェクトのプロパティ</h3>

        <p>id: <span id="haika-object-id"></span></p>

        <p><i class="fa fa-trash-o haika-remove btn btn-default"> remove</i></p>

        <p><i class="fa fa-files-o haika-duplicate btn btn-default"> duplicate</i></p>

        <p><input type="button" class="haika-bringtofront btn btn-default" value="bringToFront "/></p>

        <div id="haika-object-property"></div>
      </div>
      <div class="haika-group-panel">
          <h3>グループのプロパティ</h3>

          <p><span id="haika-group-count"></span>個のオブジェクトを選択中。</p>

          <p><i class="fa fa-trash-o haika-remove btn btn-default"> remove</i></p>

          <p>

          <div class="btn-group">
              <i class="fa fa-align-left haika-align-left btn btn-default"></i>
              <i class="fa fa-align-center haika-align-center btn btn-default"></i>
              <i class="fa fa-align-right haika-align-right btn btn-default"></i>
          </div>
          </p>
          <p>

          <div class="btn-group">
              <i class="fa fa-align-left fa-rotate-90 haika-align-top btn btn-default"></i>
              <i class="fa fa-align-center fa-rotate-90 haika-align-vcenter btn btn-default"></i>
              <i class="fa fa-align-right fa-rotate-90 haika-align-bottom btn btn-default"></i>
          </div>
          </p>
      </div>
  </div>
</div>
""")