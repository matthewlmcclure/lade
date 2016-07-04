---
target: user/index.html.md
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
# MlmGroc User Guide

## Installing groc

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

## Using groc

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

## Configuring groc

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

