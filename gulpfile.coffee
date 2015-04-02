gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
plumber    = require 'gulp-plumber'

paths =
  src:
    coffee: './public/javascripts'
  dest:
    coffee: './public/javascripts'

gulp.task 'coffee', ()->
  gulp.src ["#{paths.src.coffee}/**/*.coffee"]
  .pipe plumber()
  .pipe coffee
    bare:true
  .pipe gulp.dest "#{paths.src.coffee}"


gulp.task 'watch', () ->
  gulp.watch ["#{paths.src.coffee}/**/*.coffee"], ['coffee']

gulp.task 'default', ['coffee']