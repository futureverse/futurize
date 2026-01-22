# Parallelize 'foreach' functions

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

![The CRAN 'foreach'
package](../reference/figures/cran-foreach-logo.svg)+ ![The 'futurize'
hexlogo](../reference/figures/futurize-logo.png)= ![The 'future'
logo](../reference/figures/future-logo.png)

## TL;DR

``` r
library(futurize)
plan(multisession)
library(foreach)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:1000
ys <- foreach(x = xs) %do% slow_fcn(x) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
functions such as
[`foreach()`](https://rdrr.io/pkg/foreach/man/foreach.html) and
[`times()`](https://rdrr.io/pkg/foreach/man/foreach.html) of the
**[foreach](https://cran.r-project.org/package=foreach)** package. For
example, consider:

``` r
library(foreach)
xs <- 1:1000
ys <- foreach(x = xs) %do% slow_fcn(x)
```

This [`foreach()`](https://rdrr.io/pkg/foreach/man/foreach.html)
construct is resolved sequentially. We can use the **futurize** package
to tell **foreach** to hand over the orchestration of parallel tasks to
futureverse. All we need to do is to pass the expression to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
as in:

``` r
library(futurize)
library(foreach)
xs <- 1:1000
ys <- foreach(x = xs) %do% slow_fcn(x) |> futurize()
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

Here is another example that parallelizes
[`times()`](https://rdrr.io/pkg/foreach/man/foreach.html) of the
**foreach** package via the futureverse ecosystem:

``` r
library(futurize)
library(foreach)
ys <- times(10) %do% rnorm(3) |> futurize()
```

## Supported Functions

The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function supports parallelization of the following **foreach**
functions:

- `foreach(...) %do% { ... }`
- `times(...) %do% { ... }` with `seed = TRUE` as the default
