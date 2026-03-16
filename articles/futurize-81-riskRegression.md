# Parallelize 'riskRegression' functions

![The 'riskRegression'
image](../reference/figures/cran-riskRegression-logo.svg)+ ![The
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
library(riskRegression)
library(survival)

set.seed(42)
d <- sampleData(200, outcome = "competing.risks")
fit <- CSC(Hist(time, event) ~ X1 + X2 + X7 + X8, data = d)
sc <- Score(list("CSC" = fit), data = d,
            formula = Hist(time, event) ~ 1,
            times = 5, B = 100, split.method = "bootcv") |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[riskRegression](https://cran.r-project.org/package=riskRegression)**
functions such as
[`Score()`](https://rdrr.io/pkg/riskRegression/man/Score.html).

The
**[riskRegression](https://cran.r-project.org/package=riskRegression)**
package provides tools for risk regression modeling and prediction in
survival analysis with competing risks. It supports fitting
cause-specific Cox regression models, Fine-Gray regression, and absolute
risk regression models. The
[`Score()`](https://rdrr.io/pkg/riskRegression/man/Score.html) function
performs bootstrap cross-validation for model evaluation, which is an
excellent candidate for parallelization.

### Example: Bootstrap cross-validation with Score()

The [`Score()`](https://rdrr.io/pkg/riskRegression/man/Score.html)
function evaluates prediction models via bootstrap cross-validation with
metrics such as time-dependent AUC and Brier scores:

``` r

library(riskRegression)
library(survival)

set.seed(42)
d <- sampleData(200, outcome = "competing.risks")
fit <- CSC(Hist(time, event) ~ X1 + X2 + X7 + X8, data = d)

## Bootstrap cross-validation with 100 bootstrap samples
sc <- Score(list("CSC" = fit), data = d,
            formula = Hist(time, event) ~ 1,
            times = 5, B = 100, split.method = "bootcv")
```

Here [`Score()`](https://rdrr.io/pkg/riskRegression/man/Score.html)
evaluates sequentially, but we can easily make it evaluate in parallel
by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)
library(riskRegression)
library(survival)

set.seed(42)
d <- sampleData(200, outcome = "competing.risks")
fit <- CSC(Hist(time, event) ~ X1 + X2 + X7 + X8, data = d)

sc <- Score(list("CSC" = fit), data = d,
            formula = Hist(time, event) ~ 1,
            times = 5, B = 100, split.method = "bootcv") |> futurize()
```

This will distribute the bootstrap samples across the available parallel
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

## Supported Functions

The following **riskRegression** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`Score()`](https://rdrr.io/pkg/riskRegression/man/Score.html) for
  ‘list’
