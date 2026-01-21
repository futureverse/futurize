<!--
%\VignetteIndexEntry{Parallelize 'caret' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{caret}
%\VignetteKeyword{vignette}
%\VignetteKeyword{handlers}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-caret-logo.svg" alt="The 'caret' image">
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
library(caret)

ctrl <- trainControl(method = "cv", number = 10)
model <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize **[caret]**
functions such as `train()`.

The **[caret]** package provides a rich set of machine-learning tools
with a unified API. The `train()` function fits models using
cross-validation or bootstrap resampling, making it an excellent
candidate for parallelization.


## Example: Training a random forest with cross-validation

The `train()` function fits models across multiple resampling
iterations:

```r
library(caret)

## Set up 10-fold cross-validation
ctrl <- trainControl(method = "cv", number = 10)

## Train a random forest model
model <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl)
```

Here `train()` evaluates sequentially, but we can easily make it
evaluate in parallel by piping to `futurize()`:

```r
library(futurize)
library(caret)

ctrl <- trainControl(method = "cv", number = 10)
model <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()
```

This will distribute the cross-validation folds across the available
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

The following **caret** functions are supported by `futurize()`:

* `bag()`
* `gafs()`
* `nearZeroVar()`
* `rfe()`
* `safs()`
* `sbf()`
* `train()`


[caret]: https://cran.r-project.org/package=caret
[other parallel backends]: https://www.futureverse.org/backends.html
