gulp   = require 'gulp'
coffee = require 'gulp-coffee'
uglify = require 'gulp-uglify'
concat = require 'gulp-concat'
rename = require 'gulp-rename'

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

gulp.task 'default', ['compile-coffee', 'concat-js', 'uglify-js']