module.exports = (grunt) ->
  grunt.initConfig(
    pkg: grunt.file.readJSON("package.json")
    srcDir: "src"
    srcDirScss: "<%= srcDir %>/scss"
    srcDirScripts: "<%= srcDir %>/scripts"
    outputDir: "app"
    cssOutput: "<%= outputDir %>/css"
    jsOutput: "<%= outputDir %>/js"

    clean:
      src: ["<%= outputDir %>", ".sass-cache"]

    compass:
      development:
        options:
          sassDir: "<%= srcDirScss %>"
          cssDir:  "<%= cssOutput %>"
      production:
        options:
          sassDir: "<%= srcDirScss %>"
          cssDir:  "<%= cssOutput %>"

    jade:
      development:
        cwd: "<%= srcDir %>"
        expand: true
        src: ["**/*.jade"]
        dest: "<%= outputDir %>"
        ext: ".html"

      production:
        cwd: "<%= srcDir %>"
        files: [
          expand: false
          src: ["**/*.jade"]
          dest: "<%= outputDir %>"
          ext: ".html"
        ]

    coffee:
      development:
        expand: true
        cwd: "<%= srcDirScripts %>"
        src: ["**/*.coffee"]
        dest: "<%= jsOutput %>"
        ext: ".js"
      production:
        expand: false
        cwd: "<%= srcDirScripts %>"
        src: ["**/*.coffee"]
        dest: "<%= jsOutput %>"
        ext: ".js"
      app:
        expand: true
        cwd: "<%= srcDir %>"
        src: ["main.coffee"]
        dest: "<%= outputDir %>"
        ext: '.js'

    copy:
      main:
        expand: true,
        cwd: 'thirdparty/',
        src: '**/*',
        dest: "<%= outputDir %>"
      package:
        expand: true,
        src: 'package.json',
        dest: "<%= outputDir %>"

    exec:
      run:
        command: "cd app && ../node_modules/.bin/electron ." # run the actual app
  )

  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-compass')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-exec')

  grunt.registerTask('default',    ['clean', 'copy', 'jade:development', 'coffee:development', 'compass:development', 'coffee:app'])
  grunt.registerTask('release',    ['clean', 'copy', 'jade:production',  'coffee:production', 'coffee:app',  'compass:production'])
