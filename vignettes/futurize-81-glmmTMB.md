<!--
%\VignetteIndexEntry{Parallelize 'glmmTMB' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{glmmTMB}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-glmmTMB-logo.webp" alt="The CRAN 'glmmTMB' package">
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
library(glmmTMB)

m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)
pr <- profile(m) |> futurize()
```


# Introduction

This vignette demonstrates how to parallelize **[glmmTMB]** functions
such as `profile()` through `futurize()`.

The **[glmmTMB]** package fits generalized linear mixed models (GLMMs)
using Template Model Builder (TMB). Its `profile()` function computes
likelihood profiles for model parameters. These computations are
performed independently for each parameter, making them candidates for
parallelization.


## Example: Likelihood profile

The `profile()` function computes the likelihood profile for each
model parameter. For example, using the built-in `Salamanders` dataset
to model salamander counts:

```r
library(glmmTMB)

## Fit a negative binomial GLMM
m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)

## Compute likelihood profile
pr <- profile(m)
```

Here `profile()` is calculated sequentially. To calculate in
parallel, we can pipe to `futurize()`:

```r
library(futurize)
library(glmmTMB)

m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)
pr <- profile(m) |> futurize()
```

This will distribute the per-parameter profile computations across the
available parallel workers, given that we have set up parallel
workers, e.g.

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and works on all operating systems. There are [other parallel
backends] to choose from, including alternatives to parallelize
locally as well as distributed across remote machines, e.g.

```r
plan(future.mirai::mirai_multisession)
```

and

```r
plan(future.batchtools::batchtools_slurm)
```


# Supported Functions

The following **glmmTMB** functions are supported by `futurize()`:

* `profile()` for 'glmmTMB'


# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize `profile()`
using the **parallel** package directly, without **futurize**:

```r
library(glmmTMB)
library(parallel)

## Fit a negative binomial GLMM
m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)

## Compute likelihood profile in parallel
pr <- profile(m, parallel = "snow", ncpus = ncpus, cl = cl)

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


[glmmTMB]: https://cran.r-project.org/package=glmmTMB
[other parallel backends]: https://www.futureverse.org/backends.html
