<!--
%\VignetteIndexEntry{Parallelize 'mgcv' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{mgcv}
%\VignetteKeyword{vignette}
%\VignetteKeyword{handlers}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-mgcv-logo.svg" alt="The 'mgcv' image">
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
library(mgcv)

## Adopted from example("bam", package = "mgcv")
dat <- gamSim(1, n = 25000, dist = "normal", scale = 20)
bs <- "cr"
k <- 12

b <- bam(y ~ s(x0, bs = bs) + s(x1, bs = bs) + s(x2, bs = bs, k = k) +
             s(x3, bs = bs), data = dat) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize **[mgcv]**
functions such as `bam()`.


# Background

The **[mgcv]** package is one of the "recommended" packages in R. It
provides methods for fitting Generalized Additive Models (GAMs). The
`bam()` function can be used to fit GAMs for massive datasets
("Big Additive Models") with many thousands of observations, making
it an excellent candidate for parallelization.


## Example: Fitting a Big Additive Model

The `bam()` function supports parallel processing by setting up a
**parallel** cluster and passing it as argument `cluster`. This is
abstracted away by **futurize**:

```r
library(mgcv)

## Adopted from example("bam", package = "mgcv")
dat <- gamSim(1, n = 25000, dist = "normal", scale = 20)
bs <- "cr"
k <- 12

b <- bam(y ~ s(x0, bs = bs) + s(x1, bs = bs) + s(x2, bs = bs, k = k) +
             s(x3, bs = bs), data = dat) |> futurize()
```

This will distribute the calculations across the available parallel
workers, given that we have set up parallel workers, e.g.

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

The following **mgcv** functions are supported by `futurize()`:

* `bam()`
* `predict.bam()`


[mgcv]: https://cran.r-project.org/package=mgcv
