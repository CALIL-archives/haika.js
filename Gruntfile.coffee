#Gruntfile.coffee
"use strict"
module.exports = (grunt) ->
  #Gruntの設定
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    bower:
      install:
        options:
          install: true
          copy: false
          cleanTargetDir: false
          cleanBowerDir: false

    concat:
      js:
        options:
          stripBanners: true
          separator: ";"

        src: [
          "bower_components/proj4/dist/proj4.js"
          "bower_components/json-editor/dist/jsoneditor.min.js"
          "bower_components/jquery-mousewheel/jquery.mousewheel.min.js"
          "bower_components/dragdealer/dragdealer.min.js"
          "bower_components/Javascript-Undo-Manager/js/undomanager.js"
          "bower_components/jquery.finger/dist/jquery.finger.min.js"
          "bower_components/bootstrap-slider/bootstrap-slider.js"
          "vendor/sprintf.js"
          "vendor/mousetrap.min.js"
          "vendor/bootstrap-colorselector-0.2.0/js/bootstrap-colorselector.js"
          "vendor/aligning_guidelines.js"
          # "vendor/centering_guidelines.js"
          "vendor/clipper.js"
          "vendor/fabric.js"
          "js/fabric_obiect/shelf.js"
          "js/fabric_obiect/curvedShelf.js"
          "js/fabric_obiect/beacon.js"
          "js/fabric_obiect/wall.js"
          "js/fabric_obiect/floor.js"
          "js/fabric_obiect/grid.js"
          "js/haika.js"
          "js/haika_io_v1.js"
          "js/init.js"
          "js/editor.js"
          "vendor/ol.js"
          "js/map_setting.js"
        ]
        dest: "js/haika.all.js"
        nonull: true

      css:
        src: [
          "bower_components/dragdealer/dragdealer.css"
          "vendor/bootstrap-colorselector-0.2.0/css/bootstrap-colorselector.css"
          "css/bootstrap-slider.css"
          "css/haika.css"
        ]
        dest: "css/haika.all.css"
        nonull: true

    uglify:
      options:
        banner: "/*! <%= pkg.name %> <%= grunt.template.today(\"dd-mm-yyyy\") %> */\n"

      dist:
        files:
          "js/haika.all.min.js": ["js/haika.all.js"]

    #監視: 一個でも変更あったら全部コンパイルし直しててダサし
    watch:
      devel:
        files: ['js/*.coffee', 'css/*.css']
        tasks: ["concat:js", "concat:css", "uglify"]
      options:
        # 死んでも死なないようにする
        nospawn: false
        # 嬉しい
        livereload: false
  # loadNpmTasks
  require('load-grunt-tasks')(grunt);
  # # package.jsonから読み込んでるもの
  # grunt.loadNpmTasks "grunt-contrib-jshint"
  # grunt.loadNpmTasks "grunt-contrib-uglify"
  # grunt.loadNpmTasks "grunt-contrib-concat"
  # grunt.loadNpmTasks "grunt-contrib-copy"
  # grunt.loadNpmTasks "grunt-bower-task"
  grunt.registerTask "default", [
    "bower"
    "concat:js"
    "concat:css"
    "uglify"
  ]
