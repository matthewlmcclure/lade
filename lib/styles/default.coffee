fs   = require 'fs'
path = require 'path'

fsTools = require 'fs-tools'

StyleHelpers = require '../utils/style_helpers'
Utils        = require '../utils'


# ---
# target: includes/contributor/lib/styles/_default.md
# ---
# ## `Default`
#
# The default rendering style
module.exports = class Default
  # ---
  # target: includes/contributor/lib/styles/default/_constructor.md
  # ---
  # ### `constructor`
  #
  # ```coffeescript
  # new Default project
  # ```
  #
  # Create a new `Default` instance.
  #
  # #### Parameters
  #
  # * `project`: a `Project`
  #
  # #### Result
  #
  # A `Default` instance
  constructor: (project) ->
    @project = project
    @log     = project.log
    @files   = []
    @outline = {} # Keyed on target path

  # ---
  # target: includes/contributor/lib/styles/default/_renderFile.md
  # ---
  # ### `renderFile`
  #
  # ```coffeescript
  # renderFile data, fileInfo, done
  # ```
  #
  # Render given file content.
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
    @log.trace 'DefaultStyle#renderFile(..., %j, ...)', fileInfo

    @files.push fileInfo

    segments = Utils.splitSource data, fileInfo.language,
      requireWhitespaceAfterToken: !!@project.options.requireWhitespaceAfterToken

    @log.debug 'Split %s into %d segments', fileInfo.sourcePath, segments.length

    Utils.parseDocTags segments, @project, (error) =>
      @log.debug 'Entering parseDocTags callback'
      if error
        @log.error 'Failed to parse doc tags %s: %s\n', fileInfo.sourcePath, error.message, error.stack
        return callback error

      Utils.markdownDocTags segments, @project, (error) =>
        @log.debug 'Entering markdownDocTags callback'
        if error
          @log.error 'Failed to markdown doc tags %s: %s\n', fileInfo.sourcePath, error.message, error.stack
          return callback error

        Utils.markdownComments segments, @project, (error) =>
          @log.debug 'Entering markdownComments callback'
          if error
            @log.error 'Failed to markdown %s: %s', fileInfo.sourcePath, error.message
            return callback error

          # We also prefer to split out solo headers
          segments = StyleHelpers.segmentizeSoloHeaders segments

          @renderDocFile segments, fileInfo, callback

  renderDocFile: (segments, fileInfo, callback) ->
    @log.trace 'DefaultStyle#renderDocFile(..., %j, ...)', fileInfo

    countFinished = 0
    for segment in segments
      @renderSegment segment, (error) =>
        return callback error if error

        countFinished++
        @log.debug 'Finished %s out of %s segments in %s', countFinished, segments.length, fileInfo.sourcePath
        if countFinished == segments.length
          callback()

  renderSegment: (segment, callback) ->
    if segment.targetPath != undefined
      docPath = path.resolve @project.outPath, "#{segment.targetPath}"

      @log.debug "segment.targetPath: %s", segment.targetPath
      @log.debug "Making directory %s", path.dirname(docPath)

      fsTools.mkdir path.dirname(docPath), '0755', do (segment, docPath) =>
        (error) =>
          if error
            @log.error 'Unable to create directory %s: %s', path.dirname(docPath), error.message
            return callback error

          segment.foldMarker         = Utils.trimBlankLines(segment.foldMarker || '')

          try
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

  renderCompleted: (callback) ->
    @log.trace 'DefaultStyle#renderCompleted(...)'

    callback()

# Local Variables:
# coffee-tab-width: 2
# End:
