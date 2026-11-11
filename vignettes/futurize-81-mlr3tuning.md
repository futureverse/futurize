<!--
%\VignetteIndexEntry{Parallelize 'mlr3tuning' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{mlr3tuning}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-mlr3-logo.webp" alt="The 'mlr3' hexlogo, which is also used by 'mlr3tuning'">
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
library(mlr3tuning)

task <- tsk("penguins")
learner <- lrn("classif.rpart", cp = to_tune(1e-4, 1e-1, logscale = TRUE))
tuner <- tnr("random_search", batch_size = 10)
instance <- tune(tuner, task, learner, rsmp("cv", folds = 3), msr("classif.ce"),
                 term_evals = 20) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
**[mlr3tuning]** functions such as `tune()` and `tune_nested()`.

The **[mlr3tuning]** package provides hyperparameter tuning for the
**[mlr3]** machine-learning framework. Tuning evaluates a learner for
many hyperparameter configurations, where each evaluation involves
resampling, e.g. cross-validation. This quickly adds up to a large
number of model fits, which makes tuning an ideal candidate for
parallelization.


## Example: Tuning a learner

The `tune()` function searches for the best hyperparameter
configuration of a learner. Batch tuners, such as random search and
grid search, propose a batch of configurations at the time, which are
then evaluated by resampling. All resampling iterations of all
configurations in a batch are processed in parallel. The number of
configurations per batch is controlled by the `batch_size` argument
of the tuner:

```r
library(futurize)
library(mlr3tuning)

task <- tsk("penguins")
learner <- lrn("classif.rpart", cp = to_tune(1e-4, 1e-1, logscale = TRUE))
tuner <- tnr("random_search", batch_size = 10)

instance <- tune(tuner, task, learner, rsmp("cv", folds = 3), msr("classif.ce"),
                 term_evals = 20) |> futurize()
instance$result
```

The evaluations are processed in parallel by the workers defined by
your current `plan()`. For example, to parallelize on your local
machine:

```r
plan(multisession)
```


## Example: Nested resampling

The `tune_nested()` function estimates the performance of a tuned
learner using nested resampling, where tuning is performed in an
inner resampling loop for each iteration of an outer resampling loop:

```r
library(futurize)
library(mlr3tuning)

task <- tsk("penguins")
learner <- lrn("classif.rpart", cp = to_tune(1e-4, 1e-1, logscale = TRUE))
tuner <- tnr("random_search", batch_size = 10)

rr <- tune_nested(tuner, task, learner,
                  inner_resampling = rsmp("cv", folds = 3),
                  outer_resampling = rsmp("cv", folds = 5),
                  measure = msr("classif.ce"), term_evals = 20) |> futurize()
rr$aggregate()
```

Here, the outer resampling iterations are processed in parallel. To
protect against overloading the machine, the inner tuning runs
sequentially on each parallel worker, unless you use a nested future
plan. See the 'Future Topologies' vignette of the **[future]**
package for details.


# Details

The **mlr3tuning** package evaluates each batch of hyperparameter
configurations using `mlr3::benchmark()`, which parallelizes via
**[future.apply]**. As explained in the 'mlr3' vignette of
**futurize**, piping to `futurize()` guarantees that **mlr3**
parallelizes via futures, even if mirai daemons have been set up for
**mlr3**. Also, the `futurize()` options `globals` and `packages` are
ignored, because **mlr3** manages those itself, and parallel random
number generation (`seed = TRUE`) is always used.

Asynchronous tuners, e.g. `tnr("async_random_search")`, are _not_
supported. They run on **rush** workers, which do not use futures.
If you try to futurize `tune()` or `tune_nested()` with an
asynchronous tuner, an error is produced.


# Supported Functions

The following **mlr3tuning** functions are supported by `futurize()`:

* `tune()` with `seed = TRUE` as the default
* `tune_nested()` with `seed = TRUE` as the default


[mlr3]: https://cran.r-project.org/package=mlr3
[mlr3tuning]: https://cran.r-project.org/package=mlr3tuning
[future.apply]: https://cran.r-project.org/package=future.apply
[future]: https://cran.r-project.org/package=future
