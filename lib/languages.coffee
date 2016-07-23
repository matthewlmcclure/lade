# ---
# target: includes/user/_languages.md
# ---
# ## Source File Types
#
# Lade can extract documentation from the following source file types:
#
# * C
# * C++
# * CSS
# * CSharp
# * Clojure
# * CoffeeScript
# * Go
# * HTML
# * Handlebars
# * Haskell
# * JSON
# * JSP
# * Jade
# * Jake
# * Java
# * JavaScript
# * LESS
# * LaTeX
# * LiveScript
# * Lua
# * Make
# * Markdown
# * Mustache
# * Objective-C
# * PHP
# * Perl
# * Puppet
# * Python
# * Ruby
# * SCSS
# * SQL
# * Sass
# * Shell
# * Swift
# * TypeScript
# * YAML

# ---
# target: includes/contributor/lib/_languages.md
# ---
#
# ## Source File Types
#
# Refer to the user documentation for a list of supported source file
# types. Contributors can configure new source file types in
# `lib/languages.coffee`.
#
# Each configured source file type has the following attributes:
#
# Attribute | Type | Description | Required?
# --------- | ---- | ----------- | ---------
# nameMatchers | list of strings | File name extensions | required
# singleLineComment | list of strings | List of character sequences that introduce a single line comment | optional
# multiLineComment | list of 3 strings | 3-tuple of block comment starting character sequence, intra-block-comment line prefix, ending sequence | optional
# commentsOnly | boolean | Indicates if the source file type contains only comments and no source code | optional
# codeOnly | boolean | Indicates if the source file type contains only source code and no comments | optional
# strictMultiLineEnd | boolean | Indicates if block comments of differing syntaxes can be nested | optional

# TODO: Provide to users the capability to configure new languages via
# JSON or YAML.

# TODO: Consider if strictMultiLineEnd is an unnecessary hack,
# possibly suggestive of problems present in parsing nested block
# comments.

