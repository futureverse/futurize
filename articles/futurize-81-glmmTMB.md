# Parallelize 'glmmTMB' functions

![The CRAN 'glmmTMB'
package](../reference/figures/cran-glmmTMB-logo.svg)+ ![The 'futurize'
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
library(glmmTMB)

m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)
pr <- profile(m) |> futurize()
```

## Introduction

This vignette demonstrates how to parallelize
**[glmmTMB](https://cran.r-project.org/package=glmmTMB)** functions such
as [`profile()`](https://rdrr.io/r/stats/profile.html) through
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md).

The **[glmmTMB](https://cran.r-project.org/package=glmmTMB)** package
fits generalized linear mixed models (GLMMs) using Template Model
Builder (TMB). Its [`profile()`](https://rdrr.io/r/stats/profile.html)
function computes likelihood profiles for model parameters. These
computations are performed independently for each parameter, making them
candidates for parallelization.

### Example: Likelihood profile

The [`profile()`](https://rdrr.io/r/stats/profile.html) function
computes the likelihood profile for each model parameter. For example,
using the built-in `Salamanders` dataset to model salamander counts:

``` r

library(glmmTMB)

## Fit a negative binomial GLMM
m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)

## Compute likelihood profile
pr <- profile(m)
```

Here [`profile()`](https://rdrr.io/r/stats/profile.html) is calculated
sequentially. To calculated in parallel, we can pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)
library(glmmTMB)

m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)
pr <- profile(m) |> futurize()
```

This will distribute the per-parameter profile computations across the
available parallel workers, given that we have set up parallel workers,
e.g.

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

The following **glmmTMB** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`profile()`](https://rdrr.io/r/stats/profile.html) for ‘glmmTMB’
