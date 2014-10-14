// Generated by CoffeeScript 1.8.0
"use strict";
module.exports = function(grunt) {
  var jsfiles, proxySnippet;
  proxySnippet = require("grunt-connect-proxy/lib/utils").proxyRequest;
  jsfiles = ["bower_components/fabric/dist/fabric.js", "bower_components/proj4/dist/proj4.js", "bower_components/jquery-mousewheel/jquery.mousewheel.min.js", "bower_components/dragdealer/dragdealer.min.js", "bower_components/Javascript-Undo-Manager/js/undomanager.js", "bower_components/seiyria-bootstrap-slider/dist/bootstrap-slider.min.js", "vendor/mousetrap.min.js", "vendor/bootstrap-colorselector-0.2.0/js/bootstrap-colorselector.js", "vendor/clipper.js", "js/fabric_obiect/aligning_guidelines.js", "js/fabric_obiect/shelf.js", "js/fabric_obiect/curvedShelf.js", "js/fabric_obiect/beacon.js", "js/fabric_obiect/wall.js", "js/fabric_obiect/floor.js", "js/fabric_obiect/grid.js", "js/haika.js", "js/haika-io.js", "js/haika-geojson.js", "js/haika-zoom.js", "js/haika-scrollbar.js", "js/haika-toolbar.js", "js/haika-colorpicker.js", "js/haika-event.js", "js/haika-undo.js"];
  grunt.initConfig({
    pkg: grunt.file.readJSON("package.json"),
    bower: {
      install: {
        options: {
          install: true,
          copy: false,
          cleanTargetDir: false,
          cleanBowerDir: false
        }
      }
    },
    coffee: {
      compile: {
        options: {
          sourceMap: true,
          bare: true
        },
        expand: true,
        flatten: true,
        cwd: 'js/',
        src: ['*.coffee'],
        dest: 'js/',
        ext: '.js'
      },
      fabric_object: {
        options: {
          sourceMap: true,
          bare: true
        },
        expand: true,
        flatten: true,
        cwd: 'js/fabric_obiect/',
        src: ['*.coffee'],
        dest: 'js/fabric_obiect/',
        ext: '.js'
      }
    },
    concat: {
      js: {
        options: {
          stripBanners: true,
          separator: ";"
        },
        src: jsfiles,
        dest: "js/build/haika.all.js",
        nonull: true
      },
      css: {
        src: ["bower_components/dragdealer/dragdealer.css", "vendor/bootstrap-colorselector-0.2.0/css/bootstrap-colorselector.css", "bower_components/seiyria-bootstrap-slider/dist/css/bootstrap-slider.min.css", "css/haika.css"],
        dest: "css/haika.all.css",
        nonull: true
      }
    },
    cssmin: {
      minify: {
        expand: true,
        cwd: 'css/',
        src: ['haika.all.css', '!*.min.css'],
        dest: 'css/',
        ext: '.min.css',
        options: {
          noAdvanced: true
        }
      }
    },
    uglify: {
      options: {
        banner: "/*! <%= pkg.name %> <%= grunt.template.today(\"dd-mm-yyyy\") %> */\n"
      },
      dist: {
        files: {
          "js/build/haika.all.min.js": ["js/build/haika.all.js"]
        }
      }
    },
    esteWatch: {
      options: {
        dirs: ['.', 'js/**/', 'css/'],
        livereload: {
          enabled: true,
          extensions: ['js', 'html', 'css'],
          port: 35729
        }
      },
      'coffee': function(path) {
        return ['newer:coffee', 'concat:js', 'notify:complete'];
      },
      'css': function(path) {
        return ['newer:concat:css', 'notify:complete'];
      }
    },
    notify: {
      complete: {
        options: {
          title: 'Compile&Build',
          message: 'Complete'
        }
      }
    },
    connect: {
      server: {
        options: {
          hostname: "localhost",
          port: 9000,
          keepalive: true,
          open: false,
          middleware: function(connect, options) {
            return [proxySnippet];
          }
        },
        proxies: [
          {
            context: "/api",
            host: "localhost",
            port: 9999,
            https: false,
            xforward: false
          }, {
            context: "/",
            host: "localhost",
            port: 64358,
            https: false,
            xforward: false
          }
        ]
      }
    },
    open: {
      delayed: {
        path: "http://localhost:9000/haika.html",
        app: "Google Chrome",
        options: {
          openOn: "serverListening"
        }
      }
    }
  });
  require('load-grunt-tasks')(grunt);
  grunt.registerTask("default", ["bower", "coffee", "concat", "uglify", 'notify:complete']);
  return grunt.registerTask("server", function(target) {
    return grunt.task.run(["configureProxies:server", 'connect:server', "open", "esteWatch"]);
  });
};

//# sourceMappingURL=Gruntfile.js.map
