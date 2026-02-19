# Changelog

## Version (development version)

### New Features

- Add support for map-reduce package **pbapply**,
  e.g. `y <- pblapply(...) |> futurize()`.

- Add support for domain-specific package **fwb**,
  e.g. `b <- fwb(data, statistic, R = 1000) |> futurize()`.

- Add support for domain-specific package **strucchange**,
  e.g. `bp <- breakpoints(Nile ~ 1) |> futurize()`.

- Add support for domain-specific package **partykit**,
  e.g. `cf <- partykit::cforest(dist ~ speed, data = cars) |> futurize()`.

## Version 0.1.0

CRAN release: 2026-01-22

This is the first version submitted to CRAN.

## Version 0.0.6

### New Features

- Add `supported_packages()` and `supported_package_functions()`.

- Rename argument `chunk.size` to `chunk_size`.

- Add custom [`print()`](https://rdrr.io/r/base/print.html) method for
  transpiled calls such that attributes are displayed for arguments and
  their content.

- Transpiler can now handle nested, complex wrapped expressions.

- Error messages now suggest using `%do%` when trying to futurize
  [`foreach()`](https://rdrr.io/pkg/foreach/man/foreach.html) with
  `%dopar%` or `%dofuture%`.

- Error messages now distinguish between infix operators (e.g. `%do%`)
  and functions (e.g. [`lapply()`](https://rdrr.io/r/base/lapply.html)).

- Add support for **mgcv**, e.g. `b <- bam(...) |> futurize()`.

## Version 0.0.5

### New Features

- Add support for futurizing calls nested in one or more layers of
  `{ ... }`, `( ... )`, `local( ... )`,
  [`I()`](https://rdrr.io/r/base/AsIs.html), and
  [`identity()`](https://rdrr.io/r/base/identity.html), e.g.
  `local({ lapply(x, f) }) |> futurize()` is the same as
  `local({ lapply(x, f) |> futurize() })`.

## Version 0.0.4

### New Features

- Handle nested transpilers.

- Add `futurize(when = {condition})` for futurizing conditioned on an R
  expression at runtime,
  e.g. `lapply(xs, fun) |> futurize(when = (length(xs) > 10))`.

- Add `futurize(FALSE)` and `futurize(TRUE)` for disabling and enabling
  futurizing of calls.

- Add support for **tm**,
  e.g. `m <- tm_map(crude, content_transformer(tolower)) |> futurize()`.

## Version 0.0.3

### New Features

- The default future options for
  [`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
  are now customized such that they work in more cases, e.g. there is no
  need to declare `seed = TRUE` for
  `replicate(3, rnorm(1)) |> futurize()`.

- [`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
  gained argument `eval`, which can be used to return the futurized
  expression instead of evaluating it.

- Add support for **caret**,
  e.g. `model <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()`.

- Add support for
  [`times()`](https://rdrr.io/pkg/foreach/man/foreach.html) and `%:%` of
  **foreach**, which require special care when it comes to passing
  future options, e.g. `futurize(seed = FALSE)`.

## Version 0.0.2

The **futurize** package unifies our current **future.apply**,
**furrr**, and **doFuture** solutions into a minimal, unified API. This
means you no longer need to learn those future-specific packages and
their APIs, and all you need to know is the `... |> futurize()` syntax.
The default behavior of
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
is sufficient for most use cases and users, but, if needed, it comes
with one unifying, unique set of arguments that can be used to configure
how the futures are resolved, how they are partitioned into chunks, and
how output and conditions are relayed, among other things.

### New Features

- Add support for base R, e.g. `y <- lapply(xs, fcn) |> futurize()`,
  `y <- by(xs, idxs, fcn) |> futurize()`, and
  `xs <- kernapply(x, k) |> futurize()`.

- Add support for **purrr**, e.g. `y <- map(xs, fcn) |> futurize()`.

- Add support for **crossmap**,
  e.g. `y <- xmap_dbl(xs, fcn) |> futurize()`.

- Add support for **foreach**,
  e.g. `y <- foreach(x = xs) %do% { fcn(x) } |> futurize()`.

- Add support for **plyr**, e.g. `y <- llply(xs, fcn) |> futurize()`.

- Add support for **BiocParallel**,
  e.g. `y <- bplapply(xs, fcn) |> futurize()`.

- Add support for **boot**,
  e.g. `b <- boot(data, statistic, R = 1000) |> futurize()`.

- Add support for **glmnet**,
  e.g. `cv <- cv.glmnet(x, y) |> futurize()`.

- Add support for **lme4**, e.g. `gm <- allFit(gm) |> futurize()`.

## Version 0.0.1

### New Features

- Implemented a working proof-of-concept of a
  [`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
  function that takes a call expression to any base-R apply function and
  transpiles it such that it runs in parallel via futures. This works by
  transpiling the original map-reduce call to evaluate each iteration
  via a lazy, vanilla future. These futures are then partitioned into
  chunks, where the number of chunks defaults to the number of parallel
  workers. The futures in each chunk are merged into a single future.
  These futures are then launched in parallel on the current future
  backend. When resolved, the results are reduced back to the structure
  that the original base R apply function would return.
