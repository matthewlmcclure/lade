fs   = require 'fs'
path = require 'path'

spate = require 'spate'

Logger               = require './utils/logger'
Utils                = require './utils'
Renderer             = require './renderer'


# ---
# target: includes/contributor/lib/_project.md
# ---
# ## `Project`
#
# A `Project` represents a container that refers to input source files
# and output documentation files.
module.exports = class Project
  # ---
  # target: includes/contributor/lib/project/_constructor.md
  # ---
  # ### `constructor`
  #
  # ```coffeescript
  # project = new Project root, out
  # ```
  #
  # Create a new `Project` instance.
  #
  # #### Parameters
  #
  # * `root`: filesystem path of directory containing input source
  #           files
  # * `outPath`: filesystem path of destination directory for output
  #              documentation files
  # * `minLogLevel`: minimum `Logger` level to emit
  #
  # #### Result
  #
  # A `Project` instance
  constructor: (root, outPath, minLogLevel=Logger::INFO) ->
    @options = {}
    @log     = new Logger minLogLevel

    # * Has a single root directory that contains (most of) it.
    @root = path.resolve root
    # * Generally wants documented generated somewhere within its
    #   tree.  We default the output path to be relative to the
    #   project root, unless you pass an absolute path.
    @outPath = path.resolve @root, outPath
    # * Contains a set of files to generate documentation from, source
    #   code or otherwise.
    @files = []

    # TODO: Consider if `stripPrefixes` is obsolete. Remove it if so.

    # * Should strip specific prefixes of a file's path when
    #   generating relative paths for documentation.  For example,
    #   this could be used to ensure that `lib/some/source.file` maps
    #   to `doc/some/source.file` and not `doc/lib/some/source.file`.
    @stripPrefixes = []

  # TODO: Try concurrent file processing.

  # TODO: Simplify by dropping support for old versions of Node.

  # Annoyingly, we seem to be hitting a race condition within Node 0.10's
  # emulation for old-style streams.  For now, we're dropping concurrent doc
  # generation to play it safe.  People are still using groc with 0.6.
  oldNode = process.version.match /v0\.[0-8]\./
  # This is both a performance (over-)optimization and debugging aid.  Instead of spamming the
  # system with file I/O and overhead all at once, we only process a certain number of source files
  # concurrently.  This is similar to what [graceful-fs](https://github.com/isaacs/node-graceful-fs)
  # accomplishes.
  BATCH_SIZE: if oldNode then 10 else 1

  # ---
  # target: includes/contributor/lib/project/_generate.md
  # ---
  # ### `generate`
  #
  # ```coffeescript
  # generate (error) ->
  #   ...
  # ```
  # Extract output documentation from input source files
  #
  # #### Parameters
  #
  # * `callback`: function to call on completion
  #
  # #### Result
  #
  # None
  generate: (callback) ->
    @log.trace 'Project#Generate(...)'
    @log.info 'Generating documentation...'

    # * renderer: The renderer prototype to use.
    renderer = new Renderer @

    # We need to ensure that the project root is a strip prefix so
    # that we properly generate relative paths for our files.  Since
    # strip prefixes are relative, it must be the first prefix, so
    # that they can strip from the remainder.
    @stripPrefixes = [@root + path.sep].concat @stripPrefixes

    files = @files.map (f) -> path.resolve @root, f

    pool = spate.pool (files[k] for k of files), maxConcurrency: @BATCH_SIZE, (currentFile, done) =>
      @log.debug "Processing %s", currentFile

      language = Utils.getLanguage currentFile, @options.languages
      unless language?
        @log.warn '%s is not in a supported language, skipping.', currentFile
        return done()

      fileInfo =
        language:    language
        sourcePath:  currentFile
        projectPath: currentFile.replace ///^#{Utils.regexpEscape @root + path.sep}///, ''

      fs.readFile currentFile, 'utf-8', (error, data) =>
        if error
          @log.error "Failed to process %s: %s", currentFile, error.message
          return callback error

        renderer.renderFile data, fileInfo, done

    pool.exec (error) =>
      return callback error if error

      renderer.renderCompleted (error) =>
        return callback error if error

        @log.info ''
        @log.pass 'Documentation generated'
        callback()

# Local Variables:
# coffee-tab-width: 2
# End:
