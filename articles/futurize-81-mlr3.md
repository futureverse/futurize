# Parallelize 'mlr3' functions

![The 'mlr3' hexlogo](../reference/figures/cran-mlr3-logo.webp)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.webp)= ![The
'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`mlr3`](https://mlr3.mlr-org.com)`)`\
\
`task`` ``<-`` `[`tsk`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"penguins"``)`\
`learner`` ``<-`` `[`lrn`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"classif.rpart"``)`\
`resampling`` ``<-`` `[`rsmp`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"cv"``, folds ``=`` ``10``)`\
`rr`` ``<-`` `[`resample`](https://mlr3.mlr-org.com/reference/resample.html)`(``task``, ``learner``, ``resampling``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[mlr3](https://cran.r-project.org/package=mlr3)** functions such as
[`resample()`](https://mlr3.mlr-org.com/reference/resample.html) and
[`benchmark()`](https://mlr3.mlr-org.com/reference/benchmark.html).

The **[mlr3](https://cran.r-project.org/package=mlr3)** package is a
modern, object-oriented framework for machine learning in R. It provides
a unified interface to many learning algorithms, together with tools for
resampling, benchmarking, and model evaluation. Resampling and
benchmarking fit and evaluate a model once per resampling iteration,
which can be computationally intensive. Since these iterations are
independent of each other, they are ideal candidates for
parallelization.

### Example: Cross-validating a learner

The [`resample()`](https://mlr3.mlr-org.com/reference/resample.html)
function fits a learner on each training set of a resampling strategy
and evaluates it on the corresponding test set. For example, 10-fold
cross-validation of a classification tree results in ten independent
model fits:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`mlr3`](https://mlr3.mlr-org.com)`)`\
\
`task`` ``<-`` `[`tsk`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"penguins"``)`\
`learner`` ``<-`` `[`lrn`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"classif.rpart"``)`\
`resampling`` ``<-`` `[`rsmp`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"cv"``, folds ``=`` ``10``)`\
\
`rr`` ``<-`` `[`resample`](https://mlr3.mlr-org.com/reference/resample.html)`(``task``, ``learner``, ``resampling``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`rr``$``aggregate``(`[`msr`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"classif.ce"``)``)`

The iterations are processed in parallel by the workers defined by your
current [`plan()`](https://future.futureverse.org/reference/plan.html).
For example, to parallelize on your local machine:

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`

### Example: Benchmarking multiple learners

The [`benchmark()`](https://mlr3.mlr-org.com/reference/benchmark.html)
function runs multiple resampling experiments, e.g. to compare several
learners on one or more tasks:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`mlr3`](https://mlr3.mlr-org.com)`)`\
\
`design`` ``<-`` `[`benchmark_grid`](https://mlr3.mlr-org.com/reference/benchmark_grid.html)`(`\
`  tasks ``=`` `[`tsk`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"penguins"``)``,`\
`  learners ``=`` `[`lrns`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"classif.rpart"``, ``"classif.featureless"``)``)``,`\
`  resamplings ``=`` `[`rsmp`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"cv"``, folds ``=`` ``10``)`\
`)`\
\
`bmr`` ``<-`` `[`benchmark`](https://mlr3.mlr-org.com/reference/benchmark.html)`(``design``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`bmr``$``aggregate``(`[`msr`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"classif.ce"``)``)`

All resampling iterations across all experiments are processed in
parallel.

## Details

The **mlr3** package already parallelizes
[`resample()`](https://mlr3.mlr-org.com/reference/resample.html) and
[`benchmark()`](https://mlr3.mlr-org.com/reference/benchmark.html) via
**[future.apply](https://cran.r-project.org/package=future.apply)**,
using the future backend set by
[`plan()`](https://future.futureverse.org/reference/plan.html). It is
also possible to configure **mlr3** to parallelize via
**[mirai](https://cran.r-project.org/package=mirai)** instead, by
setting up mirai daemons for the `"mlr3_parallelization"` compute
profile. When you pipe one of these functions to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md),
**mlr3** is guaranteed to parallelize via futures, even if mirai daemons
have been set up for **mlr3**, e.g. by other code in your R session.

The **mlr3** package itself decides which globals and packages to export
to the parallel workers, and it always uses parallel random number
generation (`seed = TRUE`). Because of this,
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
options `globals` and `packages` are ignored for **mlr3** functions.
Other future options, e.g. `chunk_size` and `stdout`, are passed on
as-is, e.g.

\
`rr`` ``<-`` `[`resample`](https://mlr3.mlr-org.com/reference/resample.html)`(``task``, ``learner``, ``resampling``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``chunk_size ``=`` ``5``)`

## Supported Functions

The following **mlr3** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`benchmark()`](https://mlr3.mlr-org.com/reference/benchmark.html)
  with `seed = TRUE` as the default
- [`resample()`](https://mlr3.mlr-org.com/reference/resample.html) with
  `seed = TRUE` as the default
