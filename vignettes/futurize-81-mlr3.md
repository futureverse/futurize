<!--
%\VignetteIndexEntry{Parallelize 'mlr3' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{mlr3}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-mlr3-logo.webp" alt="The 'mlr3' hexlogo">
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
library(mlr3)

task <- tsk("penguins")
learner <- lrn("classif.rpart")
resampling <- rsmp("cv", folds = 10)
rr <- resample(task, learner, resampling) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
**[mlr3]** functions such as `resample()` and `benchmark()`.

The **[mlr3]** package is a modern, object-oriented framework for
machine learning in R. It provides a unified interface to many
learning algorithms, together with tools for resampling,
benchmarking, and model evaluation. Resampling and benchmarking
fit and evaluate a model once per resampling iteration, which can
be computationally intensive. Since these iterations are independent
of each other, they are ideal candidates for parallelization.


## Example: Cross-validating a learner

The `resample()` function fits a learner on each training set of a
resampling strategy and evaluates it on the corresponding test set.
For example, 10-fold cross-validation of a classification tree
results in ten independent model fits:

```r
library(futurize)
library(mlr3)

task <- tsk("penguins")
learner <- lrn("classif.rpart")
resampling <- rsmp("cv", folds = 10)

rr <- resample(task, learner, resampling) |> futurize()
rr$aggregate(msr("classif.ce"))
```

The iterations are processed in parallel by the workers defined
by your current `plan()`. For example, to parallelize on your local
machine:

```r
plan(multisession)
```


## Example: Benchmarking multiple learners

The `benchmark()` function runs multiple resampling experiments,
e.g. to compare several learners on one or more tasks:

```r
library(futurize)
library(mlr3)

design <- benchmark_grid(
  tasks = tsk("penguins"),
  learners = lrns(c("classif.rpart", "classif.featureless")),
  resamplings = rsmp("cv", folds = 10)
)

bmr <- benchmark(design) |> futurize()
bmr$aggregate(msr("classif.ce"))
```

All resampling iterations across all experiments are processed in
parallel.


# Details

The **mlr3** package already parallelizes `resample()` and
`benchmark()` via **[future.apply]**, using the future backend set
by `plan()`. It is also possible to configure **mlr3** to
parallelize via **[mirai]** instead, by setting up mirai daemons for
the `"mlr3_parallelization"` compute profile. When you pipe one of
these functions to `futurize()`, **mlr3** is guaranteed to
parallelize via futures, even if mirai daemons have been set up for
**mlr3**, e.g. by other code in your R session.

The **mlr3** package itself decides which globals and packages to
export to the parallel workers, and it always uses parallel random
number generation (`seed = TRUE`). Because of this, `futurize()`
options `globals` and `packages` are ignored for **mlr3** functions.
Other future options, e.g. `chunk_size` and `stdout`, are passed on
as-is, e.g.

```r
rr <- resample(task, learner, resampling) |> futurize(chunk_size = 5)
```


# Supported Functions

The following **mlr3** functions are supported by `futurize()`:

* `benchmark()` with `seed = TRUE` as the default
* `resample()` with `seed = TRUE` as the default


[mlr3]: https://cran.r-project.org/package=mlr3
[future.apply]: https://cran.r-project.org/package=future.apply
[mirai]: https://cran.r-project.org/package=mirai
