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
    coffee:
      compile:
          options:
            sourceMap: true
            bare: true
          expand: true,
          flatten: true,
          cwd: 'js/',
          src: ['*.coffee'],
          dest: 'js/',
          ext: '.js'
       fabric_object:
          options:
            sourceMap: true
            bare: true
          expand: true,
          flatten: true,
          cwd: 'js/fabric_obiect/',
          src: ['*.coffee'],
          dest: 'js/fabric_obiect/',
          ext: '.js'
    concat:
      js:
        options:
          stripBanners: true
          separator: ";"

        src: [
          "bower_components/fabric/dist/fabric.js"
          "bower_components/proj4/dist/proj4.js"
          "bower_components/json-editor/dist/jsoneditor.min.js"
          "bower_components/jquery-mousewheel/jquery.mousewheel.min.js"
          "bower_components/dragdealer/dragdealer.min.js"
          "bower_components/Javascript-Undo-Manager/js/undomanager.js"
          "bower_components/jquery.finger/dist/jquery.finger.min.js"
          "bower_components/seiyria-bootstrap-slider/dist/bootstrap-slider.min.js"
          #"vendor/sprintf.js"
          "vendor/mousetrap.min.js"
          "vendor/bootstrap-colorselector-0.2.0/js/bootstrap-colorselector.js"
          "vendor/aligning_guidelines.js"
          # "vendor/centering_guidelines.js"
          "vendor/clipper.js"
          "js/fabric_obiect/shelf.js"
          "js/fabric_obiect/curvedShelf.js"
          "js/fabric_obiect/beacon.js"
          "js/fabric_obiect/wall.js"
          "js/fabric_obiect/floor.js"
          "js/fabric_obiect/grid.js"
          "js/haika.js"
          "js/haika-io.js"
          "js/haika-geojson.js"
          "js/haika-scrollbar.js"
          "js/haika-addbuttons.js"
          "js/haika-colorpicker.js"
          "js/haika-event.js"
          "js/haika-undo.js"
          "js/haika-editor.js"
          "js/haika-map.js"
          "js/haika-init.js"
        ]
        dest: "js/build/haika.all.js"
        nonull: true

      css:
        src: [
          "bower_components/dragdealer/dragdealer.css"
          "vendor/bootstrap-colorselector-0.2.0/css/bootstrap-colorselector.css"
          "bower_components/seiyria-bootstrap-slider/dist/css/bootstrap-slider.min.css"
          "css/haika.css"
        ]
        dest: "css/haika.all.css"
        nonull: true
    cssmin:
      minify:
        expand: true
        cwd: 'css/'
        src: ['haika.all.css', '!*.min.css']
        dest: 'css/'
        ext: '.min.css'
        options:
          noAdvanced: true
    uglify:
      options:
        banner: "/*! <%= pkg.name %> <%= grunt.template.today(\"dd-mm-yyyy\") %> */\n"

      dist:
        files:
          "js/build/haika.all.min.js": ["js/build/haika.all.js"]

#    watch:
#      devel:
#        files: ['js/*.coffee', 'css/*.css']
#        tasks: ["coffee", "concat:js", "concat:css"]
#      options:
#        nospawn: false
#        livereload: true
    esteWatch:
      options:
          dirs: ['.', 'js/**/', 'css/']
          livereload:
            enabled: true
            extensions: ['js', 'html', 'css']
            port: 35729
      # 更新されたファイルだけコンパイルするように指定する
      'coffee': (path) ->
          ['newer:coffee','concat:js','notify:complete']
      'css': (path) ->
          ['newer:concat:css','notify:complete']
    notify:
      complete:
        options:
          title: 'Compile&Build'
          message: 'Complete'
  # loadNpmTasks
  require('load-grunt-tasks')(grunt);
  # # package.jsonから読み込んでるもの
  # grunt.loadNpmTasks "grunt-contrib-jshint"
  # grunt.loadNpmTasks "grunt-contrib-uglify"
  # grunt.loadNpmTasks "grunt-contrib-concat"
  # grunt.loadNpmTasks "grunt-contrib-copy"
  # grunt.loadNpmTasks "grunt-bower-task"
#  grunt.renameTask('esteWatch', 'watch');
  grunt.registerTask "default", [
    "bower"
    "coffee"
    "concat"
    "cssmin"
    "uglify"
    'notify:complete'
  ]
