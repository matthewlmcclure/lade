# ---
# target: includes/contributor/_makefile.md
# ---
# ## Makefile
#
# The rules in the file `Makefile` facilitate extracting Lade's
# documentation and providing it as input to [Slate][1].
#
# Assuming you have a copy of Slate in a directory `~/code/slate`, you
# can use the following Make command.
#
# ```shell
# make slateinput SLATE=~/code/slate
# ```
#
# [1]: https://github.com/lord/slate

# Tell Make the `slateinput` target isn't a file.
.PHONY: slateinput

# Ensure the `SLATE` variable is set.
#
# Then, include in Slate input:
# * Lade's logo
# * Documentation extracted from Lade source files
slateinput: SLATE $(SLATE)/source/images/logo.png
	bin/lade --out $(SLATE)/source

# Tell Make how to give Lade's logo to Slate.
$(SLATE)/source/images/logo.png: doc/lade.png
	cp doc/lade.png $(SLATE)/source/images/logo.png

# Tell Make the `SLATE` target isn't a file.
.PHONY: SLATE

# Fail if the `SLATE` variable isn't set.
SLATE:
ifndef SLATE
	$(error SLATE not defined)
endif
