<!--
%\VignetteIndexEntry{Parallelize 'shapr' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{shapr}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/futurize-logo.png" alt="The 'futurize' hexlogo">
<span>+</span>
<img src="../man/figures/future-logo.png" alt="The 'future' logo">
</div>

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!


# TL;DR

```r
library(futurize)
plan(multisession)
library(shapr)

result <- explain(
  model = model,
  x_explain = x_explain,
  x_train = x_train,
  approach = "empirical",
  phi0 = mean(y_train)
) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
**[shapr]** functions such as `explain()`.

The **[shapr]** package implements dependence-aware Shapley values for
explaining predictions from machine learning models. Its `explain()`
function computes Shapley value estimates by evaluating conditional
expectations across multiple coalitions of features, making the
computation an excellent candidate for parallelization.


## Example: Computing Shapley values in parallel

The `explain()` function computes Shapley values for a set of
observations. For example, using a simple linear model:

```r
library(shapr)

## Fit a model
x_train <- data.frame(x1 = rnorm(100), x2 = rnorm(100))
y_train <- 2 * x_train$x1 + x_train$x2 + rnorm(100)
model <- lm(y_train ~ x1 + x2, data = x_train)

## Explain predictions
x_explain <- data.frame(x1 = rnorm(5), x2 = rnorm(5))
result <- explain(
  model = model,
  x_explain = x_explain,
  x_train = x_train,
  approach = "empirical",
  phi0 = mean(y_train)
)
```

Here `explain()` evaluates the coalitions sequentially, but we can
easily make it evaluate them in parallel by piping to `futurize()`:

```r
library(futurize)
library(shapr)

result <- explain(
  model = model,
  x_explain = x_explain,
  x_train = x_train,
  approach = "empirical",
  phi0 = mean(y_train)
) |> futurize()
```

This will distribute the coalition computations across the available
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

The following **shapr** functions are supported by `futurize()`:

* `explain()`
* `explain_forecast()`


[shapr]: https://cran.r-project.org/package=shapr
[other parallel backends]: https://www.futureverse.org/backends.html
