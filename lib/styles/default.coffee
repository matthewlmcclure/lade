fs   = require 'fs'
path = require 'path'

_            = require 'underscore'
coffeeScript = require 'coffee-script'
fsTools      = require 'fs-tools'
jade         = require 'jade'
uglifyJs     = require 'uglify-js'
humanize     = require '../utils/humanize'

module.exports = (Base) -> class Default extends Base

  constructor: (args...) ->
    super(args...)

    @sourceAssets = path.join __dirname, 'default'
 
    templateData  = fs.readFileSync path.join(@sourceAssets, 'docPage.jade'), 'utf-8'
    @templateFunc = jade.compile templateData

  renderCompleted: (callback) ->
    @log.trace 'styles.Default#renderCompleted(...)'

    super (error) =>
      return error if error
