<!--
%\VignetteIndexEntry{Parallelize 'fwb' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{fwb}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-fwb-logo.webp" alt="The 'fwb' image">
<span>+</span>
<img src="../man/figures/futurize-logo.webp" alt="The 'futurize' hexlogo">
<span>=</span>
<img src="../man/figures/future-logo.webp" alt="The 'future' logo">
</div>

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!


# TL;DR

```r
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


# Introduction

This vignette demonstrates how to use this approach to parallelize
**[fwb]** functions such as `fwb()` and `vcovFWB()`.

The **[fwb]** package implements the fractional weighted bootstrap
(also known as the Bayesian bootstrap). Rather than resampling units
to include in bootstrap samples, random weights are drawn and
applied to a weighted estimator. Given the resampling nature of
bootstrapping, the algorithm is an excellent candidate for
parallelization.


## Example: Fractional weighted bootstrap

The `fwb()` function produces fractional weighted bootstrap samples
of a statistic applied to data. For example, consider bootstrapping
a linear model on the `mtcars` dataset:

```r
library(fwb)

## Draw 999 bootstrap samples of the regression coefficients
set.seed(123)
b <- fwb(mtcars, statistic = function(data, w) {
  fit <- lm(mpg ~ wt + am, data = data, weights = w)
  coef(fit)
}, R = 999)
```

Here `fwb()` evaluates sequentially, but we can easily make it
evaluate in parallel by piping to `futurize()`:

```r
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

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and works on all operating systems. There are [other
parallel backends] to choose from, including alternatives to
parallelize locally as well as distributed across remote machines,
e.g.

```r
plan(future.mirai::mirai_multisession)
```

and

```r
plan(future.batchtools::batchtools_slurm)
```


## Example: Bootstrap variance-covariance matrix

The `vcovFWB()` function computes a bootstrap variance-covariance
matrix for model coefficients:

```r
library(futurize)
plan(multisession)
library(fwb)

lm_fit <- lm(mpg ~ wt + am, data = mtcars)
V <- vcovFWB(lm_fit, R = 999) |> futurize()
```


# Supported Functions

The following **fwb** functions are supported by `futurize()`:

* `fwb()` with `seed = TRUE` as the default
* `vcovFWB()` with `seed = TRUE` as the default


[fwb]: https://cran.r-project.org/package=fwb
[other parallel backends]: https://www.futureverse.org/backends.html
