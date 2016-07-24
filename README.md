---
target: index.html.md
---
---
title: "Lade: Language-agnostic Documentation Extractor"

---
# Lade

Lade is a language-agnostic documentation extractor.

It extracts documentation from source code in any programming
language.

It facilitates:

* maintaining documentation close to the relevant source code
* documentation-driven development -- growing implementation from
documentation, and vice-versa
* producing different sets of documentation for different audiences --
users concerned with a program's UIs, developers concerned with its
APIs, and contributors concerned with its internals.

## User Guide

Refer to the [user guide](./user/).

## Contributor Guide

Refer to the [contributor guide](./contributor/).

## Maintainers

Lade is maintained by [Matt McClure](http://matthewlmcclure.com/).

## History

Lade is derived from [Ian MacLeod](https://github.com/nevir)'s
[Groc](https://github.com/nevir/groc). Lade is the result of taking
groc apart and putting it back together again. What remains is the
essence of documentation extraction, without groc's rendering and
publishing capabilities.

Groc was heavily influenced by
[Jeremy Ashkenas](https://github.com/jashkenas)'
[docco](http://jashkenas.github.com/docco/). It was an attempt to
further enhance the idea (thus, groc couldn't tout the same quick 'n
dirty principles of docco).

## Known Issues

* Lade's own documentation produces many small partial Markdown
  files. It seems more desirable that it could assemble fragments from
  many places in the source code into a given Markdown file so that
  the resulting extracted documentation could be used easily without
  rendering it with Slate.
