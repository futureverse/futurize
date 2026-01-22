# Parallelize 'glmnet' functions

![The 'glmnet' hexlogo](../reference/figures/glmnet-logo.svg)+ ![The
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

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[glmnet](https://cran.r-project.org/package=glmnet)** functions such
as
[`cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html).

The **[glmnet](https://cran.r-project.org/package=glmnet)** package uses
a highly optimized pathwise coordinate descent algorithm to efficiently
compute the entire regularization path for penalized generalized linear
models (Lasso, Ridge, Elastic Net). Its
[`cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html)
function performs cross-validation to select the optimal regularization
parameter, which is an excellent candidate for parallelization.

### Example: Cross-validation for regularized regression

The
[`cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html)
function fits models across multiple folds and lambda values. For
example:

``` r
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

Here
[`cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html)
evaluates sequentially, but we can easily make it evaluate in parallel
by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r
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

The following **glmnet** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html)
  with `seed = TRUE` as the default
