---
target: user/index.html.md
---
---
includes:
  - user/configuration.md
  - user/cli/heading.md
  - user/cli/help.md
  - user/cli/glob.md
  - user/cli/except.md
  - user/cli/out.md
  - user/cli/root.md
  - user/cli/languages.md
  - user/cli/silent.md
  - user/cli/version.md
  - user/cli/verbose.md
  - user/cli/very_verbose.md

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

