# Options controlling resources, scheduling and evaluation of futures

Some futures require specific **resources** and capabilities (e.g., RNG,
packages, and globals) in order to be evaluated. These can be declared
via this function. In addition, this function can control how futures
are **evaluated**, including what is collected from futures (e.g.,
standard output and conditions). It can also control how future are
**scheduled**, including how a set of futures are partitioned (e.g.
chunking).

## Usage

``` r
futurize_options(
  rng = FALSE,
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

- rng:

  (resources) If TRUE, parallel-safe random number generation (RNG) is
  set up such that each element is processed with its own, statistically
  sound RNG stream. This is needed whenever the code uses random
  numbers, e.g. via [`rnorm()`](https://rdrr.io/r/stats/Normal.html) or
  [`sample()`](https://rdrr.io/r/base/sample.html). The results are
  reproducible given a fixed
  [`set.seed()`](https://rdrr.io/r/base/Random.html), regardless of how
  and where the elements are processed. Currently, the L'Ecuyer-CMRG RNG
  is used for this. If FALSE (default), then no RNG streams are set up,
  and you will be warned if random numbers are still generated. If NA,
  then no RNG streams are set up, and there is no check for random
  numbers being generated. This can be used to silence false-positive
  RNG warnings, e.g. when the code uses random numbers in a way that
  does not affect the results. If in doubt, use `rng = TRUE`, which is
  always statistically sound. Currently, only `TRUE`, `FALSE`, and `NA`
  are supported; other types of values are reserved for future
  extensions. If `rng` is specified, then `seed` must not be specified.

- seed:

  (resources) Superseded by `rng`, but kept for backward compatibility.
  `seed = TRUE`, `seed = FALSE`, and `seed = NULL` are equivalent to
  `rng = TRUE`, `rng = FALSE`, and `rng = NA`. For other values, see the
  `seed` argument of
  [`future::future()`](https://future.futureverse.org/reference/future.html).

- globals:

  (resource; optional) a logical, a character vector, or a named list to
  control how globals are handled. For details, see section 'Globals
  used by future expressions' in the help for
  [`future()`](https://future.futureverse.org/reference/future.html).

- packages:

  (resource; optional) a character vector specifying packages to be
  attached in the R environment evaluating the future, *in addition to
  packages required by global variables* specified or identified via
  argument `globals`.

- stdout:

  (evaluation) If TRUE (default), then the standard output is captured,
  and re-outputted when
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

  (evaluation) A character string of condition classes to be captured
  and relayed. The default is to relay all conditions, including
  messages and warnings. To drop all conditions, use
  `conditions = character(0)`. Errors are always relayed. Attribute
  `exclude` can be used to ignore specific classes, e.g.
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

  (scheduling) Average number of futures ("chunks") per worker. If
  `0.0`, then a single future is used to process all elements. If `1.0`
  or `TRUE`, then one future per worker is used. If `2.0`, then each
  worker will process two futures (if there are enough elements). If
  `Inf` or `FALSE`, then one future per element is used. Only used if
  `chunk_size` is `NULL`.

- chunk_size:

  (scheduling) The average number of elements per future ("chunk"). If
  `Inf`, then all elements are processed in a single future. If `NULL`,
  then argument `scheduling` is used.

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

# Declare that parallel random number generation is needed
str(futurize_options(rng = TRUE))
#> List of 7
#>  $ seed      : logi TRUE
#>  $ globals   : logi TRUE
#>  $ packages  : NULL
#>  $ stdout    : logi TRUE
#>  $ conditions: chr "condition"
#>  $ scheduling: num 1
#>  $ chunk_size: NULL
#>  - attr(*, "specified")= chr "seed"
```
