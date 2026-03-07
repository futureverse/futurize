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
<img src="../man/figures/cran-glmmTMB-logo.svg" alt="The CRAN 'glmmTMB' package">
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
library(glmmTMB)

m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)
ci <- confint(m, method = "profile") |> futurize()
```


# Introduction

This vignette demonstrates how to parallelize **[glmmTMB]** functions
such as `confint()` and `profile()` through `futurize()`.

The **[glmmTMB]** package fits generalized linear mixed models (GLMMs)
using Template Model Builder (TMB). Its `confint()` and `profile()`
functions compute confidence intervals and likelihood profiles for
model parameters. When using `method = "profile"` or `method =
"uniroot"`, these computations are performed independently for each
parameter, making them candidates for parallelization.


## Example: Profile likelihood confidence intervals

The `confint()` function computes confidence intervals for parameters
of a fitted `glmmTMB` model. Using `method = "profile"` runs a profile
likelihood for each parameter. For example, using the built-in
`Salamanders` dataset to model salamander counts:

```r
library(glmmTMB)

## Fit a negative binomial GLMM
m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)

## Compute profile likelihood confidence intervals
ci <- confint(m, method = "profile")
```

Here `confint()` is calculated sequentially. To calculated in
parallel, we can pipe to `futurize()`:

```r
library(futurize)
library(glmmTMB)

m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)
ci <- confint(m, method = "profile") |> futurize()
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


## Example: Likelihood profile

The `profile()` function computes the likelihood profile for each
model parameter, which `confint()` uses internally when `method =
"profile"`. We can call it directly and parallelize it using:

```r
library(futurize)
plan(multisession)
library(glmmTMB)

m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)
pr <- profile(m) |> futurize()
```


# Supported Functions

The following **glmmTMB** functions are supported by `futurize()`:

* `confint()` for 'glmmTMB' (with `method = "profile"` or `method = "uniroot"`)
* `profile()` for 'glmmTMB'


[glmmTMB]: https://cran.r-project.org/package=glmmTMB
[other parallel backends]: https://www.futureverse.org/backends.html
