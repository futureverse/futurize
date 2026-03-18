<!--
%\VignetteIndexEntry{Parallelize 'lme4' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{lme4}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-lme4-logo.webp" alt="The 'lme4' image">
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
library(lme4)

gm <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
             data = cbpp, family = binomial)
gm_all <- allFit(gm) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize **[lme4]**
functions such as `allFit()` and `bootMer()`.

The **[lme4]** package fits linear and generalized linear mixed-effects
models. Its `allFit()` function fits models using all available
optimizers to check for convergence issues, and `bootMer()` performs
parametric bootstrap inference. Both are excellent candidates for
parallelization.


## Example: Fitting with multiple optimizers

The `allFit()` function fits a model with each available optimizer,
which can be done in parallel:

```r
library(lme4)

## Fit a generalized linear mixed model
gm <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
            data = cbpp, family = binomial)

## Try all available optimizers
gm_all <- allFit(gm)
```

Here `allFit()` evaluates sequentially, but we can easily make it
evaluate in parallel by piping to `futurize()`:

```r
library(futurize)
library(lme4)

gm <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
            data = cbpp, family = binomial)
gm_all <- allFit(gm) |> futurize()
```

This will distribute the optimizer fits across the available parallel
workers, given that we have set up parallel workers, e.g.

```r
plan(multisession)
```

Unlike other parallel backends in R, `futurize()` relays standard
output, messages, and warnings produced by the parallel workers back
to your main R session. For instance, when running the above, you
will see the progress output from each optimizer as it completes:

```
> gm_all <- allFit(gm) |> futurize()
bobyqa : [OK]
Nelder_Mead : [OK]
nlminbwrap : [OK]
nmkbw : [OK]
optimx.L-BFGS-B : [OK]
nloptwrap.NLOPT_LN_NELDERMEAD : [OK]
nloptwrap.NLOPT_LN_BOBYQA : [OK]
```

This output originates from the parallel workers and is relayed to
your R session, so you get the same informative feedback as when
running sequentially.

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


## Example: Parametric bootstrap

The `bootMer()` function performs parametric bootstrap inference on
fitted models:

```r
library(futurize)
plan(multisession)
library(lme4)

## Fit a linear mixed model
fm <- lmer(Reaction ~ Days + (Days | Subject), data = sleepstudy)

## Bootstrap the fixed-effect coefficients
boot_coef <- function(model) fixef(model)
b <- bootMer(fm, boot_coef, nsim = 100) |> futurize()
```


# Supported Functions

The following **lme4** functions are supported by `futurize()`:

* `allFit()`
* `bootMer()`
* `influence()` for 'merMod'
* `profile()` for 'merMod'


# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize `bootMer()`
using the **parallel** package directly, without **futurize**:

```r
library(lme4)
library(parallel)

## Fit a linear mixed model
fm <- lmer(Reaction ~ Days + (Days | Subject), data = sleepstudy)

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)

## Bootstrap the fixed-effect coefficients
boot_coef <- function(model) fixef(model)
b <- bootMer(fm, boot_coef, nsim = 100,
             parallel = "snow", ncpus = ncpus, cl = cl)

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


[lme4]: https://cran.r-project.org/package=lme4
[other parallel backends]: https://www.futureverse.org/backends.html
