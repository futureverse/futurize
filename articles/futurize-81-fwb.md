# Parallelize 'fwb' functions

![The 'fwb' image](../reference/figures/cran-fwb-logo.webp)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.webp)= ![The
'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(fwb)

set.seed(123)
lm_fit <- lm(mpg ~ wt + am, data = mtcars)
b <- fwb(mtcars, statistic = function(data, w) {
  fit <- lm(mpg ~ wt + am, data = data, weights = w)
  coef(fit)
}, R = 999) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[fwb](https://cran.r-project.org/package=fwb)** functions such as
[`fwb()`](https://ngreifer.github.io/fwb/reference/fwb.html) and
[`vcovFWB()`](https://ngreifer.github.io/fwb/reference/vcovFWB.html).

The **[fwb](https://cran.r-project.org/package=fwb)** package implements
the fractional weighted bootstrap (also known as the Bayesian
bootstrap). Rather than resampling units to include in bootstrap
samples, random weights are drawn and applied to a weighted estimator.
Given the resampling nature of bootstrapping, the algorithm is an
excellent candidate for parallelization.

### Example: Fractional weighted bootstrap

The [`fwb()`](https://ngreifer.github.io/fwb/reference/fwb.html)
function produces fractional weighted bootstrap samples of a statistic
applied to data. For example, consider bootstrapping a linear model on
the `mtcars` dataset:

``` r

library(fwb)

## Draw 999 bootstrap samples of the regression coefficients
set.seed(123)
b <- fwb(mtcars, statistic = function(data, w) {
  fit <- lm(mpg ~ wt + am, data = data, weights = w)
  coef(fit)
}, R = 999)
```

Here [`fwb()`](https://ngreifer.github.io/fwb/reference/fwb.html)
evaluates sequentially, but we can easily make it evaluate in parallel
by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(fwb)
library(futurize)

set.seed(123)
b <- fwb(mtcars, statistic = function(data, w) {
  fit <- lm(mpg ~ wt + am, data = data, weights = w)
  coef(fit)
}, R = 999) |> futurize()
```

This will distribute the 999 bootstrap samples across the available
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

### Example: Bootstrap variance-covariance matrix

The [`vcovFWB()`](https://ngreifer.github.io/fwb/reference/vcovFWB.html)
function computes a bootstrap variance-covariance matrix for model
coefficients:

``` r

library(futurize)
plan(multisession)
library(fwb)

lm_fit <- lm(mpg ~ wt + am, data = mtcars)
V <- vcovFWB(lm_fit, R = 999) |> futurize()
```

## Supported Functions

The following **fwb** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`fwb()`](https://ngreifer.github.io/fwb/reference/fwb.html) with
  `seed = TRUE` as the default
- [`vcovFWB()`](https://ngreifer.github.io/fwb/reference/vcovFWB.html)
  with `seed = TRUE` as the default
