# Parallelize 'BiocParallel' functions

![The Bioconductor 'BiocParallel'
image](../reference/figures/bioconductor-BiocParallel-logo.svg)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.png)= ![The
'future' logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

You can use **futurize** to make
**[BiocParallel](https://bioconductor.org/packages/BiocParallel/)**
functions to parallelize via any of the \[parallel backends\] supported
by Futureverse, e.g.

``` r
library(futurize)
plan(multisession)
library(BiocParallel)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:1000
ys <- bplapply(xs, slow_fcn) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
functions such as
[`bplapply()`](https://rdrr.io/pkg/BiocParallel/man/bplapply.html),
[`bpmapply()`](https://rdrr.io/pkg/BiocParallel/man/bpmapply.html), and
[`bpvec()`](https://rdrr.io/pkg/BiocParallel/man/bpvec.html) in the
**BiocParallel** package. For example, consider the
[`bplapply()`](https://rdrr.io/pkg/BiocParallel/man/bplapply.html)
function. It works like base-R
[`lapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html), but uses
the **BiocParallel** framework to process the tasks concurrently. It is
commonly used something like:

``` r
library(BiocParallel)
xs <- 1:1000
ys <- bplapply(xs, slow_fcn)
```

The parallel backend is controlled by the
[`BiocParallel::register()`](https://rdrr.io/pkg/BiocParallel/man/register.html),
similar to how we use
[`future::plan()`](https://future.futureverse.org/reference/plan.html)
in futureverse. We can use the **futurize** package to tell
**BiocParallel** to hand over the orchestration of parallel tasks to
futureverse. All we need to do is to pass the expression to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
as in:

``` r
library(futurize)
library(BiocParallel)
xs <- 1:1000
ys <- bplapply(xs, slow_fcn) |> futurize()
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

## Supported Functions

The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function supports parallelization of all **BiocParallel** functions that
take argument `BPPARAM`. Specifically,

- [`bplapply()`](https://rdrr.io/pkg/BiocParallel/man/bplapply.html) and
  [`.bplapply_impl()`](https://rdrr.io/pkg/BiocParallel/man/DeveloperInterface.html)
- [`bpmapply()`](https://rdrr.io/pkg/BiocParallel/man/bpmapply.html) and
  `.bpmapply_impl()`
- [`bpvec()`](https://rdrr.io/pkg/BiocParallel/man/bpvec.html)
- [`bpaggregate()`](https://rdrr.io/pkg/BiocParallel/man/bpaggregate.html)

The following functions are currently not supported:

- [`bpiterate()`](https://rdrr.io/pkg/BiocParallel/man/bpiterate.html) -
  technically supported, but because this function does not support
  using
  [`DoparParam()`](https://rdrr.io/pkg/BiocParallel/man/DoparParam-class.html)
  with it, it effectively does not work with
  [`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
- [`bpvectorize()`](https://rdrr.io/pkg/BiocParallel/man/bpvectorize.html)
- [`register()`](https://rdrr.io/pkg/BiocParallel/man/register.html)
