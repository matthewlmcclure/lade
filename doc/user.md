---
target: user/index.html.md
---
---
title: Lade User Guide

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
  - user/languages.md

---
# Lade User Guide

## Installing Lade

The following is aspirational as of 2016-07-02. In the meantime, get
Lade from GitHub.

Lade depends on [Node.js](http://nodejs.org/).  Once you have Node,
assuming that your Node came with [npm](http://npmjs.org/), you can
install Lade using:

```bash
$ npm install -g lade
```

For those new to npm, `-g` indicates that you want Lade installed
as globally in your environment.  You may need to prefix the command
with sudo, depending on how you installed node.

## Using Lade

To extract documentation, just point lade to source files that you
want docs for:

```bash
$ lade *.coffee
```

Lade will also handle extended globbing syntax if you quote
arguments:

```bash
$ lade "lib/**/*.coffee" README.md
```

By default, `lade` will put extracted documentation in a `doc`
subfolder of your project.

