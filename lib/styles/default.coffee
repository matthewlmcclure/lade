fs   = require 'fs'
path = require 'path'

_            = require 'underscore'
coffeeScript = require 'coffee-script'
fsTools      = require 'fs-tools'
uglifyJs     = require 'uglify-js'
humanize     = require '../utils/humanize'

module.exports = (Base) -> class Default extends Base

  constructor: (args...) ->
    super(args...)

  renderCompleted: (callback) ->
    @log.trace 'styles.Default#renderCompleted(...)'

    super (error) =>
      return error if error
