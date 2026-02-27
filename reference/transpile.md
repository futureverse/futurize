# Transpile an R expression

Transpile an R expression

## Usage

``` r
transpile(
  expr,
  options = list(...),
  ...,
  when = TRUE,
  eval = TRUE,
  envir = parent.frame(),
  disable = FALSE,
  type = "built-in",
  what = "transpile",
  unwrap = list(base::`{`, base::`(`, base::`!`, base::local, base::I, base::identity,
    base::invisible, base::suppressMessages, base::suppressWarnings,
    base::suppressPackageStartupMessages),
  debug = FALSE
)
```

## Arguments

- expr:

  An R expression, typically a function call to transpile. If FALSE,
  then the transpiler is disabled, and if TRUE, it is re-enabled. If NA,
  then TRUE is returned if the transpiler is enabled, otherwise FALSE.

- options:

  (optional) Named options for the transpilation.

- when:

  If TRUE (default), the expression is transpiled, otherwise not.

- eval:

  If TRUE (default), the transpiled expression is evaluated, otherwise
  it is returned.

- envir:

  The environment where the expression should be evaluated.

- type:

  Type of the transpiler to use.

- unwrap:

  (optional) A list of functions that should be considered wrapping
  functions that the transpiler should unwrap ("enter"). This allows us
  to transpile expressions within `{ ... }` and `local( ... )`.

## Value

Returns the value of the evaluated expression `expr` if `eval = TRUE`,
otherwise the transpiled expression. If `expr` is NA, then TRUE is
returned if the transpiler is enabled, otherwise FALSE.
