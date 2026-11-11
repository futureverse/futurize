# Parallelize 'mlr3tuning' functions

![The 'mlr3' hexlogo, which is also used by
'mlr3tuning'](../reference/figures/cran-mlr3-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`mlr3tuning`](https://mlr3tuning.mlr-org.com)`)`\
\
`task`` ``<-`` `[`tsk`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"penguins"``)`\
`learner`` ``<-`` `[`lrn`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"classif.rpart"``, cp ``=`` `[`to_tune`](https://paradox.mlr-org.com/reference/to_tune.html)`(``1e-4``, ``1e-1``, logscale ``=`` ``TRUE``)``)`\
`tuner`` ``<-`` `[`tnr`](https://mlr3tuning.mlr-org.com/reference/tnr.html)`(``"random_search"``, batch_size ``=`` ``10``)`\
`instance`` ``<-`` `[`tune`](https://mlr3tuning.mlr-org.com/reference/tune.html)`(``tuner``, ``task``, ``learner``, `[`rsmp`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"cv"``, folds ``=`` ``3``)``, `[`msr`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"classif.ce"``)``,`\
`                 term_evals ``=`` ``20``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[mlr3tuning](https://cran.r-project.org/package=mlr3tuning)**
functions such as
[`tune()`](https://mlr3tuning.mlr-org.com/reference/tune.html) and
[`tune_nested()`](https://mlr3tuning.mlr-org.com/reference/tune_nested.html).

The **[mlr3tuning](https://cran.r-project.org/package=mlr3tuning)**
package provides hyperparameter tuning for the
**[mlr3](https://cran.r-project.org/package=mlr3)** machine-learning
framework. Tuning evaluates a learner for many hyperparameter
configurations, where each evaluation involves resampling,
e.g. cross-validation. This quickly adds up to a large number of model
fits, which makes tuning an ideal candidate for parallelization.

### Example: Tuning a learner

The [`tune()`](https://mlr3tuning.mlr-org.com/reference/tune.html)
function searches for the best hyperparameter configuration of a
learner. Batch tuners, such as random search and grid search, propose a
batch of configurations at the time, which are then evaluated by
resampling. All resampling iterations of all configurations in a batch
are processed in parallel. The number of configurations per batch is
controlled by the `batch_size` argument of the tuner:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`mlr3tuning`](https://mlr3tuning.mlr-org.com)`)`\
\
`task`` ``<-`` `[`tsk`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"penguins"``)`\
`learner`` ``<-`` `[`lrn`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"classif.rpart"``, cp ``=`` `[`to_tune`](https://paradox.mlr-org.com/reference/to_tune.html)`(``1e-4``, ``1e-1``, logscale ``=`` ``TRUE``)``)`\
`tuner`` ``<-`` `[`tnr`](https://mlr3tuning.mlr-org.com/reference/tnr.html)`(``"random_search"``, batch_size ``=`` ``10``)`\
\
`instance`` ``<-`` `[`tune`](https://mlr3tuning.mlr-org.com/reference/tune.html)`(``tuner``, ``task``, ``learner``, `[`rsmp`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"cv"``, folds ``=`` ``3``)``, `[`msr`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"classif.ce"``)``,`\
`                 term_evals ``=`` ``20``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`instance``$``result`

The evaluations are processed in parallel by the workers defined by your
current [`plan()`](https://future.futureverse.org/reference/plan.html).
For example, to parallelize on your local machine:

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`

### Example: Nested resampling

The
[`tune_nested()`](https://mlr3tuning.mlr-org.com/reference/tune_nested.html)
function estimates the performance of a tuned learner using nested
resampling, where tuning is performed in an inner resampling loop for
each iteration of an outer resampling loop:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`mlr3tuning`](https://mlr3tuning.mlr-org.com)`)`\
\
`task`` ``<-`` `[`tsk`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"penguins"``)`\
`learner`` ``<-`` `[`lrn`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"classif.rpart"``, cp ``=`` `[`to_tune`](https://paradox.mlr-org.com/reference/to_tune.html)`(``1e-4``, ``1e-1``, logscale ``=`` ``TRUE``)``)`\
`tuner`` ``<-`` `[`tnr`](https://mlr3tuning.mlr-org.com/reference/tnr.html)`(``"random_search"``, batch_size ``=`` ``10``)`\
\
`rr`` ``<-`` `[`tune_nested`](https://mlr3tuning.mlr-org.com/reference/tune_nested.html)`(``tuner``, ``task``, ``learner``,`\
`                  inner_resampling ``=`` `[`rsmp`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"cv"``, folds ``=`` ``3``)``,`\
`                  outer_resampling ``=`` `[`rsmp`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"cv"``, folds ``=`` ``5``)``,`\
`                  measure ``=`` `[`msr`](https://mlr3.mlr-org.com/reference/mlr_sugar.html)`(``"classif.ce"``)``, term_evals ``=`` ``20``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`rr``$``aggregate``(``)`

Here, the outer resampling iterations are processed in parallel. To
protect against overloading the machine, the inner tuning runs
sequentially on each parallel worker, unless you use a nested future
plan. See the ‘Future Topologies’ vignette of the
**[future](https://cran.r-project.org/package=future)** package for
details.

## Details

The **mlr3tuning** package evaluates each batch of hyperparameter
configurations using
[`mlr3::benchmark()`](https://mlr3.mlr-org.com/reference/benchmark.html),
which parallelizes via
**[future.apply](https://cran.r-project.org/package=future.apply)**. As
explained in the ‘mlr3’ vignette of **futurize**, piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
guarantees that **mlr3** parallelizes via futures, even if mirai daemons
have been set up for **mlr3**. Also, the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
options `globals` and `packages` are ignored, because **mlr3** manages
those itself, and parallel random number generation (`seed = TRUE`) is
always used.

Asynchronous tuners, e.g. `tnr("async_random_search")`, are *not*
supported. They run on **rush** workers, which do not use futures. If
you try to futurize
[`tune()`](https://mlr3tuning.mlr-org.com/reference/tune.html) or
[`tune_nested()`](https://mlr3tuning.mlr-org.com/reference/tune_nested.html)
with an asynchronous tuner, an error is produced.

## Supported Functions

The following **mlr3tuning** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`tune()`](https://mlr3tuning.mlr-org.com/reference/tune.html) with
  `seed = TRUE` as the default
- [`tune_nested()`](https://mlr3tuning.mlr-org.com/reference/tune_nested.html)
  with `seed = TRUE` as the default
