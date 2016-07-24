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

Lade depends on [Node.js](http://nodejs.org/). Assuming you have Node,
and your Node came with [npm](http://npmjs.org/), you can install Lade
using:

```bash
$ npm install -g Lade
```

For those new to npm, `-g` indicates that you want Lade installed
as globally in your environment.  You may need to prefix the command
with sudo, depending on how you installed node.

## Documenting Programs

Lade extracts comments from source code, and writes the comments to a
given target file.

An example follows.

Suppose you have a `hello.coffee` file with the following contents.

```coffeescript
# ---
# target: hello.md
# ---
# # Hello, World!
#
# A "Hello, World!" program is a computer program that outputs or
# displays "Hello, World!" to the user. Being a very simple program in
# most programming languages, it is often used to illustrate the basic
# syntax of a programming language for a working program.
#
# This implementation uses Coffescript.
print "Hello, World!"
```

<div></div>

You can use Lade to extract the documentation to a `hello.md`
file. The `hello.md` file will contain the following.

```markdown
# Hello, World!

A "Hello, World!" program is a computer program that outputs or
displays "Hello, World!" to the user. Being a very simple program in
most programming languages, it is often used to illustrate the basic
syntax of a programming language for a working program.

This implementation uses Coffescript.
```

<div></div>

You can also document for different audiences in the same source
file. For example, if the `hello.coffee` file contained the following.

```coffeescript
# ---
# target: hello_for_users.md
# ---
# # Hello, World!
#
# A "Hello, World!" program is a computer program that outputs or
# displays "Hello, World!" to the user. Being a very simple program in
# most programming languages, it is often used to illustrate the basic
# syntax of a programming language for a working program.
#
# Run this "Hello, World!" using the command `coffee hello.coffee`.

# ---
# target: hello_for_programmers.md
# ---
# # Hello, World!
#
# The implementation of "Hello, World!" in Coffeescript is very
# simple. It consists of a single file containing a single statement.
#
# Refer to the `hello.coffee` file for the source of this
# documentation and the program itself.
console.log "Hello, World!"
```

<div></div>

Then Lade would produce two separate documentation files. The
`hello_for_users.md` file would contain the following.

```markdown
# Hello, World!

A "Hello, World!" program is a computer program that outputs or
displays "Hello, World!" to the user. Being a very simple program in
most programming languages, it is often used to illustrate the basic
syntax of a programming language for a working program.

Run this "Hello, World!" using the command `coffee hello.coffee`.
```

<div></div>

And the `hello_for_programmers.md` file would contain the following.

```markdown
# Hello, World!

The implementation of "Hello, World!" in Coffeescript is very
simple. It consists of a single file containing a single statement.

Refer to the `hello.coffee` file for the source of this
documentation and the program itself.
```

## Using Lade

To extract documentation, just point `lade` to source files that you
want docs for:

```bash
$ lade *.coffee
```

<div></div>

Lade will also handle extended globbing syntax if you quote
arguments:

```bash
$ lade "lib/**/*.coffee" README.md
```

<div></div>

By default, `lade` will put extracted documentation in a `doc`
subfolder of your project.

