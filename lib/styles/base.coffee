fs   = require 'fs'
path = require 'path'

fsTools = require 'fs-tools'

StyleHelpers = require '../utils/style_helpers'
Utils        = require '../utils'


module.exports = class Base
  constructor: (project) ->
    @project = project
    @log     = project.log
    @files   = []
    @outline = {} # Keyed on target path

  renderFile: (data, fileInfo, callback) ->
    @log.trace 'BaseStyle#renderFile(..., %j, ...)', fileInfo

    @files.push fileInfo

    segments = Utils.splitSource data, fileInfo.language,
      requireWhitespaceAfterToken: !!@project.options.requireWhitespaceAfterToken
      allowEmptyLines: !!@project.options.allowEmptyLines

    @log.debug 'Split %s into %d segments', fileInfo.sourcePath, segments.length

    Utils.parseDocTags segments, @project, (error) =>
      if error
        @log.error 'Failed to parse doc tags %s: %s\n', fileInfo.sourcePath, error.message, error.stack
        return callback error

      Utils.markdownDocTags segments, @project, (error) =>
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
    @log.trace 'BaseStyle#renderDocFile(..., %j, ...)', fileInfo

    for segment in segments
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
    @log.trace 'BaseStyle#renderCompleted(...)'

    callback()

# Local Variables:
# coffee-tab-width: 2
# End:
