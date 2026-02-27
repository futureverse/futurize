# Parallelize 'lme4' functions

![The 'lme4' image](../reference/figures/cran-lme4-logo.svg)+ ![The
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
library(lme4)

gm <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
             data = cbpp, family = binomial)
gm_all <- allFit(gm) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[lme4](https://cran.r-project.org/package=lme4)** functions such as
[`allFit()`](https://rdrr.io/pkg/lme4/man/allFit.html) and
[`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html).

The **[lme4](https://cran.r-project.org/package=lme4)** package fits
linear and generalized linear mixed-effects models. Its
[`allFit()`](https://rdrr.io/pkg/lme4/man/allFit.html) function fits
models using all available optimizers to check for convergence issues,
and [`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html) performs
parametric bootstrap inference. Both are excellent candidates for
parallelization.

### Example: Fitting with multiple optimizers

The [`allFit()`](https://rdrr.io/pkg/lme4/man/allFit.html) function fits
a model with each available optimizer, which can be done in parallel:

``` r

library(lme4)

## Fit a generalized linear mixed model
gm <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
            data = cbpp, family = binomial)

## Try all available optimizers
gm_all <- allFit(gm)
```

Here [`allFit()`](https://rdrr.io/pkg/lme4/man/allFit.html) evaluates
sequentially, but we can easily make it evaluate in parallel by piping
to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)
library(lme4)

gm <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
            data = cbpp, family = binomial)
gm_all <- allFit(gm) |> futurize()
```

This will distribute the optimizer fits across the available parallel
workers, given that we have set up parallel workers, e.g.

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

### Example: Parametric bootstrap

The [`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html) function
performs parametric bootstrap inference on fitted models:

``` r

library(futurize)
plan(multisession)
library(lme4)

## Fit a linear mixed model
fm <- lmer(Reaction ~ Days + (Days | Subject), data = sleepstudy)

## Bootstrap the fixed-effect coefficients
boot_coef <- function(model) fixef(model)
b <- bootMer(fm, boot_coef, nsim = 100) |> futurize()
```

## Supported Functions

The following **lme4** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`allFit()`](https://rdrr.io/pkg/lme4/man/allFit.html)
- [`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html)
