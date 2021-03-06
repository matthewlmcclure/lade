# TODO: should be migrated into `lib/utils`.

childProcess = require 'child_process'
path         = require 'path'
YAML         = require 'yamljs'

_        = require 'underscore'

LANGUAGES            = null
Logger               = require './utils/logger'


# ---
# target: includes/contributor/lib/_utils.md
# ---
# ## `Utils`
#
# Utility functions
module.exports = Utils =

  # ---
  # target: includes/contributor/lib/utils/_regexpEscapePattern.md
  # ---
  #
  # ### `regexpEscapePattern`
  #
  # A regular expression matching a class of regular expression
  # metacharacters
  regexpEscapePattern : /[-[\]{}()*+?.,\\^$|#\s]/g
  # ---
  # target: includes/contributor/lib/utils/_regexpEscapeReplace.md
  # ---
  #
  # ### `regexpEscapeReplace`
  #
  # A replacement that escapes a matched character with `\`
  regexpEscapeReplace : '\\$&'

  # ---
  # target: includes/contributor/lib/utils/_regexpEscape.md
  # ---
  # ### `regexpEscape`
  #
  # ```coffeescript
  # regexpEscape "a string"
  # regexpEscape ["an", "array", "of", "strings"]
  # ```
  #
  # Escape regular expression characters in a String, an Array of
  # Strings or any Object having a proper toString-method
  #
  # #### Parameters
  #
  # * `obj`: a string, array of strings, or object having a `toString`
  #          method
  #
  # #### Result
  #
  # A transformed `obj`, in which characters in `regexpEscapePattern`
  # have been escaped according to `regexpEscapeReplace`.
  #
  # #### Credit
  #
  # Adapted from the solution at
  # <http://blog.simonwillison.net/post/57956816139/escape>
  regexpEscape: (obj) ->
    if _.isArray obj
      _.invoke(obj, 'replace', @regexpEscapePattern, @regexpEscapeReplace)
    else if _.isString obj
      obj.replace(@regexpEscapePattern, @regexpEscapeReplace)
    else
      @regexpEscape "#{obj}"

  # ---
  # target: includes/contributor/lib/utils/_getLanguage.md
  # ---
  # ### `getLanguage`
  #
  # ```coffeescript
  # getLanguage file, languages
  # ```
  #
  # Detect the language that a given file is written in
  #
  # The language is also annotated with a name property, matching the language's
  # key in LANGUAGES.
  #
  # #### Parameters
  #
  # * `filePath`: filesystem path of file containing language to detect
  # * `languageDefinitions`: filesystem path of module containing languages object
  #
  # #### Result
  #
  # Language object corresponding to source file type of file at `filePath`
  getLanguage: (filePath, languageDefinitions = './languages') ->
    unless @_languageDetectionCache?
      @_languageDetectionCache = []

      LANGUAGES = require(languageDefinitions) if not LANGUAGES?

      for name, language of LANGUAGES
        language.name = name

        for matcher in language.nameMatchers
          # If the matcher is a string, we assume that it's a file extension.
          # Stick it in a regex:
          matcher = ///#{@regexpEscape matcher}$/// if _.isString matcher

          @_languageDetectionCache.push [matcher, language]

    baseName = path.basename filePath

    for pair in @_languageDetectionCache
      return pair[1] if baseName.match pair[0]

  # ---
  # target: includes/contributor/lib/utils/_splitSource.md
  # ---
  # ### `splitSource`
  #
  # ```coffeescript
  # segments = Utils.splitSource data, language
  # ```
  #
  # Split `data` in a given `language` into an array of `Segment`
  # objects
  #
  # #### Parameters
  #
  # * `data`: source text as a multi-line string
  # * `language`: `Language` object corresponding to the source file type of `data`
  #
  # #### Result
  #
  # Array of `Segment` objects, each containing source code or comment
  # lines
  splitSource: (data, language) ->
    lines = data.split /\r?\n/

    # Always strip shebangs - but don't shift it off the array to
    # avoid the perf hit of walking the array to update indices.
    lines[0] = '' if lines[0][0..1] is '#!'

    # Special case: If the language is comments-only, we can skip pygments
    return [new @Segment [], lines] if language.commentsOnly

    # Special case: If the language is code-only, we can shorten the process
    return [new @Segment lines, []] if language.codeOnly

    segments = []
    currSegment = new @Segment

    # Make whitespace after the comment token optional
    whitespaceMatch = '\\s?'

    if language.singleLineComment?
      singleLines = @regexpEscape(language.singleLineComment).join '|'
      aSingleLine = ///
        ^\s*                        # Start a line and skip all indention.
        (?:#{singleLines})          # Match the single-line start but don't capture this group.
        (?:                         # Also don't capture this group …
          #{whitespaceMatch}        # … possibly starting with a whitespace, but
          (.*)                      # … capture anything else in this …
        )?                          # … optional group …
        $                           # … up to the EOL.
      ///


    if language.multiLineComment?
      mlc = language.multiLineComment

      unless (mlc.length % 3) is 0
        throw new Error('Multi-line block-comment definitions must be a list of 3-tuples')

      blockStarts = _.select mlc, (v, i) -> i % 3 == 0
      blockLines  = _.select mlc, (v, i) -> i % 3 == 1
      blockEnds   = _.select mlc, (v, i) -> i % 3 == 2

      # This flag indicates if the end-mark of block-comments (the `blockEnds`
      # list above) must correspond to the initial block-mark (the `blockStarts`
      # above).  If this flag is missing it defaults to `true`.  The main idea
      # is to embed sample block-comments with syntax A in another block-comment
      # with syntax B. This useful in handlebar's mixed syntax or other language
      # combinations like html+php, which are supported by `pygmentize`.
      strictMultiLineEnd = language.strictMultiLineEnd ? true

      # This map is used to lookup corresponding line- and end-marks.
      blockComments = {}
      for v, i in blockStarts
        blockComments[v] =
          linemark: blockLines[i]
          endmark : blockEnds[i]

      blockStarts = @regexpEscape(blockStarts).join '|'
      blockLines  = @regexpEscape(blockLines).join '|'
      blockEnds   = @regexpEscape(blockEnds).join '|'

      # No need to match for any particular real content in `aBlockStart`, as
      # either `aBlockLine`, `aBlockEnd` or the `inBlock` catch-all fallback
      # handles the real content, in the implementation below.
      aBlockStart = ///
        ^(\s*)                      # Start a line and capture indention, used to reverse indent catch-all fallback lines.
        (#{blockStarts})            # Capture the start-mark, to check the if line- and end-marks correspond, …
        (#{blockLines})?            # … possibly followed by a line, captured to check if its corresponding to the start,
        (?:#{whitespaceMatch}|$)    # … and finished by whitespace OR the EOL.
      ///

      aBlockLine = ///
        ^\s*                        # Start a line and skip all indention.
        (#{blockLines})             # Capture the line-mark to check if it corresponds to the start-mark, …
        (#{whitespaceMatch})        # … possibly followed by whitespace,
        (.*)$                       # … and collect all up to the line end.
      ///

      aBlockEnd = ///
        (#{blockEnds})              # Capture the end-mark to check if it corresponds to the line start,
        (.*)?$                      # … and collect all up to the line end.
      ///

      ###
      # A special case used to capture empty block-comment lines, like the one
      # below this line …
      #
      # … and above this line.
      ###
      aEmptyLine = ///^\s*(?:#{blockLines})$///

    inBlock   = false

    # Variables used in temporary assignments have been collected here for
    # documentation purposes only.
    blockline = null
    blockmark = null
    linemark  = null
    space     = null
    endmark   = null
    indention = null
    comment   = null
    code      = null

    for line in lines

      # Match that line to the language's block-comment syntax, if it exists
      if aBlockStart? and not inBlock and (match = line.match aBlockStart)?
        inBlock = true

        # Reusing `match` as a placeholder.
        [match, indention, blockmark, linemark] = match

        # Strip the block-comments start, preserving any inline stuff.
        # We don't touch the `line` itself, as we still need it.
        blockline = line.replace aBlockStart, ''

        # If we found a `linemark`, prepend it (back) to the `blockline`, if it
        # does not correspond to the initial `blockmark`.
        if linemark? and blockComments[blockmark].linemark isnt linemark
          blockline = "#{linemark}#{blockline}"

        # Block-comments are an important tool to structure code into larger
        # segments, therefore we always start a new segment if the current one
        # is not empty.
        else if currSegment.code.length > 0
          segments.push currSegment
          currSegment   = new @Segment

      # This flag is triggered above.
      if inBlock

        # Catch all lines, unless there is a `blockline` from above.
        blockline = line unless blockline?

        # Match a block-comment's end
        if (match = blockline.match aBlockEnd)?

          # Reusing `match` as a placeholder.
          [match, endmark, code] = match

          # The `endmark` must correspond to the `blockmark`'s.
          if not strictMultiLineEnd or blockComments[blockmark].endmark is endmark

            ### Ensure to leave the block-comment, especially single-lines like this one. ###
            inBlock = false

            blockline = blockline.replace aBlockEnd, ''

        # Match a block-comment's line
        if (match = blockline.match aBlockLine)?

          # Reusing `match` as a placeholder.
          [match, linemark, space, comment] = match

          # If we found a `linemark`, prepend it (back) to the `comment`,
          # if it does not correspond to the initial `blockmark`.
          if linemark? and blockComments[blockmark].linemark isnt linemark
            comment = "#{linemark}#{space ? ''}#{comment}"

          blockline = comment

        # The previous cycle contained code, so lets start a new segment.
        if currSegment.code.length > 0
          segments.push currSegment
          currSegment = new @Segment

        # A special case as described in the initialization of `aEmptyLine`.
        if aEmptyLine.test line
          currSegment.comments.push ""

        else
          ###
          Collect all but empty start- and end-block-comment lines, hence
          single-line block-comments simultaneous matching `aBlockStart`
          and `aBlockEnd` have a false `inBlock` flag at this point, are
          included.
          ###
          if not /^\s*$/.test(blockline) or (inBlock and not aBlockStart.test line)
            # Strip leading `indention` from block-comment like the one above
            # to align their content with the initial blockmark.
            if indention? and indention isnt '' and not aBlockLine.test line
              blockline = blockline.replace ///^#{indention}///, ''

            currSegment.comments.push blockline

          # The `code` may occure immediatly after a block-comment end.
          if code?
            currSegment.code.push code unless inBlock # fool-proof ?
            code = null

        # Make sure the next cycle starts fresh.
        blockline = null

      # Match that line to the language's single line comment syntax.
      #
      # However, we treat all comments beginning with } as inline code commentary
      # and comments starting with ^ cause that comment and the following code
      # block to start folded.
      else if aSingleLine? and (match = line.match aSingleLine)?

        # Uses `match` as a placeholder.
        [match, comment] = match

        if comment? and comment isnt ''

          # The previous cycle contained code, so lets start a new segment
          # and stop any folding.
          if currSegment.code.length > 0
            segments.push currSegment
            currSegment   = new @Segment

          currSegment.comments.push comment

        else
          currSegment.comments.push ''

      # We surely (should) have raw code at this point.
      else
        currSegment.code.push line

    segments.push currSegment

    segments

  # ---
  # target: includes/contributor/lib/utils/_Segment.md
  # ---
  # ### `Segment`
  #
  # A container to hold code lines and corresponding comment lines
  #
  # #### Attributes
  #
  # * `code`: array of source code lines
  # * `comments`: array of comment lines
  Segment: class Segment
    constructor: (code=[], comments=[]) ->
      @code     = code
      @comments = comments

  # ---
  # target: includes/contributor/lib/utils/_preprocessComments.md
  # ---
  # ### `preprocessComments`
  #
  # Preprocess comment `Segment` objects.
  #
  # Extract a target path from comment front matter. Assemble the
  # array of comment lines into a multi-line comment text string.
  #
  # Input `Segment` objects are modified by adding `targetPath` and
  # `plainComments` attributes.
  #
  # #### Parameters
  #
  # * `segments`: array of `Segment` objects
  # * `project`: `Project` to use
  # * `callback`: function to call on completion
  #
  # #### Result
  #
  # None
  preprocessComments: (segments, project, callback) ->
    try
      for segment, segmentIndex in segments
        commentLineIndex = 1
        if segment.comments[0] == "---"
          while segment.comments[commentLineIndex] != "---"
            commentLineIndex++
            if commentLineIndex == segment.comments.length
              throw new Error 'Missing trailing "---"'
          frontMatterYaml = segment.comments[1...commentLineIndex].join '\n'
          frontMatter = YAML.parse(frontMatterYaml)
          targetPath = frontMatter.target
          segment.comments = segment.comments[commentLineIndex+1..]
          project.log.debug "targetPath: %s", targetPath
          plainComments = segment.comments.join '\n'
          plainComments += '\n\n'

          # Attach the plain comments
          segment.plainComments = plainComments
          # As well as the targetPath and the frontMatter
          segment.targetPath = targetPath
          segment.frontMatter = frontMatter

    catch error
      return callback error

    callback()

# Local Variables:
# coffee-tab-width: 2
# End:
