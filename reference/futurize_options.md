# Options for how futures are partitioned and resolved

Options for how futures are partitioned and resolved

## Usage

``` r
futurize_options(
  seed = FALSE,
  globals = TRUE,
  packages = NULL,
  stdout = TRUE,
  conditions = "condition",
  scheduling = 1,
  chunk_size = NULL,
  ...
)
```

## Arguments

- seed:

  (optional) If TRUE, the random seed, that is, the state of the random
  number generator (RNG) will be set such that statistically sound
  random numbers are produced (also during parallelization). If FALSE
  (default), it is assumed that the future expression neither needs nor
  uses random number generation. To use a fixed random seed, specify a
  L'Ecuyer-CMRG seed (seven integers) or a regular RNG seed (a single
  integer). If the latter, then a L'Ecuyer-CMRG seed will be
  automatically created based on the given seed. Furthermore, if FALSE,
  then the future will be monitored to make sure it does not use random
  numbers. If it does and depending on the value of option
  [future.rng.onMisuse](https://future.futureverse.org/reference/zzz-future.options.html),
  the check is ignored, an informative warning, or error will be
  produced. If `seed` is NULL, then the effect is as with `seed = FALSE`
  but without the RNG check being performed.

- globals:

  (optional) a logical, a character vector, or a named list to control
  how globals are handled. For details, see section 'Globals used by
  future expressions' in the help for
  [`future()`](https://future.futureverse.org/reference/future.html).

- packages:

  (optional) a character vector specifying packages to be attached in
  the R environment evaluating the future.

- stdout:

  If TRUE (default), then the standard output is captured, and
  re-outputted when
  [`value()`](https://future.futureverse.org/reference/value.html) is
  called. If FALSE, any output is silenced (by sinking it to the null
  device as it is outputted). Using
  `stdout = structure(TRUE, drop = TRUE)` causes the captured standard
  output to be dropped from the future object as soon as it has been
  relayed. This can help decrease the overall memory consumed by
  captured output across futures. Using `stdout = NA` fully avoids
  intercepting the standard output; behavior of such unhandled standard
  output depends on the future backend.

- conditions:

  A character string of condition classes to be captured and relayed.
  The default is to relay all conditions, including messages and
  warnings. To drop all conditions, use `conditions = character(0)`.
  Errors are always relayed. Attribute `exclude` can be used to ignore
  specific classes, e.g.
  `conditions = structure("condition", exclude = "message")` will
  capture all `condition` classes except those that inherit from the
  `message` class. Using `conditions = structure(..., drop = TRUE)`
  causes any captured conditions to be dropped from the future object as
  soon as they have been relayed, e.g. by `value(f)`. This can help
  decrease the overall memory consumed by captured conditions across
  futures. Using `conditions = NULL` (not recommended) avoids
  intercepting conditions, except from errors; behavior of such
  unhandled conditions depends on the future backend and the environment
  from which R runs.

- scheduling:

  Average number of futures ("chunks") per worker. If `0.0`, then a
  single future is used to process all elements of `X`. If `1.0` or
  `TRUE`, then one future per worker is used. If `2.0`, then each worker
  will process two futures (if there are enough elements in `X`). If
  `Inf` or `FALSE`, then one future per element of `X` is used. Only
  used if `chunk_size` is `NULL`.

- chunk_size:

  The average number of elements per future ("chunk"). If `Inf`, then
  all elements are processed in a single future. If `NULL`, then
  argument `scheduling` is used.

- ...:

  Additional named options.

## Value

A named list of future options. Attribute `specified` is a character
vector of future options that were explicitly specified.

## Examples

``` r
# Default futurize options
str(futurize_options())
#> List of 7
#>  $ seed      : logi FALSE
#>  $ globals   : logi TRUE
#>  $ packages  : NULL
#>  $ stdout    : logi TRUE
#>  $ conditions: chr "condition"
#>  $ scheduling: num 1
#>  $ chunk_size: NULL
#>  - attr(*, "specified")= chr(0) 
```
