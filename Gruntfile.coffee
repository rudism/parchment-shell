module.exports = (grunt) ->
  pkg = require './package.json'
  grunt.initConfig
    pkg: pkg

    coffee:
      compile:
        options:
          join: true
          bare: true
        files: [
          'bin/pshell.js': ['src/**/*.coffee']
        ]

    stylus:
      compile:
        options:
          compress: true
        files: [
          'bin/pshell.css': ['src/**/*.styl']
        ]

    uglify:
      js:
        files:
          'bin/pshell.min.js': [
            'bin/pshell.js'
          ]

    copy:
      static:
        files: [
          expand: true
          flatten: true
          src: ['src/**/*.html']
          dest: 'bin/'
        ]

    watch:
      js:
        files: ['src/**/*.coffee']
        tasks: ['build:js']
      css:
        files: ['src/**/*.styl']
        tasks: ['stylus:compile']
      static:
        files: ['src/**/*.html']
        tasks: ['copy:static']

  for name of pkg.devDependencies when name.substring(0, 6) is 'grunt-'
    grunt.loadNpmTasks name

  grunt.registerTask 'build:js', [
    'coffee:compile'
    'uglify:js'
  ]

  grunt.registerTask 'default', [
    'coffee:compile'
    'uglify:js'
    'stylus:compile'
    'copy:static'
  ]
