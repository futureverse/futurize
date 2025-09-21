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
library(caret)
library(futurize)
plan(multisession)

ctrl <- trainControl(method = "cv", number = 10)
model <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()
```


# Introduction

This vignette demonstrates how use this approach to parallelize **[caret]**
functions such as `train()``.


# Background

The **caret** `llply()` function is commonly used to apply a function to
the elements of a list and return a list. For example, 

```r
library(caret)

ctrl <- trainControl(method = "cv", number = 10)
model <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl)
```

Here `train()` evaluates sequentially, but we can easily make it to
evaluate parallelly, by using:

```r
library(futurize)
library(caret)

ctrl <- trainControl(method = "cv", number = 10)
model <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize() |> futurize()
```

This will distribute the calculations across the available parallel
workers, given that we have set parallel workers, e.g.

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and it works on all operating system. There are [other
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

The `futurize()` function supports parallelization of the common base
R functions. The following **caret** functions are supported:

* `allFit()`
* `bootMer()`


[caret]: https://cran.r-project.org/package=caret
