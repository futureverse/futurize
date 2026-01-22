# Parallelize base-R apply functions

![The base-R logo](../reference/figures/r-base-logo.svg)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.png)= ![The
'future' logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r
library(futurize)
plan(multisession)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:1000
ys <- lapply(xs, slow_fcn) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
functions such as [`lapply()`](https://rdrr.io/r/base/lapply.html),
[`tapply()`](https://rdrr.io/r/base/tapply.html),
[`apply()`](https://rdrr.io/r/base/apply.html), and
[`replicate()`](https://rdrr.io/r/base/lapply.html) in the **base**
package, and [`kernapply()`](https://rdrr.io/r/stats/kernapply.html) in
the **stats** package. For example, consider the base R
[`lapply()`](https://rdrr.io/r/base/lapply.html) function, which is
commonly used to apply a function to the elements of a vector or a list,
as in:

``` r
xs <- 1:1000
ys <- lapply(xs, slow_fcn)
```

Here [`lapply()`](https://rdrr.io/r/base/lapply.html) evaluates
sequentially, but we can easily make it evaluate in parallel, by using:

``` r
library(futurize)
ys <- lapply(xs, slow_fcn) |> futurize()
```

This will distribute the calculations across the available parallel
workers, given that we have set parallel workers, e.g.

``` r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local computer
and it works on all operating systems. There are [other parallel
backends](https://www.futureverse.org/backends.html) to choose from,
including alternatives to parallelize locally as well as distributed
across remote machines, e.g.

``` r
plan(future.mirai::mirai_multisession)
```

and

``` r
plan(future.batchtools::batchtools_slurm)
```

### Kernel smoothing

``` r
library(futurize)
plan(multisession)

library(stats)

xs <- datasets::EuStockMarkets
k50 <- kernel("daniell", 50)
xs_smooth <- kernapply(xs, k = k50) |> futurize()
```

## Supported Functions

The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function supports parallelization of the common base R functions. The
following **base** package functions are supported:

- [`lapply()`](https://rdrr.io/r/base/lapply.html),
  [`vapply()`](https://rdrr.io/r/base/lapply.html),
  [`sapply()`](https://rdrr.io/r/base/lapply.html),
  [`tapply()`](https://rdrr.io/r/base/tapply.html)
- [`mapply()`](https://rdrr.io/r/base/mapply.html),
  [`.mapply()`](https://rdrr.io/r/base/mapply.html),
  [`Map()`](https://rdrr.io/r/base/funprog.html)
- [`eapply()`](https://rdrr.io/r/base/eapply.html)
- [`apply()`](https://rdrr.io/r/base/apply.html)
- [`replicate()`](https://rdrr.io/r/base/lapply.html) with `seed = TRUE`
  as the default
- [`by()`](https://rdrr.io/r/base/by.html)
- [`Filter()`](https://rdrr.io/r/base/funprog.html)

The [`rapply()`](https://rdrr.io/r/base/rapply.html) function is not
supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md).

The following **stats** package function is also supported:

- [`kernapply()`](https://rdrr.io/r/stats/kernapply.html)
