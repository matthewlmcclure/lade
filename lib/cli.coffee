# # Command Line Interface

childProcess = require 'child_process'
fs           = require 'fs'
path         = require 'path'

glob     = require 'glob'
optimist = require 'optimist'

CLIHelpers   = require './utils/cli_helpers'
Logger       = require './utils/logger'
PACKAGE_INFO = require '../package.json'
Project      = require './project'
styles       = require './styles'
Utils        = require './utils'


# ## `CLI`
#
# ```javascript
# CLI(process.argv.slice(2), function(error) {
#   if (error) {
#     process.exit(1)
#   }
# })
# ```
#
# Invoke Groc with the given command line arguments
#
# ### Parameters
#
# * `inputArgs`: array of command line arguments
# * `callback`: function to call on completion
#
# ### Result
#
# The result of `project.generate`
module.exports = CLI = (inputArgs, callback) ->
  # Make sure that output doesn't get too comfortable with the user's
  # next shell line.
  actualCallback = callback
  callback = (args...) ->
    console.log ''

    actualCallback args...

  # Use [Optimist](https://github.com/substack/node-optimist) to parse
  # command line arguments, and manage the options.
  opts = optimist inputArgs

  # Leave a good impression with nicely formatted and readable output.
  opts
    # TODO: Fix issue: Wrapping makes optimist fail if any option has
    # a default value too long
    .wrap(80)
    .usage("""
    Usage: groc [options] "lib/**/*.coffee" doc/*.md

    groc accepts lists of files and (quoted) glob expressions to match
    the files you would like to generate documentation for.  Any
    unnamed options are shorthand for --glob arg.

    You can also specify arguments via a configuration file in the
    current directory named .groc.json.  It should contain a mapping
    between option names and their values.  For example:

      TODO: ...
    """)


  # ## CLI Options

  optionsConfig =

    # ---
    # target: includes/cli/_help.md
    # ---
    # `--help`: Command line usage
    help:
      describe: "You're looking at it."
      alias:   ['h', '?']
      type:     'boolean'

    # ---
    # target: includes/cli/_glob.md
    # ---
    # `--glob`: A file path or globbing expression that matches files
    # to generate documentation for.
    glob:
      describe: "A file path or globbing expression that matches files to generate documentation for."
      default:  (opts) -> opts.argv._
      type:     'list'

    # ---
    # target: includes/cli/_except.md
    # ---
    # `--except`: Glob expression of files to exclude.  Can be
    # specified multiple times.
    except:
      describe: "Glob expression of files to exclude.  Can be specified multiple times."
      alias:    'e'
      type:     'list'

    # ---
    # target: includes/cli/_out.md
    # ---
    # `--out`: The directory to place generated documentation,
    # relative to the project root [./doc]
    out:
      describe: "The directory to place generated documentation, relative to the project root."
      alias:    'o'
      default:  './doc'
      type:     'string'

    # ---
    # target: includes/cli/_root.md
    # ---
    # `--root`: The root directory of the project.
    root:
      describe: "The root directory of the project."
      alias:    'r'
      default:  '.'
      type:     'path'

    # ---
    # target: includes/cli/_languages.md
    # ---
    # `--languages`: Path to language definition file.
    languages:
      describe: "Path to language definition file."
      default:  "#{__dirname}/languages"
      type:     'path'

    # ---
    # target: includes/cli/_silent.md
    # ---
    # `--silent`: Output errors only.
    silent:
      describe: "Output errors only."

    # ---
    # target: includes/cli/_version.md
    # ---
    # `--version`: Shows you the current version of groc
    version:
      describe: "Shows you the current version of groc (#{PACKAGE_INFO.version})"
      alias:    'v'

    # ---
    # target: includes/cli/_verbose.md
    # ---
    # `--verbose`: Output the inner workings of groc to help diagnose issues.
    verbose:
      describe: "Output the inner workings of groc to help diagnose issues."

    # ---
    # target: includes/cli/_very_verbose.md
    # ---
    # `--very-verbose`: Hey, you asked for it.
   'very-verbose':
      describe: "Hey, you asked for it."

  # ## Argument processing

  # We treat the values within the current project's `.groc.json` as defaults, so that you can
  # easily override the persisted configuration when testing and tweaking.
  projectConfigPath = path.resolve '.groc.json'
  try
    projectConfig = JSON.parse fs.readFileSync projectConfigPath
  catch err
    unless err.code == 'ENOENT' || err.code == 'EBADF'
      console.log opts.help()
      console.log
      Logger.error "Failed to load .groc.json: %s", err.message

      return callback err

  # We rely on [CLIHelpers.configureOptimist](utils/cli_helpers.html#configureoptimist) to provide
  # the extra options behavior that we require.
  CLIHelpers.configureOptimist opts, optionsConfig, projectConfig
  #} We have one special case that depends on other defaults...

  opts.default 'strip', []
  argv = CLIHelpers.extractArgv opts, optionsConfig
  # If we're in tracing mode, the parsed options are extremely helpful.
  Logger.trace 'argv: %j', argv if argv['very-verbose']

  # Version checks short circuit before our pretty printing begins, since it is
  # one of those things that you might want to reference from other scripts.
  return console.log PACKAGE_INFO.version if argv.version

  # In keeping with our stance on readable output, we don't want it bumping up
  # against the shell execution lines and blurring together; use that whitespace
  # with great gusto!
  console.log ''

  return console.log opts.help() if argv.help

  # ## Project Generation

  # A [Project](project.html) is just a handy way to configure the generation process, and is in
  # charge of kicking that off.
  project = new Project argv.root, argv.out

  # `--silent`, `--verbose` and `--very-verbose` just impact the logging level of the project.
  project.log.minLevel = Logger::LEVELS.ERROR if argv.silent
  project.log.minLevel = Logger::LEVELS.DEBUG if argv.verbose
  project.log.minLevel = Logger::LEVELS.TRACE if argv['very-verbose']

  # Set up project-specific options as we get them.
  project.options.languages = argv.languages

  # We expand the `--glob` expressions into a poor-man's set, so that we can easily remove
  # exclusions defined by `--except` before we add the result to the project's file list.
  files = {}
  for globExpression in argv.glob
    files[file] = true for file in glob.sync path.resolve(argv.root, globExpression)

  for globExpression in argv.except
    delete files[file] for file in glob.sync path.resolve(argv.root, globExpression)

  # There are several properties that we need to configure on a project before we can go ahead and
  # generate its documentation.
  project.files = (f for f of files)
  project.stripPrefixes = argv.strip

  # `Project#generate` can take some options, such as which style to use.  Since we're generating
  # differently depending on whether or not github is enabled, let's set those up now:
  # If a style was passed in, but it isn't registered, try loading a module.
  unless argv.style? and (style = styles[argv.style])?
    try
      style = require(argv.style) require './styles/default'
    catch error

  options =
    style: style

  project.generate options, (error) ->
    callback error

# Local Variables:
# coffee-tab-width: 2
# End:
