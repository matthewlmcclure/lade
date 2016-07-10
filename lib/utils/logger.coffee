# # groc.Logger

colors = require 'colors'
util = require 'util'

# ---
# target: includes/contributor/lib/utils/_Logger.md
# ---
# ## `Logger`
#
# `Logger` provides logging capabilities
#
# Groc has pretty simple logging needs, and its contributors are
# unaware of a reasonable off-the-shelf solution that fits them
# without being too overbearing.
#
module.exports = class Logger
  # ---
  # target: includes/contributor/lib/utils/Logger/_LEVELS.md
  # ---
  # ### `LEVELS`
  #
  # Groc uses the following output levels, and corresponding log line
  # prefixes, colors, and mapping to `console.log` semantics.
  #
  # Level | Prefix | Color | Console
  # ----- | ------ | ----- | -------
  # TRACE | ∴ | grey | `log`
  # DEBUG | ‡ | grey | `log`
  # INFO |   | black | `log`
  # PASS | ✓ | green | `log`
  # WARN | » | yellow | `error`
  # ERROR | ! | red | `error`
  LEVELS:
    TRACE: 0
    DEBUG: 1
    INFO:  2
    PASS:  2
    WARN:  3
    ERROR: 4

  LEVEL_PREFIXES:
    TRACE: '∴ '
    DEBUG: '‡ '
    INFO:  '  '
    PASS:  '✓ '
    WARN:  '» '
    ERROR: '! '

  LEVEL_COLORS:
    TRACE: 'grey'
    DEBUG: 'grey'
    INFO:  'black'
    PASS:  'green'
    WARN:  'yellow'
    ERROR: 'red'

  LEVEL_STREAMS:
    TRACE: console.log
    DEBUG: console.log
    INFO:  console.log
    PASS:  console.log
    WARN:  console.error
    ERROR: console.error

  # ---
  # target: includes/contributor/lib/utils/Logger/_constructor.md
  # ---
  # ### `constructor`
  #
  # ```coffeescript
  # logger = new Logger minLogLevel
  # ```
  #
  # Create a new Logger object
  #
  # #### Parameters
  #
  # * `minLevel`: minimum log level to emit
  #
  # #### Result
  #
  # A Logger object
  constructor: (minLevel = @LEVELS.INFO) ->
    @minLevel = minLevel

    # ---
    # target: includes/contributor/lib/utils/Logger/_level_functions.md
    # ---
    # ### `trace`
    #
    # ```coffeescript
    # trace 'A detail of interest to a developer relating to %s happened', aThing
    # ```
    #
    # Log given message at `TRACE` level
    #
    # #### Parameters
    #
    # * `args`: variable length argument list: a format string and
    #   corresponding placeholder values
    #
    # #### Result
    #
    # The string emitted to the corresponding stream
    #
    # ### `debug`
    #
    # ```coffeescript
    # debug 'Something of interest to a developer relating to %s happened', aThing
    # ```
    #
    # Log given message at `DEBUG` level
    #
    # #### Parameters
    #
    # * `args`: variable length argument list: a format string and
    #   corresponding placeholder values
    #
    # #### Result
    #
    # The string emitted to the corresponding stream
    #
    # ### `info`
    #
    # ```coffeescript
    # info 'A detail of interest to a user relating to %s happened', aThing
    # ```
    #
    # #### Parameters
    #
    # * `args`: variable length argument list: a format string and
    #   corresponding placeholder values
    #
    # #### Result
    #
    # The string emitted to the corresponding stream
    #
    # ### `pass`
    #
    # ```coffeescript
    # pass 'Something of interest to a user relating to %s happened', aThing
    # ```
    #
    # #### Parameters
    #
    # * `args`: variable length argument list: a format string and
    #   corresponding placeholder values
    #
    # #### Result
    #
    # The string emitted to the corresponding stream
    #
    # ### `warn`
    #
    # ```coffeescript
    # warn 'Something abnormal relating to %s happened', aThing
    # ```
    #
    # #### Parameters
    #
    # * `args`: variable length argument list: a format string and
    #   corresponding placeholder values
    #
    # #### Result
    #
    # The string emitted to the corresponding stream
    #
    # ### `error`
    #
    # ```coffeescript
    # error 'Something failed relating to %s', aThing
    # ```
    #
    # #### Parameters
    #
    # * `args`: variable length argument list: a format string and
    #   corresponding placeholder values
    #
    # #### Result
    #
    # The string emitted to the corresponding stream
    for name of @LEVELS
      do (name) =>
        @[name.toLowerCase()] = (args...) ->
          @emit name, args...

  # ---
  # target: includes/contributor/lib/utils/Logger/_emit.md
  # ---
  # ### `emit`
  #
  # ```coffeescript
  # emit level, args...
  # ```
  #
  # Emit a log message at the given `level`
  #
  # #### Parameters
  #
  # * `levelName`: level at which to emit message given by `args`
  # * `args`: variable length argument list: a format string and
  #   corresponding placeholder values
  #
  # #### Result
  #
  # The string emitted to the corresponding stream
  emit: (levelName, args...) ->
    if @LEVELS[levelName] >= @minLevel
      output = util.format args...

      # * We like nicely indented output
      output = output.split(/\r?\n/).join('\n  ')

      @LEVEL_STREAMS[levelName] colors[@LEVEL_COLORS[levelName]] "#{@LEVEL_PREFIXES[levelName]}#{output}"

      output

# ---
# target: includes/contributor/lib/utils/Logger/_globalLogger.md
# ---
# ### Simple Logging
#
# ```coffeescript
# Logger = require './utils/logger'
# Logger.info 'Logging can be this simple'
# ```
#
# `Logger` provides functions that let a caller log at a given level
# without creating a new `Logger` object.
globalLogger = new Logger Logger::LEVELS.TRACE

for level of globalLogger.LEVELS
  do (level) ->
    Logger[level.toLowerCase()] = (args...) -> globalLogger[level.toLowerCase()] args...
