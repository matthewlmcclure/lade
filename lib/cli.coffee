childProcess = require 'child_process'
fs           = require 'fs'
path         = require 'path'

glob     = require 'glob'
optimist = require 'optimist'

CLIHelpers   = require './utils/cli_helpers'
Logger       = require './utils/logger'
PACKAGE_INFO = require '../package.json'
Project      = require './project'
Utils        = require './utils'


# ---
# target: includes/contributor/lib/_cli.md
# ---
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
    # target: includes/user/cli/_help.md
    # ---
    # `--help`: Command line usage
    help:
      describe: "You're looking at it."
      alias:   ['h', '?']
      type:     'boolean'

    # ---
    # target: includes/user/cli/_glob.md
    # ---
    # `--glob`: A file path or globbing expression that matches files
    # to generate documentation for.
    glob:
      describe: "A file path or globbing expression that matches files to generate documentation for."
      default:  (opts) -> opts.argv._
      type:     'list'

    # ---
    # target: includes/user/cli/_except.md
    # ---
    # `--except`: Glob expression of files to exclude.  Can be
    # specified multiple times.
    except:
      describe: "Glob expression of files to exclude.  Can be specified multiple times."
      alias:    'e'
      type:     'list'

    # ---
    # target: includes/user/cli/_out.md
    # ---
    # `--out`: The directory to place generated documentation,
    # relative to the project root [./doc]
    out:
      describe: "The directory to place generated documentation, relative to the project root."
      alias:    'o'
      default:  './doc'
      type:     'string'

    # ---
    # target: includes/user/cli/_root.md
    # ---
    # `--root`: The root directory of the project.
    root:
      describe: "The root directory of the project."
      alias:    'r'
      default:  '.'
      type:     'path'

    # ---
    # target: includes/user/cli/_languages.md
    # ---
    # `--languages`: Path to language definition file.
    languages:
      describe: "Path to language definition file."
      default:  "#{__dirname}/languages"
      type:     'path'

    # ---
    # target: includes/user/cli/_silent.md
    # ---
    # `--silent`: Output errors only.
    silent:
      describe: "Output errors only."

    # ---
    # target: includes/user/cli/_version.md
    # ---
    # `--version`: Shows you the current version of groc
    version:
      describe: "Shows you the current version of groc (#{PACKAGE_INFO.version})"
      alias:    'v'

    # ---
    # target: includes/user/cli/_verbose.md
    # ---
    # `--verbose`: Output the inner workings of groc to help diagnose issues.
    verbose:
      describe: "Output the inner workings of groc to help diagnose issues."

    # ---
    # target: includes/user/cli/_very_verbose.md
    # ---
    # `--very-verbose`: Hey, you asked for it.
   'very-verbose':
      describe: "Hey, you asked for it."

  # ---
  # target: includes/user/_configuration.md
  # ---
  # ## Configuring groc
  #
  # MlmGroc can configure itself from a file as an alternative to using
  # command-line arguments.
  #
  # Create a `.groc.json` file in your project root, where each key maps
  # to an argument you would pass to the `groc` command.  File names and
  # globs are defined as an array with the key `glob`.  For example:
  #
  # ```json
  # {
  #     "glob": [
  #         "**/*.md",
  #         "**/*.coffee",
  #         ".groc.json",
  #         "package.json"
  #     ],
  #     "except": [
  #         "node_modules/**"
  #     ],
  #     "out": "./doc"
  # }
  # ```
  #
  # If you invoke `groc` without any arguments, it will use your
  # pre-defined configuration.
  projectConfigPath = path.resolve '.groc.json'
  try
    projectConfig = JSON.parse fs.readFileSync projectConfigPath
  catch err
    unless err.code == 'ENOENT' || err.code == 'EBADF'
      console.log opts.help()
      console.log
      Logger.error "Failed to load .groc.json: %s", err.message

      return callback err

  # Configure Optimist to use two layers of default values
  CLIHelpers.configureOptimist opts, optionsConfig, projectConfig

  # Configure the filesystem path prefixes to strip
  opts.default 'strip', []

  # Extract arguments
  argv = CLIHelpers.extractArgv opts, optionsConfig

  # Short-circuit if the user is just checking the version
  return console.log PACKAGE_INFO.version if argv.version

  # Short-circuit if the user is just asking for help
  return console.log opts.help() if argv.help

  # Make a `Project` that refers to the input and output directories
  project = new Project argv.root, argv.out

  # Configure the minimum logging level to emit in the `Project`
  project.log.minLevel = Logger::LEVELS.ERROR if argv.silent
  project.log.minLevel = Logger::LEVELS.DEBUG if argv.verbose
  project.log.minLevel = Logger::LEVELS.TRACE if argv['very-verbose']

  # Configure the path to the language definition file
  project.options.languages = argv.languages

  # Expand the `--glob` expressions into a poor man's set, so that we
  # can easily remove exclusions defined by `--except` before we add
  # the result to the project's file list.
  files = {}
  for globExpression in argv.glob
    files[file] = true for file in glob.sync path.resolve(argv.root, globExpression)

  for globExpression in argv.except
    delete files[file] for file in glob.sync path.resolve(argv.root, globExpression)

  # Configure several properties on a project before generating its
  # documentation.
  project.files = (f for f of files)
  project.stripPrefixes = argv.strip

  project.generate (error) ->
    callback error

# Local Variables:
# coffee-tab-width: 2
# End:
