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

        @renderDocTags segments

        if @project.options.highlighter is 'pygments'
          highlightCode = Utils.highlightCodeUsingPygments
        else
          highlightCode = Utils.highlightCodeUsingHighlightJS

        highlightCode segments, fileInfo.language, (error) =>
          if error
            if error.failedHighlights
              for highlight, i in error.failedHighlights
                @log.debug "highlight #{i}:"
                @log.warn   segments[i]?.code.join '\n'
                @log.error  highlight

            @log.error 'Failed to highlight %s as %s: %s', fileInfo.sourcePath, fileInfo.language.name, error.message or error
            return callback error

          Utils.markdownComments segments, @project, (error) =>
            if error
              @log.error 'Failed to markdown %s: %s', fileInfo.sourcePath, error.message
              return callback error

            @outline[fileInfo.targetPath] = StyleHelpers.outlineHeaders segments

            # We also prefer to split out solo headers
            segments = StyleHelpers.segmentizeSoloHeaders segments

            @renderDocFile segments, fileInfo, callback

  # renderDocTags: # THIS METHOD MUST BE DEFINED BY SUBCLASSES

  renderDocFile: (segments, fileInfo, callback) ->
    @log.trace 'BaseStyle#renderDocFile(..., %j, ...)', fileInfo

    throw new Error "@templateFunc must be defined by subclasses!" unless @templateFunc

    for segment in segments
      docPath = path.resolve @project.outPath, "#{segment.targetPath}.md"

      @log.debug "segment.targetPath: %s", segment.targetPath
      @log.debug "Making directory %s", path.dirname(docPath)

      fsTools.mkdir path.dirname(docPath), '0755', do (segment, docPath) =>
        (error) =>
          if error
            @log.error 'Unable to create directory %s: %s', path.dirname(docPath), error.message
            return callback error

          segment.markdownedComments = Utils.trimBlankLines segment.markdownedComments
          segment.highlightedCode    = Utils.trimBlankLines segment.highlightedCode
          segment.foldMarker         = Utils.trimBlankLines(segment.foldMarker || '')

          templateContext =
            project:     @project
            segments:    [segment]
            pageTitle:   segment.pageTitle
            sourcePath:  fileInfo.sourcePath
            targetPath:  segment.targetPath
            projectPath: fileInfo.projectPath

          # How many levels deep are we?
          pathChunks = path.dirname(templateContext.targetPath).split(/[\/\\]/)
          if pathChunks.length == 1 && pathChunks[0] == '.'
            templateContext.relativeRoot = ''
          else
            templateContext.relativeRoot = "#{pathChunks.map(-> '..').join '/'}/"

          try
            data = @templateFunc templateContext

          catch error
            @log.error 'Rendering documentation template for %s failed: %s', docPath, error.message
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

    @tableOfContents = StyleHelpers.buildTableOfContents @files, @outline

    callback()

# Local Variables:
# coffee-tab-width: 2
# End:
