# Makefile for the 'progressify' package

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Transpiler code, which is copied from the 'transpiler' package,
# expected in the sibling folder ../transpiler
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
R_SCRIPT ?= Rscript
TRANSPILER_DIR ?= ../transpiler

## Copy the transpiler code from the 'transpiler' package
transpiler-sync:
	$(R_SCRIPT) "$(TRANSPILER_DIR)/tools/sync.R" .

## Check that the transpiler code is in sync with the 'transpiler' package
transpiler-check:
	$(R_SCRIPT) "$(TRANSPILER_DIR)/tools/sync.R" --check .

.PHONY: transpiler-sync transpiler-check
