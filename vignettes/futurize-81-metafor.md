<!--
%\VignetteIndexEntry{Parallelize 'metafor' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{metafor}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-metafor-logo.svg" alt="The CRAN 'metafor' package">
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
library(metafor)

dat <- escalc(measure = "RR", ai = tpos, bi = tneg,
              ci = cpos, di = cneg, data = dat.bcg)
fit <- rma(yi, vi, data = dat)
pr <- profile(fit) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
**[metafor]** functions such as `profile()`, `rstudent()`,
`cooks.distance()`, and `dfbetas()`.

The **[metafor]** package provides a comprehensive collection of
functions for conducting meta-analyses in R. It supports fixed-effects,
random-effects, and mixed-effects (meta-regression) models and includes
functions for model diagnostics and profiling. Several of these
computations involve fitting the model repeatedly, making them
excellent candidates for parallelization.


## Example: Likelihood profile for a random-effects model

The `profile()` function computes the likelihood profile for model
parameters such as the variance component in a random-effects
meta-analysis. For example, using the built-in BCG vaccine dataset:

```r
library(metafor)

## Calculate log risk ratios and sampling variances
dat <- escalc(measure = "RR", ai = tpos, bi = tneg,
              ci = cpos, di = cneg, data = dat.bcg)

## Fit a random-effects model
fit <- rma(yi, vi, data = dat)

## Compute likelihood profile
pr <- profile(fit)
```

Here `profile()` is calculated sequentially. To calculate in
parallel, we can pipe to `futurize()`:

```r
library(futurize)
library(metafor)

dat <- escalc(measure = "RR", ai = tpos, bi = tneg,
              ci = cpos, di = cneg, data = dat.bcg)
fit <- rma(yi, vi, data = dat)
pr <- profile(fit) |> futurize()
```

This will distribute the profile computations across the available
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

The following **metafor** functions are supported by `futurize()`:

* `profile()` for 'rma.uni', 'rma.mv', 'rma.ls', and 'rma.uni.selmodel'
* `rstudent()` for 'rma.mv'
* `cooks.distance()` for 'rma.mv'
* `dfbetas()` for 'rma.mv'


[metafor]: https://cran.r-project.org/package=metafor
[other parallel backends]: https://www.futureverse.org/backends.html
