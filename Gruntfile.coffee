"use strict"
module.exports = (grunt) ->
  jsfiles = [
    "bower_components/fabric/dist/fabric.js"
    "bower_components/Javascript-Undo-Manager/js/undomanager.js"
    "bower_components/seiyria-bootstrap-slider/dist/bootstrap-slider.min.js"
    "bower_components/bootstrap-contextmenu/bootstrap-contextmenu.js"
    "vendor/mousetrap.min.js"
    "vendor/bootstrap-colorselector-0.2.0/js/bootstrap-colorselector.js"
    "vendor/clipper.js"
    "vendor/dragdealer/dragdealer.min.js"
    "js/fabric_object/aligning_guidelines.js"
    "js/fabric_object/shelf.js"
    "js/fabric_object/curvedShelf.js"
    "js/fabric_object/beacon.js"
    "js/fabric_object/wall.js"
    "js/fabric_object/floor.js"
    "js/fabric_object/grid.js"
    "js/haika.js"
    "js/haika-io.js"
    "js/haika-geojson.js"
    "js/haika-zoom.js"
    "js/haika-scrollbar.js"
    "js/haika-toolbar.js"
    "js/haika-colorpicker.js"
    "js/haika-event.js"
    "js/haika-undo.js"
    "js/haika-property.js"
    "js/haika-html.js"
  ]
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
      cwd: 'js/fabric_object/',
      src: ['*.coffee'],
      dest: 'js/fabric_object/',
      ext: '.js'
    concat:
      js:
        options:
          stripBanners: true
          separator: ";"

        src: jsfiles
        dest: "js/build/haika.all.js"
        nonull: true

      css:
        src: [
          "vendor/dragdealer/dragdealer.css"
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

  require('load-grunt-tasks')(grunt)
  grunt.registerTask "default", [
    "bower"
    "coffee"
    "concat"
    "uglify"
  ]
