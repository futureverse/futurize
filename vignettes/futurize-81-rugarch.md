<!--
%\VignetteIndexEntry{Parallelize 'rugarch' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{rugarch}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
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
library(rugarch)

data(sp500ret, package = "rugarch")
spec <- ugarchspec()
roll <- ugarchroll(spec, sp500ret, n.start = 1000, refit.window = "moving", refit.every = 100) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize **[rugarch]**
functions such as `ugarchroll()`, `ugarchdistribution()`, and `ugarchboot()`.

The **[rugarch]** package provides a comprehensive set of methods for
Generalized Autoregressive Conditional Heteroskedasticity (GARCH)
modeling. Many of its functions, especially those involving
rolling estimation or bootstrapping, are computationally intensive and
benefit greatly from parallelization.


## Example: Rolling GARCH estimation

The `ugarchroll()` function performs rolling estimation and
forecasting. This can be time-consuming as it involves multiple fits
of the GARCH model.

```r
library(futurize)
plan(multisession)
library(rugarch)

data(sp500ret, package = "rugarch")
spec <- ugarchspec()

## Perform rolling estimation
roll <- ugarchroll(spec, sp500ret, n.start = 1000, 
                   refit.window = "moving", refit.every = 100) |> futurize()
```


## Example: GARCH parameter distribution

The `ugarchdistribution()` function simulates and estimates the
parameter distribution of a GARCH model.

```r
library(futurize)
plan(multisession)
library(rugarch)

data(sp500ret, package = "rugarch")
spec <- ugarchspec()
fit <- ugarchfit(spec, sp500ret)

## Estimate parameter distribution
dist <- ugarchdistribution(fit, n.sim = 100, n.hist = 10) |> futurize()
```


# Supported Functions

The following **rugarch** functions are supported by `futurize()`:

* `arfimacv()` with `seed = TRUE` as the default
* `arfimadistribution()` with `seed = TRUE` as the default
* `arfimaroll()` with `seed = TRUE` as the default
* `autoarfima()` with `seed = TRUE` as the default
* `multifilter()` with `seed = TRUE` as the default
* `multifit()` with `seed = TRUE` as the default
* `multiforecast()` with `seed = TRUE` as the default
* `ugarchboot()` with `seed = TRUE` as the default
* `ugarchdistribution()` with `seed = TRUE` as the default
* `ugarchroll()` with `seed = TRUE` as the default


# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize `ugarchroll()` using
the **parallel** package directly, without **futurize**:

```r
library(rugarch)
library(parallel)

data(sp500ret, package = "rugarch")
spec <- ugarchspec()

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)

## Run rolling estimation in parallel
roll <- ugarchroll(spec, sp500ret, n.start = 1000, 
                   refit.window = "moving", refit.every = 100,
                   cluster = cl)

## Tear down the cluster
stopCluster(cl)
```

This requires you to manually create and manage the cluster
lifecycle. If you forget to call `stopCluster()`, or if your code
errors out before reaching it, you leak background R processes. You
also have to decide upfront how many CPUs to use and what cluster
type to use. Switching to another parallel backend, e.g. a Slurm
cluster, would require a completely different setup. With
**futurize**, all of this is handled for you - just pipe to
`futurize()` and control the backend with `plan()`.


[rugarch]: https://cran.r-project.org/package=rugarch
