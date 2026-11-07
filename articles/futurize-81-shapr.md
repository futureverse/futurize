# Parallelize 'shapr' functions

![The 'shapr' logo](../reference/figures/cran-shapr-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`shapr`](https://norskregnesentral.github.io/shapr/)`)`\
\
`result`` ``<-`` `[`explain`](https://norskregnesentral.github.io/shapr/reference/explain.html)`(`\
`  model ``=`` ``model``,`\
`  x_explain ``=`` ``x_explain``,`\
`  x_train ``=`` ``x_train``,`\
`  approach ``=`` ``"empirical"``,`\
`  phi0 ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``y_train``)`\
`)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[shapr](https://cran.r-project.org/package=shapr)** functions such as
[`explain()`](https://norskregnesentral.github.io/shapr/reference/explain.html).

The **[shapr](https://cran.r-project.org/package=shapr)** package
implements dependence-aware Shapley values for explaining predictions
from machine learning models. Its
[`explain()`](https://norskregnesentral.github.io/shapr/reference/explain.html)
function computes Shapley value estimates by evaluating conditional
expectations across multiple coalitions of features, making the
computation an excellent candidate for parallelization.

### Example: Computing Shapley values in parallel

The
[`explain()`](https://norskregnesentral.github.io/shapr/reference/explain.html)
function computes Shapley values for a set of observations. For example,
using a simple linear model:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`shapr`](https://norskregnesentral.github.io/shapr/)`)`\
\
`## Fit a model`\
`x_train`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``x1 ``=`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``100``)``, x2 ``=`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``100``)``)`\
`y_train`` ``<-`` ``2`` ``*`` ``x_train``$``x1`` ``+`` ``x_train``$``x2`` ``+`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``100``)`\
`model`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``y_train`` ``~`` ``x1`` ``+`` ``x2``, data ``=`` ``x_train``)`\
\
`## Explain predictions`\
`x_explain`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``x1 ``=`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``5``)``, x2 ``=`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``5``)``)`\
`result`` ``<-`` `[`explain`](https://norskregnesentral.github.io/shapr/reference/explain.html)`(`\
`  model ``=`` ``model``,`\
`  x_explain ``=`` ``x_explain``,`\
`  x_train ``=`` ``x_train``,`\
`  approach ``=`` ``"empirical"``,`\
`  phi0 ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``y_train``)`\
`)`

Here
[`explain()`](https://norskregnesentral.github.io/shapr/reference/explain.html)
evaluates the coalitions sequentially, but we can easily make it
evaluate them in parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`shapr`](https://norskregnesentral.github.io/shapr/)`)`\
\
`result`` ``<-`` `[`explain`](https://norskregnesentral.github.io/shapr/reference/explain.html)`(`\
`  model ``=`` ``model``,`\
`  x_explain ``=`` ``x_explain``,`\
`  x_train ``=`` ``x_train``,`\
`  approach ``=`` ``"empirical"``,`\
`  phi0 ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``y_train``)`\
`)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the coalition computations across the available
parallel workers, given that we have set up parallel workers, e.g.

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`

The built-in `multisession` backend parallelizes on your local computer
and works on all operating systems. There are [other parallel
backends](https://www.futureverse.org/backends.html) to choose from,
including alternatives to parallelize locally as well as distributed
across remote machines, e.g.

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``future.mirai``::`[`mirai_multisession`](https://future.mirai.futureverse.org/reference/mirai_multisession.html)`)`

and

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``future.batchtools``::`[`batchtools_slurm`](https://future.batchtools.futureverse.org/reference/batchtools_slurm.html)`)`

## Supported Functions

The following **shapr** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`explain()`](https://norskregnesentral.github.io/shapr/reference/explain.html)
  with `seed = TRUE` as the default
- [`explain_forecast()`](https://norskregnesentral.github.io/shapr/reference/explain_forecast.html)
  with `seed = TRUE` as the default
