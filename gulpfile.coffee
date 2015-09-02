gulp        = require 'gulp'
coffee      = require 'gulp-coffee'
uglify      = require 'gulp-uglify'
concat      = require 'gulp-concat'
rename      = require 'gulp-rename'
cssmin      = require 'gulp-cssmin'
browserSync = require 'browser-sync'
open        = require 'gulp-open'
changed　　　= require 'gulp-changed'

# gulp-plumber コンパイルエラーによる強制停止を防止する
plumber     = require 'gulp-plumber'
notify      = require 'gulp-notify'

url         = require 'url'
proxy       = require 'proxy-middleware'

# 並列、直列処理
runSequence = require 'run-sequence'

# CofeeScriptのコンパイル
gulp.task 'compile-coffee', () ->
    gulp.src 'src/**/*.coffee'
        .pipe(plumber({
          errorHandler: notify.onError "Error: <%= error.message %>"
        }))
        .pipe coffee({bare: true})
        .pipe gulp.dest 'src/'


js_files = [
  "bower_components/fabric/dist/fabric.js"
  "bower_components/Javascript-Undo-Manager/lib/undomanager.js"
  "bower_components/seiyria-bootstrap-slider/dist/bootstrap-slider.min.js"
  "bower_components/bootstrap-contextmenu/bootstrap-contextmenu.js"
  "vendor/mousetrap.min.js"
  "vendor/dragdealer/dragdealer.min.js"
  "vendor/clipper_unminified.js"
  "vendor/graham_scan_js-1.0.2/graham_scan.min.js"
  "src/fabric_object/aligning_guidelines.js"
  "src/fabric_object/shelf.js"
  "src/fabric_object/curvedShelf.js"
  "src/fabric_object/beacon.js"
  "src/fabric_object/wall.js"
  "src/fabric_object/floor.js"
  "src/fabric_object/grid.js"
]

haika_js_files = [
  "src/haika.js"
  "src/haika-io.js"
  "src/haika-geojson.js"
  "src/haika-html.js"
  "src/haika-event.js"
  "src/haika-header.js"
  "src/haika-nav.js"
  "src/haika-zoom.js"
  "src/haika-scrollbar.js"
  "src/haika-toolbar.js"
  "src/haika-undo.js"
  "src/haika-property.js"
  "src/haika-contextmenu.js"
]

# Javascriptの結合
gulp.task 'concat-js', () ->
    gulp.src js_files.concat(haika_js_files)
        .pipe changed 'dist/'
        .pipe concat('haika.all.js')
        .pipe gulp.dest 'dist/'
        .pipe browserSync.reload(stream: true, once: true)


# Javascriptの圧縮
gulp.task 'uglify-js', () ->
    gulp.src 'dist/haika.all.js'
        .pipe uglify preserveComments:'some'
        .pipe rename extname: '.min.js'
        .pipe gulp.dest 'dist/'
        .pipe browserSync.reload(stream: true, once: true)

css_files = [
  "vendor/dragdealer/dragdealer.css"
  "bower_components/seiyria-bootstrap-slider/dist/css/bootstrap-slider.min.css"
  "css/haika.css"
  "css/haika-header.css"
  "css/haika-toolbar.css"
  "css/haika-zoom.css"
  "css/haika-nav.css"
  "css/haika-scrollbar.css"
  "css/haika-property.css"
]

# CSSの結合
gulp.task 'concat-css', () ->
    gulp.src css_files
        .pipe changed 'dist/'
        .pipe concat('haika.all.css')
        .pipe gulp.dest 'dist/'

# CSSの圧縮
gulp.task 'minify-css', () ->
    gulp.src 'dist/haika.all.css'
      .pipe cssmin()
      .pipe rename extname: '.min.css'
      .pipe gulp.dest 'dist/'
      .pipe browserSync.reload(stream: true, once: true)


# BrowserSync
# http://www.browsersync.io/docs/options/
gulp.task 'browserSync', ->
  proxyOptions = url.parse 'https://app.haika.io/api'
  proxyOptions.route = '/api'
  browserSync.init({
    notify: true
    port: 3000
    open: false
#    proxy: 'localhost:8888'
    server:
      baseDir: './'
#      index  : 'demo/index.html'
      routes:
        '/demo': 'demo'
      middleware: [proxy(proxyOptions)]
    port: 3000
  }, ->
    # ローカルのデモを開く
    gulp.src　__filename
      .pipe　open　uri: 'http://localhost:3000/demo/index.html'
  )

# リロード
gulp.task 'browserSync-reload', ->
  browserSync.reload()

# Javascriptライブラリの結合 デモ用
gulp.task 'concat-js-lib', () ->
    gulp.src js_files
        .pipe concat('haika.require.js')
        .pipe gulp.dest 'demo/'

# デモ用 CofeeScriptのコンパイル
gulp.task 'compile-coffee-demo', () ->
    gulp.src 'demo/**/*.coffee'
        .pipe(plumber({
          errorHandler: notify.onError "Error: <%= error.message %>"
        }))
        .pipe coffee({bare: true})
        .pipe gulp.dest 'demo/'
        .pipe browserSync.reload(stream: true, once: true)



# JS, CSSのタスクをまとめる
gulp.task 'build-js',  ->
  runSequence 'compile-coffee', 'concat-js', 'uglify-js'
gulp.task 'build-css', ->
  runSequence 'concat-css', 'minify-css'

# gulpコマンドの設定
gulp.task 'default', ->
  runSequence ['build-js', 'build-css'], 'browserSync', ->
    # ファイル変更でタスクを実行
    gulp.watch 'src/**/*.coffee', ->
      runSequence　'compile-coffee', 'concat-js'
    gulp.watch css_files, ['build-css']
    # デモ用の設定
    gulp.watch 'demo/*.html', ['browserSync-reload']
    gulp.watch 'demo/**/*.coffee', ['compile-coffee-demo']


