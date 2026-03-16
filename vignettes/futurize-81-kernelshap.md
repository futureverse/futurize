<!--
%\VignetteIndexEntry{Parallelize 'kernelshap' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{kernelshap}
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
library(kernelshap)

ks <- kernelshap(
  model, X = x_explain, bg_X = bg_X
) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
**[kernelshap]** functions such as `kernelshap()` and `permshap()`.

The **[kernelshap]** package provides efficient implementations of
Kernel SHAP and permutation SHAP for explaining predictions from any
machine learning model. These functions iterate over observations to
compute Shapley value estimates, making the computation an excellent
candidate for parallelization.


## Example: Computing Kernel SHAP values in parallel

The `kernelshap()` function computes Kernel SHAP values for a set of
observations. For example, using a simple linear model:

```r
library(kernelshap)

## Fit a model
x_train <- data.frame(x1 = rnorm(100), x2 = rnorm(100))
y_train <- 2 * x_train$x1 + x_train$x2 + rnorm(100)
model <- lm(y_train ~ ., data = cbind(y = y_train, x_train))

## Compute Kernel SHAP values
x_explain <- x_train[1:5, ]
bg_X <- x_train[1:20, ]
ks <- kernelshap(model, X = x_explain, bg_X = bg_X)
```

Here `kernelshap()` processes observations sequentially, but we can
easily make it process them in parallel by piping to `futurize()`:

```r
library(futurize)
library(kernelshap)

ks <- kernelshap(
  model, X = x_explain, bg_X = bg_X
) |> futurize()
```

This will distribute the observation-level computations across the
available parallel workers, given that we have set up parallel
workers, e.g.

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


## Example: Computing permutation SHAP values in parallel

The `permshap()` function works the same way:

```r
library(futurize)
library(kernelshap)

ps <- permshap(
  model, X = x_explain, bg_X = bg_X
) |> futurize()
```


# Supported Functions

The following **kernelshap** functions are supported by `futurize()`:

* `kernelshap()`
* `permshap()`


[kernelshap]: https://cran.r-project.org/package=kernelshap
[other parallel backends]: https://www.futureverse.org/backends.html