module.exports = LANGUAGES =
  Markdown:
    nameMatchers: ['.md', '.markdown','.mkd', '.mkdn', '.mdown']
    commentsOnly: true

  C:
    nameMatchers:      ['.c', '.h']
    multiLineComment:  ['/*', '*', '*/']
    singleLineComment: ['//']

  CSharp:
    nameMatchers:      ['.cs']
    multiLineComment:  ['/*', '*', '*/']
    singleLineComment: ['//']
    
  CSS:
    nameMatchers:      ['.css']
    multiLineComment:  ['/*', '*', '*/']

  'C++':
    nameMatchers:      ['.cpp', '.hpp', '.c++', '.h++', '.cc', '.hh', '.cxx', '.hxx']
    multiLineComment:  ['/*', '*', '*/']
    singleLineComment: ['//']

  Clojure:
    nameMatchers:      ['.clj', '.cljs']
    singleLineComment: [';;']

  CoffeeScript:
    nameMatchers:      ['.coffee', 'Cakefile']
    # **CoffeScript's multi-line block-comment styles.**

    # - Variant 1:
    #   (Variant 3 is preferred over this syntax, as soon as the pull-request
    #    mentioned below has been merged into coffee-script's codebase.)
    ###* }
     * Tip: use '-' or '+' for bullet-lists instead of '*' to distinguish
     * bullet-lists visually from this kind of block comments.  The preceding
     * whitespaces in the line-matcher and end-matcher are required. Without
     * them this syntax makes no sense, as it is meant to produce comments
     * like the following in compiled javascript:
     *
     *     /**
     *      * A sample comment, having a preceding whitespace per line.
     *      * <= COMBINE THESE TWO CHARS => /
     *
     * (The the final comment-mark above has been TWEAKED to not raise an error)
    ###
    # - Variant 2:
    ### }
    Uses the the below defined syntax, without preceding `#` per line. This is
    the syntax for what the definition is actually meant for !
    ###
    # - Variant 3:
    #   (This syntax produces arkward comments in the compiled javascript, if
    #    the pull-request _“[Format block-comments
    #    better](<https://github.com/jashkenas/coffee-script/pull/3132)”_ has
    #    not been applied to coffee-script's codebase …)
    ### }
    # The block-comment line-matcher `'#'` also works on lines not starting
    # with `'#'`, because we add unmatched lines to the comments once we are
    # in a multi-line comment-block and until we left them …
    ###
    # - Variant 4:
    #   (This definition matches the format used by YUIDoc to parse CoffeeScript
    #   comments)
    multiLineComment  : [
      # Syntax definition for variant 1.
      '###*',   ' *',   ' ###',
      # Syntax definition for variant 2 and 3.
      '###' ,   '#' ,   '###',
      # Syntax definition for variant 4
      '###*',   '#',    '###'
    ]
    # This flag indicates if the end-mark of block-comments (the third value in
    # the list of 3-tuples above) must correspond to the initial block-mark (the
    # first value in the list of 3-tuples above).  If this flag is missing it
    # defaults to `true`. If true it allows one to nest block-comments in
    # different syntax-definitions, like in handlebars or html+php.
    strictMultiLineEnd:false
    singleLineComment: ['#']

  Go:
    nameMatchers:      ['.go']
    singleLineComment: ['//']

  Handlebars:
    nameMatchers:      ['.handlebars', '.hbs']
    multiLineComment:  [
      '<!--', '', '-->', # HTML block comments go first, for code highlighting / segment splitting purposes
      '{{!',  '', '}}'   # Actual handlebars block comments
    ]
    # See above for a description of this flag.
    strictMultiLineEnd:true

  Haskell:
    nameMatchers:      ['.hs']
    singleLineComment: ['--']

  HTML:
    nameMatchers:      ['.htm', '.html']
    multiLineComment:  ['<!--', '', '-->']
    
  Jade:
    nameMatchers:      ['.jade']
    # @todo <https://github.com/isagalaev/highlight.js/pull/250>
    singleLineComment: ['//', '//-']

  Java:
    nameMatchers:      ['.java']
    multiLineComment:  ['/*', '*', '*/']
    singleLineComment: ['//']
    multiLineComment:  ['/*', '*', '*/']

  JavaScript:
    nameMatchers:      ['.js', /^lade$/]
    multiLineComment:  ['/*', '*', '*/']
    singleLineComment: ['//']

  Jake:
    nameMatchers:      ['.jake']
    singleLineComment: ['//']

  JSON                :
    nameMatchers      : ['.json']
    codeOnly          : true

  JSP:
    nameMatchers:      ['.jsp']
    multiLineComment:  [
      '<!--', '', '-->',
      '<%--', '', '--%>'
    ]
    strictMultiLineEnd:true

  LaTeX:
    nameMatchers:      ['.tex', '.latex', '.sty']
    singleLineComment: ['%']

  LESS:
    nameMatchers:      ['.less']
    singleLineComment: ['//']

  LiveScript:
    nameMatchers:       ['.ls', 'Slakefile']
    multiLineComment:   ['/*', '*', '*/']
    singleLineComment:  ['#']

  Lua:
    nameMatchers:      ['.lua']
    singleLineComment: ['--']

  Make:
    nameMatchers:      ['Makefile']
    singleLineComment: ['#']

  Mustache:
    nameMatchers:      ['.mustache']
    multiLineComment:  ['{{!', '', '}}']

  'Objective-C':
    nameMatchers:      ['.m', '.mm']
    multiLineComment:  ['/*', '*', '*/']
    singleLineComment: ['//']

  Perl:
    nameMatchers:      ['.pl', '.pm']
    singleLineComment: ['#']

  PHP:
    nameMatchers:      [/\.php\d?$/, '.fbp']
    singleLineComment: ['//']

  Puppet:
    nameMatchers:      ['.pp']
    singleLineComment: ['#']

  Python:
    nameMatchers:      ['.py']
    singleLineComment: ['#']

  Ruby:
    nameMatchers:      ['.rb', '.ru', '.gemspec']
    singleLineComment: ['#']

  Sass:
    nameMatchers:      ['.sass']
    singleLineComment: ['//']

  SCSS:
    nameMatchers:      ['.scss']
    multiLineComment:  ['/*', '*', '*/']
    singleLineComment: ['//']

  Shell:
    nameMatchers:      ['.sh']
    singleLineComment: ['#']

  SQL:
    nameMatchers:      ['.sql']
    singleLineComment: ['--']

  Swift:
    nameMatchers:      ['.swift']
    singleLineComment: ['//']
    multiLineComment:  ['/*', '*', '*/']

  TypeScript:
    nameMatchers:      ['.ts']
    multiLineComment:  ['/*', '*', '*/']
    singleLineComment: ['//']

  YAML:
    nameMatchers:      ['.yml', '.yaml']
    singleLineComment: ['#']
