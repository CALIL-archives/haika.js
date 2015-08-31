gulp        = require 'gulp'
coffee      = require 'gulp-coffee'
uglify      = require 'gulp-uglify'
concat      = require 'gulp-concat'
rename      = require 'gulp-rename'
cssmin      = require 'gulp-cssmin'
browserSync = require 'browser-sync'

# CofeeScriptのコンパイル
gulp.task 'compile-coffee', () ->
    gulp.src 'src/**/*.coffee'
        .pipe coffee()
        .pipe gulp.dest 'src/'


js_files = [
  "bower_components/fabric/dist/fabric.js"
  "bower_components/Javascript-Undo-Manager/lib/undomanager.js"
  "bower_components/seiyria-bootstrap-slider/dist/bootstrap-slider.min.js"
  "bower_components/bootstrap-contextmenu/bootstrap-contextmenu.js"
  "vendor/mousetrap.min.js"
  "vendor/dragdealer/dragdealer.js"
  "vendor/graham_scan_js-1.0.2/src/graham_scan.js"
  "vendor/clipper_unminified.js"
]

# Javascriptの結合
gulp.task 'concat-js', () ->
    gulp.src js_files.concat ['src/**/*.js', '!src/extra/']
        .pipe concat('haika.all.js')
        .pipe gulp.dest 'dist/'

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
]

# CSSの結合
gulp.task 'concat-css', () ->
    gulp.src css_files
        .pipe concat('css/haika.all.css')
        .pipe gulp.dest 'dist/'

# CSSの圧縮
gulp.task 'minify-css', () ->
    gulp.src 'css/haika.all.css'
        .pipe cssmin()
        .pipe rename extname: '.min.css'
        .pipe gulp.dest 'css/'
        .pipe browserSync.reload(stream: true, once: true)


# BrowserSync
# http://www.browsersync.io/docs/options/
gulp.task 'browserSync', ->
  browserSync.init(null, {
    notify: true,
#    proxy: 'localhost:8888'
    server:
      baseDir: 'demo/'
    port: 3000
  })

# リロード
gulp.task 'browserSync-reload', ->
  browserSync.reload()


# JS, CSSのタスクをまとめる
gulp.task 'build-js',  ['compile-coffee', 'concat-js', 'uglify-js']
gulp.task 'build-css', ['concat-css', 'minify-css']

# gulpコマンドの設定
gulp.task 'default', [
  'build-js'
  'build-css'
  'browserSync'
], ->
  # ファイル変更でタスクを実行
  gulp.watch 'demo/*.html', ['browserSync-reload']
  gulp.watch 'src/**/*.coffee', ['build-js']
  gulp.watch css_files, ['build-css']


