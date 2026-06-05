# Parallelize 'sandwich' functions

![The 'sandwich' image](../reference/figures/cran-sandwich-logo.webp)+
![The 'futurize' hexlogo](../reference/figures/futurize-logo.webp)=
![The 'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(sandwich)

fm <- lm(dist ~ speed, data = cars)
v <- vcovBS(fm) |> futurize()
```

## Introduction

The **[sandwich](https://cran.r-project.org/package=sandwich)** package
provides model-agnostic robust covariance matrix estimators.

### Example: Clustered bootstrap covariance matrix

Example adopted from
[`help("vcovBS", package = "sandwich")`](https://rdrr.io/pkg/sandwich/man/vcovBS.html):

``` r

library(futurize)
plan(multisession)
library(sandwich)

## fit a simple linear model
fm <- lm(dist ~ speed, data = cars)

## bootstrap covariance matrix estimation in parallel
v <- vcovBS(fm, R = 250) |> futurize()

## summary of coefficients with robust standard errors
library(lmtest)
coeftest(fm, vcov = v)
```

This will parallelize the bootstrap replications, given that we have set
up parallel workers, e.g.

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

The following **sandwich** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`vcovBS()`](https://rdrr.io/pkg/sandwich/man/vcovBS.html) with
  `seed = TRUE` as the default
- [`vcovJK()`](https://rdrr.io/pkg/sandwich/man/vcovJK.html) with
  `seed = TRUE` as the default

## Without futurize: Manual setup

For comparison, here is what it takes to parallelize
[`vcovBS()`](https://rdrr.io/pkg/sandwich/man/vcovBS.html) using the
**sandwich** package directly, without **futurize**:

``` r

library(sandwich)
library(parallel)

## Fit a simple linear model
fm <- lm(dist ~ speed, data = cars)

## Bootstrap covariance matrix estimation in parallel using cores
v <- vcovBS(fm, R = 250, cores = 4L)
```

While **sandwich** has a built-in `cores` argument, it only supports
local multicore or PSOCK clusters depending on the OS. With
**futurize**, you can use any `future` backend, including remote
clusters and HPC environments, just by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
and controlling the backend with
[`plan()`](https://future.futureverse.org/reference/plan.html).
