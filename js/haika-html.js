$.extend(haika, {
  html: function(container) {
    return $(container).html("<div id=\"haika-canvas\" data-toggle=\"context\" data-target=\"#haika-context-menu\">\n  <ul class=\"haika-nav\">\n      <li><a href=\"#\" class=\"floor\">床</a></li>\n      <li><a href=\"#\" class=\"wall\">壁</a></li>\n      <li><a href=\"#\" class=\"beacon\">ビーコン</a></li>\n      <li class=\"active\"><a href=\"#\" class=\"shelf\">本棚</a></li>\n  </ul>\n  <div class=\"haika-header\">\n      <div style=\"margin-top: 5px;\" class=\"pull-left\">\n        <i class=\"fa fa-copy haika-copy btn btn-default\"> copy</i>\n        <i class=\"fa fa-paste haika-paste btn btn-default\"> paste</i>\n        <i class=\"fa fa-undobtn haika-undo btn btn-default\"> undo</i>\n      </div>\n      <div class=\"pull-right\" style=\"margin-top: 2px;\">\n        <span class=\"fullscreen btn btn-default\">\n          <span class=\"glyphicon glyphicon-fullscreen\"></span>\n          fullscreen\n        </span>\n      </div>\n      <div style=\"display:none;\">\n          <input type=\"file\" id=\"file\"/>\n      </div>\n  </div>\n  <div class=\"haika-toolbar-container\">\n    <ul class=\"toolbar-menu\">\n    </ul>\n    <select id=\"fill-color\">\n        <option value=\"1\" data-color=\"#CFE2F3\" selected=\"selected\">lightblue</option>\n    </select>\n    <select id=\"stroke-color\">\n        <option value=\"1\" data-color=\"#000000\" selected=\"selected\">balck</option>\n    </select>\n  </div>\n  <div class=\"haika-buttons\">\n    <span class=\"haika-button haika-full\">\n      <span class=\"glyphicon glyphicon-resize-full\"></span>\n    </span>\n    <span class=\"haika-button haika-zoomin\">\n      <i class=\"fa fa-plus\"></i>\n    </span>\n    <span class=\"haika-button haika-zoomout\">\n      <i class=\"fa fa-minus\"></i>\n    </span>\n  </div>\n  <div  id=\"vertical-scroller\" class=\"content-scroller\">\n    <div class=\"dragdealer\">\n      <div class=\"handle scroller-gray-bar\">\n        <span class=\"value\"><i class=\"fa fa-bars\"></i></span>\n      </div>\n    </div>\n  </div>\n  <div id=\"horizontal-scroller\" class=\"dragdealer\">\n    <div class=\"handle scroller-gray-bar\">\n      <span class=\"value\"><i class=\"fa fa-bars fa-rotate-90\"></i></span>\n    </div>\n  </div>\n  <div class=\"haika-property-panel\">\n    <div class=\"haika-canvas-panel\">\n        <h3>キャンバスのプロパティ</h3>\n        <label for=\"haika-canvas-width\">\n            width: <span id=\"haika-canvas-width\"></span>\n        </label>\n        <label for=\"haika-canvas-height\">\n            height: <span id=\"haika-canvas-height\"></span>\n        </label><br/>\n        <label for=\"haika-canvas-centerX\">\n            centerX: <span id=\"haika-canvas-centerX\"></span>\n        </label>\n        <label for=\"haika-canvas-centerY\">\n            centerY: <span id=\"haika-canvas-centerY\"></span>\n        </label><br/>\n        <label for=\"haika-canvas-bgscale\">\n            bgscale:\n            <input type=\"number\" id=\"haika-canvas-bgscale\" class=\"form-control\" value=\"0\" step=\"0.01\"/>\n        </label><br/>\n        <label for=\"haika-canvas-bgopacity\">\n            bgopacity:\n            <input type=\"number\" id=\"haika-canvas-bgopacity\" class=\"form-control\" value=\"0\" step=\"0.1\"/>\n            <input id=\"haika-bgopacity-slider\" data-slider-id='haika-bgopacity-slider' type=\"text\" data-slider-min=\"0\" data-slider-max=\"1\" data-slider-step=\"0.1\" data-slider-value=\"0.2\"/>\n        </label><br/>\n        <label for=\"haika-bgimg\">\n            背景画像:\n            <input type=\"file\" id=\"haika-bgimg\" class=\"btn btn-default\"/>\n        </label>\n        <br/>\n        <br/>\n        <span class=\"haika-map-setting btn btn-default\">\n          <i class=\"fa fa-map-marker\"></i>\n          地図設定\n        </span>\n        <br/>\n        <br/>\n        <br/>\n        <br/>\n        <span id=\"haika-bgreset\" class=\"btn btn-default\">\n          <i class=\"fa fa-trash\"></i>\n          背景リセット\n        </span>\n        <br/>\n        <br/>\n        <br/>\n        <br/>\n        <span id=\"haika-import\" class=\"btn btn-default\">\n          <i class=\"fa fa-download\"></i>\n          データのインポート\n        </span>\n      </div>\n      <div class=\"haika-object-panel\">\n        <h3>オブジェクトのプロパティ</h3>\n\n        <p>id: <span id=\"haika-object-id\"></span></p>\n\n        <p><i class=\"fa fa-trash-o haika-remove btn btn-default\"> remove</i></p>\n\n        <p><i class=\"fa fa-files-o haika-duplicate btn btn-default\"> duplicate</i></p>\n\n        <p><input type=\"button\" class=\"haika-bringtofront btn btn-default\" value=\"bringToFront \"/></p>\n\n        <div id=\"haika-object-property\"></div>\n      </div>\n      <div class=\"haika-group-panel\">\n          <h3>グループのプロパティ</h3>\n\n          <p><span id=\"haika-group-count\"></span>個のオブジェクトを選択中。</p>\n\n          <p><i class=\"fa fa-trash-o haika-remove btn btn-default\"> remove</i></p>\n\n          <p>\n\n          <div class=\"btn-group\">\n              <i class=\"fa fa-align-left haika-align-left btn btn-default\"></i>\n              <i class=\"fa fa-align-center haika-align-center btn btn-default\"></i>\n              <i class=\"fa fa-align-right haika-align-right btn btn-default\"></i>\n          </div>\n          </p>\n          <p>\n\n          <div class=\"btn-group\">\n              <i class=\"fa fa-align-left fa-rotate-90 haika-align-top btn btn-default\"></i>\n              <i class=\"fa fa-align-center fa-rotate-90 haika-align-vcenter btn btn-default\"></i>\n              <i class=\"fa fa-align-right fa-rotate-90 haika-align-bottom btn btn-default\"></i>\n          </div>\n          </p>\n      </div>\n  </div>\n</div>\n<div id=\"haika-context-menu\">\n  <ul class=\"dropdown-menu\" role=\"menu\">\n    <li>\n      <a class=\"fa fa-copy haika-copy\"> copy</a>\n    </li>\n    <li>\n      <a class=\"fa fa-paste haika-paste\"> paste</a>\n    </li>\n    <li>\n      <a class=\"fa fa-undobtn haika-undo\"> undo</a>\n    </li>\n  </ul>\n</div>");
  }
});

//# sourceMappingURL=haika-html.js.map
