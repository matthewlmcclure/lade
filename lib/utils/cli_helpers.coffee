childProcess = require 'child_process'
path         = require 'path'

_ = require 'underscore'


# # Command Line Helpers
module.exports = CLIHelpers =

  # ## configureOptimist

  # [Optimist](https://github.com/substack/node-optimist) fails to provide a few conveniences, so we
  # layer on a little bit of additional structure when defining our options.
  configureOptimist: (opts, config, extraDefaults) ->
    for optName, optConfig of config
      # * We support two tiers of default values.  First, we set up the hard-coded defaults specified
      #   as part of `config`.
      #
      # Also, `default` is a reserved name, hence `defaultVal`.
      defaultVal = extraDefaults?[optName] ? optConfig.default

      # * We also want the ability to specify reactionary default values, so that the user can
      #   inspect the current state of things by tacking on a `--help`.
      defaultVal = defaultVal opts if _.isFunction defaultVal

      # And set it all up with our key as the canonical option name.
      opts.options optName, _(optConfig).extend(default: defaultVal)

  # ## extractArgv

  # In addition to the extended configuration that we desire, we also want special handling for
  # generated values:
  extractArgv: (opts, config) ->
    argv = opts.argv

    # * With regular optimist parsing, you either get an individual value or an array.  For
    #   list-style options, we always want an array.
    for optName, optConfig of config
      if optConfig.type == 'list' and not _.isArray opts.argv[optName]
        argv[optName] = _.compact [ argv[optName] ]

    # * It's also handy to auto-resolve paths.
    for optName, optConfig of config
      argv[optName] = path.resolve argv[optName] if optConfig.type == 'path'

    argv

module.exports = CLIHelpers
