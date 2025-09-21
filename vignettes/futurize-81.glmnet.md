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
library(glmnet)
library(futurize)
plan(multisession)

n <- 1000
p <- 100
nzc <- trunc(p / 10)
x <- matrix(rnorm(n * p), n, p)
beta <- rnorm(nzc)
fx <- x[, seq(nzc)] %*% beta
eps <- rnorm(n) * 5
y <- drop(fx + eps)

cv <- cv.glmnet(x, y) |> futurize()
```


# Introduction

This vignette demonstrates how use this approach to parallelize **[glmnet]**
functions such as `cv.glmnet()`.


# Background

The **glmnet** `llply()` function is commonly used to apply a function to
the elements of a list and return a list. For example, 

```r
library(glmnet)

n <- 1000
p <- 100
nzc <- trunc(p / 10)
x <- matrix(rnorm(n * p), n, p)
beta <- rnorm(nzc)
fx <- x[, seq(nzc)] %*% beta
eps <- rnorm(n) * 5
y <- drop(fx + eps)

cv <- cv.glmnet(x, y)
```

Here `glmnet()` evaluates sequentially, but we can easily make it to
evaluate parallelly, by using:

```r
library(futurize)
library(glmnet)

n <- 1000
p <- 100
nzc <- trunc(p / 10)
x <- matrix(rnorm(n * p), n, p)
beta <- rnorm(nzc)
fx <- x[, seq(nzc)] %*% beta
eps <- rnorm(n) * 5
y <- drop(fx + eps)

cv <- cv.glmnet(x, y) |> futurize()
```

This will distribute the calculations across the available parallel
workers, given that we have set parallel workers, e.g.

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and it works on all operating system. There are [other
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

The `futurize()` function supports parallelization of the common base
R functions. The following **glmnet** functions are supported:

* `cv.glmnet()` with `seed = TRUE` as the default


[glmnet]: https://cran.r-project.org/package=glmnet
