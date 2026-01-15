<!--
%\VignetteIndexEntry{Parallelize 'glmnet' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{glmnet}
%\VignetteKeyword{vignette}
%\VignetteKeyword{handlers}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/glmnet-logo.svg" alt="The 'glmnet' hexlogo">
<span>+</span>
<img src="../man/figures/futurize-logo.png" alt="The 'futurize' hexlogo">
<span>=</span>
<img src="../man/figures/future-logo.png" alt="The 'future' logo">
</div>

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!


# TL;DR

```r
library(futurize)
plan(multisession)
library(glmnet)

n <- 1000
p <- 100
nzc <- trunc(p / 10)
x <- matrix(rnorm(n * p), n, p)
beta <- rnorm(nzc)
fx <- x[, seq_along(nzc)] %*% beta
eps <- rnorm(n) * 5
y <- drop(fx + eps)

cv <- cv.glmnet(x, y) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize **[glmnet]**
functions such as `cv.glmnet()`.

The **[glmnet]** package provides highly-optimized algorithms for fitting
Generalized Linear Models (GLMs) with lasso and elastic-net regularization.
Its `cv.glmnet()` function performs cross-validation to select the optimal
regularization parameter, which is an excellent candidate for parallelization.


## Example: Cross-validation for regularized regression

The `cv.glmnet()` function fits models across multiple folds and lambda
values. For example:

```r
library(glmnet)

## Generate simulated data
n <- 1000
p <- 100
nzc <- trunc(p / 10)
x <- matrix(rnorm(n * p), n, p)
beta <- rnorm(nzc)
fx <- x[, seq_along(nzc)] %*% beta
eps <- rnorm(n) * 5
y <- drop(fx + eps)

## Perform cross-validation to find optimal lambda
cv <- cv.glmnet(x, y)
```

Here `cv.glmnet()` evaluates sequentially, but we can easily make it
evaluate in parallel by piping to `futurize()`:

```r
library(futurize)
library(glmnet)

n <- 1000
p <- 100
nzc <- trunc(p / 10)
x <- matrix(rnorm(n * p), n, p)
beta <- rnorm(nzc)
fx <- x[, seq_along(nzc)] %*% beta
eps <- rnorm(n) * 5
y <- drop(fx + eps)

cv <- cv.glmnet(x, y) |> futurize()
```

This will distribute the cross-validation folds across the available
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


# Supported Functions

The following **glmnet** functions are supported by `futurize()`:

* `cv.glmnet()` with `seed = TRUE` as the default


[glmnet]: https://cran.r-project.org/package=glmnet
