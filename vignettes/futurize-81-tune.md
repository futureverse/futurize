<!--
%\VignetteIndexEntry{Parallelize 'tune' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{tune}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
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
library(tune)

wf <- workflow() |>
  workflows::add_formula(Species ~ .) |>
  workflows::add_model(decision_tree(mode = "classification") |> set_engine("rpart"))

folds <- rsample::vfold_cv(iris, v = 5)
result <- tune::fit_resamples(wf, resamples = folds) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize **[tune]**
functions such as `tune_grid()` and `fit_resamples()`.

The **[tune]** package provides tidy tuning tools for fitting and evaluating
models across resamples and hyperparameter grids. Functions like
`tune_grid()` and `fit_resamples()` iterate over resamples, making
them excellent candidates for parallelization.


## Example: Fitting resamples in parallel

The `fit_resamples()` function fits a model across resampling
iterations:

```r
library(tune)
library(parsnip)
library(workflows)
library(rsample)

spec <- decision_tree(mode = "classification") |> set_engine("rpart")
wf <- workflow() |>
  workflows::add_formula(Species ~ .) |>
  workflows::add_model(spec)

folds <- vfold_cv(iris, v = 5)
result <- fit_resamples(wf, resamples = folds)
```

Here `fit_resamples()` evaluates sequentially, but we can easily make
it evaluate in parallel by piping to `futurize()`:

```r
library(futurize)

result <- fit_resamples(wf, resamples = folds) |> futurize()
```


## Example: Grid tuning in parallel

The `tune_grid()` function evaluates a model across a grid of
hyperparameters:

```r
spec <- decision_tree(mode = "classification", cost_complexity = tune()) |>
  set_engine("rpart")
wf <- workflow() |>
  workflows::add_formula(Species ~ .) |>
  workflows::add_model(spec)

grid <- dials::grid_regular(dials::cost_complexity(), levels = 5)
result <- tune_grid(wf, resamples = folds, grid = grid) |> futurize()
```

This will distribute the work across the available parallel workers,
given that we have set up parallel workers, e.g.

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

The following **tune** functions are supported by `futurize()`:

* `fit_resamples()`
* `last_fit()`
* `tune_bayes()`
* `tune_grid()`


[tune]: https://cran.r-project.org/package=tune
[other parallel backends]: https://www.futureverse.org/backends.html
