var gulp = require('gulp');
var rename = require('gulp-rename');
//var bowerTask = require('gulp-bower-task');
//var connectProxy = require('gulp-connect-proxy');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var copy = require('gulp-copy');
var cssmin = require('gulp-cssmin');
//var jshint = require('gulp-jshint');
var uglify = require('gulp-uglify');
//var esteWatch = require('gulp-este-watch');
//var newer = require('gulp-newer');
//var notify = require('gulp-notify');
var open = require('gulp-open');


//var mainBowerFiles = require('main-bower-files');
//console.log(mainBowerFiles)
//
//gulp.task('bower', function () {
//  return gulp
//    .src(mainBowerFiles())
//    .pipe(gulp.dest('bower_components'))
//  ;
//});

var js_files = [
  "bower_components/fabric/dist/fabric.js",
  "bower_components/Javascript-Undo-Manager/js/undomanager.js",
  "bower_components/seiyria-bootstrap-slider/dist/bootstrap-slider.min.js",
  "bower_components/bootstrap-contextmenu/bootstrap-contextmenu.js",
  "vendor/mousetrap.min.js",
  "vendor/dragdealer/dragdealer.min.js",
  "vendor/graham_scan_js-1.0.2/graham_scan.min.js",
  "vendor/clipper_unminified.js",
  "src/fabric_object/aligning_guidelines.js",
  "src/fabric_object/shelf.js",
  "src/fabric_object/curvedShelf.js",
  "src/fabric_object/beacon.js",
  "src/fabric_object/wall.js",
  "src/fabric_object/floor.js",
  "src/fabric_object/grid.js",
  "src/haika.js",
  "src/haika-io.js",
  "src/haika-geojson.js",
  "src/haika-zoom.js",
  "src/haika-scrollbar.js",
  "src/haika-toolbar.js",
  "src/haika-event.js",
  "src/haika-undo.js",
  "src/haika-property.js",
  "src/haika-html.js"
];


gulp.task('coffee', function () {
  return gulp
    .src('src/*.coffee')
    .pipe(gulp.dest('src/'))
  ;
});
gulp.task('coffee', function () {
  return gulp
    .src('fabric_object/*.coffee')
    .pipe(gulp.dest('src/'))
  ;
});

gulp.task('concat', function () {
  return gulp
    .src(js_files)
    .pipe(concat('all.js'))
    .pipe(gulp.dest('dist'))
  ;
});
//
//
//gulp.task('concat', function () {
//  return gulp
//    .src('bower_components/fabric/dist/fabric.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('bower_components/Javascript-Undo-Manager/js/undomanager.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('bower_components/seiyria-bootstrap-slider/dist/bootstrap-slider.min.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('bower_components/bootstrap-contextmenu/bootstrap-contextmenu.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('vendor/mousetrap.min.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('vendor/dragdealer/dragdealer.min.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('vendor/graham_scan_js-1.0.2/graham_scan.min.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('vendor/clipper_unminified.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/fabric_object/aligning_guidelines.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/fabric_object/shelf.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/fabric_object/curvedShelf.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/fabric_object/beacon.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/fabric_object/wall.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/fabric_object/floor.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/fabric_object/grid.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/haika.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/haika-io.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/haika-geojson.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/haika-zoom.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/haika-scrollbar.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/haika-toolbar.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/haika-event.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/haika-undo.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/haika-property.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('src/haika-html.js')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('dist'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('vendor/dragdealer/dragdealer.css')
//    .pipe(concat('all.js'))
//    .pipe(gulp.dest('css'))
//  ;
//});
//
//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('bower_components/seiyria-bootstrap-slider/dist/css/bootstrap-slider.min.css')
//    .pipe(concat('haika.all.css'))
//    .pipe(gulp.dest('css'))
//  ;
//});

//gulp.task('concat', function () { // WARNING: potential duplicate task
//  return gulp
//    .src('css/haika.css')
//    .pipe(concat('haika.all.css'))
//    .pipe(gulp.dest('css'))
//  ;
//});

gulp.task('cssmin', function () {
  return gulp
    .src('css/haika.all.css')
    .pipe(gulp.dest('css/'))
  ;
});

gulp.task('cssmin', function () { // WARNING: potential duplicate task
  return gulp
    .src('!*.min.css')
    .pipe(gulp.dest('css/'))
  ;
});

gulp.task('uglify', function () {
  return gulp
    .src('dist/haika.all.js')
    .pipe(rename('haika.all.min.js'))
    .pipe(uglify())
    .pipe(gulp.dest('dist'))
  ;
});

gulp.task('default', ["bower","coffee","concat","uglify"]);

