fs   = require 'fs'
path = require 'path'

fsTools = require 'fs-tools'

Utils        = require './utils'


# ---
# target: includes/contributor/lib/_renderer.md
# ---
# ## `Renderer`
#
# A `Renderer` handles rendering extracted documentation to
# destination files.
module.exports = class Renderer
  # ---
  # target: includes/contributor/lib/renderer/_constructor.md
  # ---
  # ### `constructor`
  #
  # ```coffeescript
  # new Renderer project
  # ```
  #
  # Create a new `Renderer` instance.
  #
  # #### Parameters
  #
  # * `project`: a `Project`
  #
  # #### Result
  #
  # A `Renderer` instance
  constructor: (project) ->
    @project = project
    @log     = project.log
    @files   = []
    @outline = {} # Keyed on target path

  # ---
  # target: includes/contributor/lib/renderer/_renderFile.md
  # ---
  # ### `renderFile`
  #
  # ```coffeescript
  # renderFile data, fileInfo, done
  # ```
  #
  # Render given file content.
  #
  # `renderFile` expects that `data` contains output destinations for
  # its corresponding content.
  #
  # #### Parameters
  #
  # * `data`: source file content
  # * `fileInfo`: source file metadata
  # * `callback`: function to call on completion
  #
  # #### Result
  #
  # None
  renderFile: (data, fileInfo, callback) ->
    @log.trace 'Renderer#renderFile(..., %j, ...)', fileInfo

    @files.push fileInfo

    segments = Utils.splitSource data, fileInfo.language

    @log.debug 'Split %s into %d segments', fileInfo.sourcePath, segments.length

    Utils.preprocessComments segments, @project, (error) =>
      @log.debug 'Entering preprocessComments callback'
      if error
        @log.error 'Failed to preprocess %s: %s', fileInfo.sourcePath, error.message
        return callback error

      @renderDocFile segments, fileInfo, callback

  # ---
  # target: includes/contributor/lib/renderer/_renderDocFile.md
  # ---
  # ### `renderDocFile`
  #
  # ```coffeescript
  # renderDocFile segments, fileInfo, callback
  # ```
  #
  # Render given segments of documentation and code.
  #
  # `renderDocFile` expects that `segments` contains output
  # destinations for its corresponding content.
  #
  # #### Parameters
  #
  # * `segments`: array of `Segment` elements
  # * `fileInfo`: source file metadata
  # * `callback`: function to call on completion
  #
  # #### Result
  #
  # None
  renderDocFile: (segments, fileInfo, callback) ->
    @log.trace 'Renderer#renderDocFile(..., %j, ...)', fileInfo

    countFinished = 0
    for segment in segments
      @renderSegment segment, (error) =>
        return callback error if error

        countFinished++
        @log.trace 'Finished %s out of %s segments in %s', countFinished, segments.length, fileInfo.sourcePath
        if countFinished == segments.length
          callback()

  # ---
  # target: includes/contributor/lib/renderer/_renderSegment.md
  # ---
  # ### `renderSegment`
  #
  # ```coffeescript
  # renderSegment segment, callback
  # ```
  #
  # Render given segment of documentation and code.
  #
  # `renderSegment` expects that `segment.targetPath` contains an
  # output destination for its corresponding content.
  #
  # #### Parameters
  #
  # * `segment`: a `Segment`
  # * `callback`: function to call on completion
  #
  # #### Result
  #
  # None
  renderSegment: (segment, callback) ->
    if segment.targetPath != undefined
      docPath = path.resolve @project.outPath, "#{segment.targetPath}"

      @log.trace "Creating directory %s", path.dirname(docPath)

      fsTools.mkdir path.dirname(docPath), '0755', do (segment, docPath) =>
        (error) =>
          if error
            @log.error 'Unable to create directory %s: %s', path.dirname(docPath), error.message
            return callback error

          try
            # TODO: Consider changing plainComments name to simply
            # comments. It is named plainComments to distinguish it
            # from HTML-rendered comments.
            data = segment.plainComments

          catch error
            @log.error 'Rendering documentation for %s failed: %s', docPath, error.message
            # TODO: Consider continuing. The return statement dates from
            # when it was assumed this function was rendering one output
            # file.
            return callback error

          @log.debug 'Writing to docPath: %s, data: %s', docPath, data

          @writeDocFile docPath, data, callback
    else
      callback()

  # ---
  # target: includes/contributor/lib/renderer/_writeDocFile.md
  # ---
  # ### `writeDocFile`
  #
  # ```coffeescript
  # writeDocFile docPath, data, callback
  # ```
  #
  # Write given documentation `data` to `docPath`.
  #
  # #### Parameters
  #
  # * `docPath`: filesystem path to output file
  # * `data`: data to write to output file
  # * `callback`: function to call on completion
  #
  # #### Result
  #
  # None
  writeDocFile: (docPath, data, callback) ->
    fs.writeFile docPath, data, 'utf-8', (error) =>
      if error
        @log.error 'Failed to write documentation file %s: %s', docPath, error.message
        # TODO: Consider continuing. The return statement dates from
        # when it was assumed this function was rendering one output
        # file.
        return callback error

      @log.pass docPath

      callback()

  # ---
  # target: includes/contributor/lib/renderer/_renderCompleted.md
  # ---
  # ### `renderCompleted`
  #
  # ```coffeescript
  # renderCompleted callback
  # ```
  #
  # Indicate rendering completed.
  #
  # #### Parameters
  #
  # * `callback`: function to call on completion
  #
  # #### Result
  #
  # None
  renderCompleted: (callback) ->
    @log.trace 'Renderer#renderCompleted(...)'

    callback()

# Local Variables:
# coffee-tab-width: 2
# End:
