# Parallelize 'glmnet' functions

![The 'glmnet' hexlogo](../reference/figures/glmnet-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`glmnet`](https://glmnet.stanford.edu)`)`\
\
`n`` ``<-`` ``1000`\
`p`` ``<-`` ``100`\
`nzc`` ``<-`` `[`trunc`](https://rdrr.io/r/base/Round.html)`(``p`` ``/`` ``10``)`\
`x`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n`` ``*`` ``p``)``, ``n``, ``p``)`\
`beta`` ``<-`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``nzc``)`\
`fx`` ``<-`` ``x``[``, `[`seq_len`](https://rdrr.io/r/base/seq.html)`(``nzc``)``]`` `[`%*%`](https://rdrr.io/r/base/matmult.html)` ``beta`\
`eps`` ``<-`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n``)`` ``*`` ``5`\
`y`` ``<-`` `[`drop`](https://rdrr.io/r/base/drop.html)`(``fx`` ``+`` ``eps``)`\
\
`cv`` ``<-`` `[`cv.glmnet`](https://glmnet.stanford.edu/reference/cv.glmnet.html)`(``x``, ``y``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[glmnet](https://cran.r-project.org/package=glmnet)** functions such
as
[`cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html).

The **[glmnet](https://cran.r-project.org/package=glmnet)** package uses
a highly optimized pathwise coordinate descent algorithm to efficiently
compute the entire regularization path for penalized generalized linear
models (Lasso, Ridge, Elastic Net). Its
[`cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html)
function performs cross-validation to select the optimal regularization
parameter, which is an excellent candidate for parallelization.

### Example: Cross-validation for regularized regression

The
[`cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html)
function fits models across multiple folds and lambda values. For
example:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`glmnet`](https://glmnet.stanford.edu)`)`\
\
`## Generate simulated data`\
`n`` ``<-`` ``1000`\
`p`` ``<-`` ``100`\
`nzc`` ``<-`` `[`trunc`](https://rdrr.io/r/base/Round.html)`(``p`` ``/`` ``10``)`\
`x`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n`` ``*`` ``p``)``, ``n``, ``p``)`\
`beta`` ``<-`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``nzc``)`\
`fx`` ``<-`` ``x``[``, `[`seq_len`](https://rdrr.io/r/base/seq.html)`(``nzc``)``]`` `[`%*%`](https://rdrr.io/r/base/matmult.html)` ``beta`\
`eps`` ``<-`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n``)`` ``*`` ``5`\
`y`` ``<-`` `[`drop`](https://rdrr.io/r/base/drop.html)`(``fx`` ``+`` ``eps``)`\
\
`## Perform cross-validation to find optimal lambda`\
`cv`` ``<-`` `[`cv.glmnet`](https://glmnet.stanford.edu/reference/cv.glmnet.html)`(``x``, ``y``)`

Here
[`cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html)
evaluates sequentially, but we can easily make it evaluate in parallel
by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`glmnet`](https://glmnet.stanford.edu)`)`\
\
`n`` ``<-`` ``1000`\
`p`` ``<-`` ``100`\
`nzc`` ``<-`` `[`trunc`](https://rdrr.io/r/base/Round.html)`(``p`` ``/`` ``10``)`\
`x`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n`` ``*`` ``p``)``, ``n``, ``p``)`\
`beta`` ``<-`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``nzc``)`\
`fx`` ``<-`` ``x``[``, `[`seq_len`](https://rdrr.io/r/base/seq.html)`(``nzc``)``]`` `[`%*%`](https://rdrr.io/r/base/matmult.html)` ``beta`\
`eps`` ``<-`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n``)`` ``*`` ``5`\
`y`` ``<-`` `[`drop`](https://rdrr.io/r/base/drop.html)`(``fx`` ``+`` ``eps``)`\
\
`cv`` ``<-`` `[`cv.glmnet`](https://glmnet.stanford.edu/reference/cv.glmnet.html)`(``x``, ``y``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the cross-validation folds across the available
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

The following **glmnet** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html)
  with `seed = TRUE` as the default

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html)
using the **parallel** and **doParallel** packages directly, without
**futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`glmnet`](https://glmnet.stanford.edu)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`doParallel`](https://github.com/RevolutionAnalytics/doparallel)`)`\
\
`## Generate simulated data`\
`n`` ``<-`` ``1000`\
`p`` ``<-`` ``100`\
`nzc`` ``<-`` `[`trunc`](https://rdrr.io/r/base/Round.html)`(``p`` ``/`` ``10``)`\
`x`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n`` ``*`` ``p``)``, ``n``, ``p``)`\
`beta`` ``<-`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``nzc``)`\
`fx`` ``<-`` ``x``[``, `[`seq_len`](https://rdrr.io/r/base/seq.html)`(``nzc``)``]`` `[`%*%`](https://rdrr.io/r/base/matmult.html)` ``beta`\
`eps`` ``<-`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n``)`` ``*`` ``5`\
`y`` ``<-`` `[`drop`](https://rdrr.io/r/base/drop.html)`(``fx`` ``+`` ``eps``)`\
\
`## Set up a PSOCK cluster and register it with foreach`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
[`registerDoParallel`](https://rdrr.io/pkg/doParallel/man/registerDoParallel.html)`(``cl``)`\
\
`## Perform cross-validation in parallel via foreach`\
`cv`` ``<-`` `[`cv.glmnet`](https://glmnet.stanford.edu/reference/cv.glmnet.html)`(``x``, ``y``, parallel ``=`` ``TRUE``)`\
\
`## Tear down the cluster`\
[`stopCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``cl``)`\
[`registerDoSEQ`](https://rdrr.io/pkg/foreach/man/registerDoSEQ.html)`(``)``  ``## reset foreach to sequential`

This requires you to manually create a cluster, register it with
**doParallel**, and remember to tear it down and reset the **foreach**
backend when done. If you forget to call
[`stopCluster()`](https://rdrr.io/r/parallel/makeCluster.html), or if
your code errors out before reaching it, you leak background R
processes. You also have to decide upfront how many CPUs to use and what
cluster type to use. Switching to another parallel backend, e.g. a Slurm
cluster, would require a completely different setup. With **futurize**,
all of this is handled for you - just pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
and control the backend with
[`plan()`](https://future.futureverse.org/reference/plan.html).
