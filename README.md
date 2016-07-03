---
target: index.html.md
---
---
includes:
  - cli/heading.md
  - cli/help.md
  - cli/glob.md
  - cli/except.md
  - cli/out.md
  - cli/root.md
  - cli/languages.md
  - cli/silent.md
  - cli/version.md
  - cli/verbose.md
  - cli/very_verbose.md

---
# mlmgroc

MlmGroc extracts documentation from source code.

## Goals

MlmGroc's goal is extraction of documentation from any programming
language, for any audience.

It should facilitate maintaining documentation close to source code
that delivers on documentation's claims. It should facilitate
documentation-driven development -- growing implementation from
documentation, and vice-versa. And it should facilitate producing
different sets of documentation for different audiences -- users
concerned with a program's UIs, developers concerned with its APIs,
and contributors concerned with its internals.

## History

MlmGroc is derived from [Ian MacLeod](https://github.com/nevir)'s
[Groc](https://github.com/nevir/groc). MlmGroc is the result of taking
groc apart and putting it back together again. What remains is the
essence of documentation extraction, without groc's rendering and
publishing capabilities.

Groc was heavily influenced by
[Jeremy Ashkenas](https://github.com/jashkenas)'
[docco](http://jashkenas.github.com/docco/). It was an attempt to
further enhance the idea (thus, groc couldn't tout the same quick 'n
dirty principles of docco).

## Maintainers

MlmGroc is maintained by [Matt McClure](http://matthewlmcclure.com/).

### Installing groc

The following is aspirational as of 2016-07-02. In the meantime, get
MlmGroc from GitHub.

MlmGroc depends on [Node.js](http://nodejs.org/).  Once you have Node,
assuming that your Node came with [npm](http://npmjs.org/), you can
install MlmGroc using:

```bash
$ npm install -g mlmgroc
```

For those new to npm, `-g` indicates that you want MlmGroc installed
as globally in your environment.  You may need to prefix the command
with sudo, depending on how you installed node.

### Using groc

To extract documentation, just point groc to source files that you
want docs for:

```bash
$ groc *.coffee
```

MlmGroc will also handle extended globbing syntax if you quote
arguments:

```bash
$ groc "lib/**/*.coffee" README.md
```

By default, groc will put extracted documentation in a `doc` subfolder
of your project.

### Configuring groc

MlmGroc can configure itself from a file as an alternative to using
command-line arguments.

Create a `.groc.json` file in your project root, where each key maps
to an argument you would pass to the `groc` command.  File names and
globs are defined as an array with the key `glob`.  For example,
MlmGroc's own configuration is:

```json
{
    "glob": [
        "**/*.md",
        "**/*.coffee",
        ".groc.json",
        "package.json"
    ],
    "except": [
        "node_modules/**"
    ],
    "out": "./doc",
    "only-render-newer": false
}
```

If you invoke `groc` without any arguments, it will use your
pre-defined configuration.

## Known Issues

* I'm still taking groc apart, and there will be more work ahead to
  put it back together.
* MlmGroc's own documentation produces many small partial Markdown
  files. It seems more desirable that it could assemble fragments from
  many places in the source code into a given Markdown file so that
  the resulting extracted documentation could be used easily without
  rendering it with Slate.
