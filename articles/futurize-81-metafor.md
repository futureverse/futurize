# Parallelize 'metafor' functions

![The CRAN 'metafor'
package](../reference/figures/cran-metafor-logo.svg)+ ![The 'futurize'
hexlogo](../reference/figures/futurize-logo.png)= ![The 'future'
logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(metafor)

dat <- escalc(measure = "RR", ai = tpos, bi = tneg,
              ci = cpos, di = cneg, data = dat.bcg)
fit <- rma(yi, vi, data = dat)
pr <- profile(fit) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[metafor](https://cran.r-project.org/package=metafor)** functions such
as [`profile()`](https://rdrr.io/r/stats/profile.html),
[`rstudent()`](https://rdrr.io/r/stats/influence.measures.html),
[`cooks.distance()`](https://rdrr.io/r/stats/influence.measures.html),
and [`dfbetas()`](https://rdrr.io/r/stats/influence.measures.html).

The **[metafor](https://cran.r-project.org/package=metafor)** package
provides a comprehensive collection of functions for conducting
meta-analyses in R. It supports fixed-effects, random-effects, and
mixed-effects (meta-regression) models and includes functions for model
diagnostics and profiling. Several of these computations involve fitting
the model repeatedly, making them excellent candidates for
parallelization.

### Example: Likelihood profile for a random-effects model

The [`profile()`](https://rdrr.io/r/stats/profile.html) function
computes the likelihood profile for model parameters such as the
variance component in a random-effects meta-analysis. For example, using
the built-in BCG vaccine dataset:

``` r

library(metafor)

## Calculate log risk ratios and sampling variances
dat <- escalc(measure = "RR", ai = tpos, bi = tneg,
              ci = cpos, di = cneg, data = dat.bcg)

## Fit a random-effects model
fit <- rma(yi, vi, data = dat)

## Compute likelihood profile
pr <- profile(fit)
```

Here [`profile()`](https://rdrr.io/r/stats/profile.html) is calculated
sequentially. To calculate in parallel, we can pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)
library(metafor)

dat <- escalc(measure = "RR", ai = tpos, bi = tneg,
              ci = cpos, di = cneg, data = dat.bcg)
fit <- rma(yi, vi, data = dat)
pr <- profile(fit) |> futurize()
```

This will distribute the profile computations across the available
parallel workers, given that we have set up parallel workers, e.g.

``` r

plan(multisession)
```

The built-in `multisession` backend parallelizes on your local computer
and works on all operating systems. There are [other parallel
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

The following **metafor** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`profile()`](https://rdrr.io/r/stats/profile.html) for ‘rma.uni’,
  ‘rma.mv’, ‘rma.ls’, and ‘rma.uni.selmodel’
- [`rstudent()`](https://rdrr.io/r/stats/influence.measures.html) for
  ‘rma.mv’
- [`cooks.distance()`](https://rdrr.io/r/stats/influence.measures.html)
  for ‘rma.mv’
- [`dfbetas()`](https://rdrr.io/r/stats/influence.measures.html) for
  ‘rma.mv’
