childProcess = require 'child_process'
path         = require 'path'

_ = require 'underscore'


# ---
# target: includes/contributor/lib/utils/_CLIHelpers.md
# ---
# ## `CLIHelpers`
#
# Utilities for handling command line invocation
module.exports = CLIHelpers =

  # ---
  # target: includes/contributor/lib/utils/CLIHelpers/_configureOptimist.md
  # ---
  # ### `configureOptimist`
  #
  # ```coffeescript
  # configureOptimist opts, optionsConfig, projectConfig
  # ```
  #
  # Configure [Optimist][1] to provide two layers of defaults:
  #
  # 1. from the source code
  # 2. from the user's configuration file
  #
  # [1]: https://github.com/substack/node-optimist
  #
  # And make `--help` show the resulting default values, regardless of tier.
  #
  # #### Parameters
  #
  # * `opts`: command line options object resulting from Optimist
  # * `config`: options configuration with source code defaults
  # * `extraDefaults`: options configuration with user's configuration defaults
  #
  # #### Result
  #
  # Command line options object resulting from combining:
  #
  # 1. user command line options
  # 2. user defaults
  # 3. source code defaults
  configureOptimist: (opts, config, extraDefaults) ->
    for optName, optConfig of config
      # First, set up the hard-coded defaults specified as part of `config`.
      #
      # `default` is a reserved name, hence `defaultVal`.
      defaultVal = extraDefaults?[optName] ? optConfig.default

      # Configure the ability to specify reactionary default values,
      # so that the user can inspect the current state of things by
      # tacking on a `--help`.
      defaultVal = defaultVal opts if _.isFunction defaultVal

      # And set it all up with our key as the canonical option name.
      opts.options optName, _(optConfig).extend(default: defaultVal)

  # ---
  # target: includes/contributor/lib/utils/CLIHelpers/_extractArgv.md
  # ---
  # ### `extractArgv`
  #
  # ```coffeescript
  # extractArgv opts, optionsConfig
  # ```
  #
  # Handle generated values specially, as follows.
  #
  # 1. Ensure list-style option values are always arrays, instead of
  # being single values for one-element lists
  # 2. Resolve filesystem paths
  #
  # #### Parameters
  #
  # * `opts`: command line options object resulting from Optimist
  # * `config`: options configuration
  #
  # #### Result
  #
  # `opts.argv` with the preceding transformations applied
  extractArgv: (opts, config) ->
    argv = opts.argv

    # Ensure list-style options always produce arrays. Optimist
    # parsing produces either an individual value or an array.
    for optName, optConfig of config
      if optConfig.type == 'list' and not _.isArray opts.argv[optName]
        argv[optName] = _.compact [ argv[optName] ]

    # Resolve paths
    for optName, optConfig of config
      argv[optName] = path.resolve argv[optName] if optConfig.type == 'path'

    argv

module.exports = CLIHelpers
