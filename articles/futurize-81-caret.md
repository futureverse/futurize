# Parallelize 'caret' functions

![The 'caret' image](../reference/figures/cran-caret-logo.webp)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.webp)= ![The
'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(caret)

ctrl <- trainControl(method = "cv", number = 10)
model <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[caret](https://cran.r-project.org/package=caret)** functions such as
[`train()`](https://rdrr.io/pkg/caret/man/train.html).

The **[caret](https://cran.r-project.org/package=caret)** package
provides a rich set of machine-learning tools with a unified API. The
[`train()`](https://rdrr.io/pkg/caret/man/train.html) function fits
models using cross-validation or bootstrap resampling, making it an
excellent candidate for parallelization.

### Example: Training a random forest with cross-validation

The [`train()`](https://rdrr.io/pkg/caret/man/train.html) function fits
models across multiple resampling iterations:

``` r

library(caret)

## Set up 10-fold cross-validation
ctrl <- trainControl(method = "cv", number = 10)

## Train a random forest model
model <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl)
```

Here [`train()`](https://rdrr.io/pkg/caret/man/train.html) evaluates
sequentially, but we can easily make it evaluate in parallel by piping
to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)
library(caret)

ctrl <- trainControl(method = "cv", number = 10)
model <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()
```

This will distribute the cross-validation folds across the available
parallel workers, given that we have set up parallel workers, e.g.

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

The following **caret** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`bag()`](https://rdrr.io/pkg/caret/man/bag.html)
- [`gafs()`](https://rdrr.io/pkg/caret/man/gafs.default.html)
- [`nearZeroVar()`](https://rdrr.io/pkg/caret/man/nearZeroVar.html)
- [`rfe()`](https://rdrr.io/pkg/caret/man/rfe.html)
- [`safs()`](https://rdrr.io/pkg/caret/man/safs.html)
- [`sbf()`](https://rdrr.io/pkg/caret/man/sbf.html)
- [`train()`](https://rdrr.io/pkg/caret/man/train.html)
