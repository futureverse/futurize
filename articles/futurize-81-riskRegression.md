# Parallelize 'riskRegression' functions

![The 'riskRegression'
image](../reference/figures/cran-riskRegression-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`riskRegression`](https://github.com/tagteam/riskRegression)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`survival`](https://github.com/therneau/survival)`)`\
\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``42``)`\
`d`` ``<-`` `[`sampleData`](https://rdrr.io/pkg/riskRegression/man/sampleData.html)`(``200``, outcome ``=`` ``"competing.risks"``)`\
`fit`` ``<-`` `[`CSC`](https://rdrr.io/pkg/riskRegression/man/CSC.html)`(``Hist``(``time``, ``event``)`` ``~`` ``X1`` ``+`` ``X2`` ``+`` ``X7`` ``+`` ``X8``, data ``=`` ``d``)`\
`sc`` ``<-`` `[`Score`](https://rdrr.io/pkg/riskRegression/man/Score.html)`(`[`list`](https://rdrr.io/r/base/list.html)`(``"CSC"`` ``=`` ``fit``)``, data ``=`` ``d``,`\
`            formula ``=`` ``Hist``(``time``, ``event``)`` ``~`` ``1``,`\
`            times ``=`` ``5``, B ``=`` ``100``, split.method ``=`` ``"bootcv"``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[riskRegression](https://cran.r-project.org/package=riskRegression)**
functions such as
[`Score()`](https://rdrr.io/pkg/riskRegression/man/Score.html).

The
**[riskRegression](https://cran.r-project.org/package=riskRegression)**
package provides tools for risk regression modeling and prediction in
survival analysis with competing risks. It supports fitting
cause-specific Cox regression models, Fine-Gray regression, and absolute
risk regression models. The
[`Score()`](https://rdrr.io/pkg/riskRegression/man/Score.html) function
performs bootstrap cross-validation for model evaluation, which is an
excellent candidate for parallelization.

### Example: Bootstrap cross-validation with Score()

The [`Score()`](https://rdrr.io/pkg/riskRegression/man/Score.html)
function evaluates prediction models via bootstrap cross-validation with
metrics such as time-dependent AUC and Brier scores:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`riskRegression`](https://github.com/tagteam/riskRegression)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`survival`](https://github.com/therneau/survival)`)`\
\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``42``)`\
`d`` ``<-`` `[`sampleData`](https://rdrr.io/pkg/riskRegression/man/sampleData.html)`(``200``, outcome ``=`` ``"competing.risks"``)`\
`fit`` ``<-`` `[`CSC`](https://rdrr.io/pkg/riskRegression/man/CSC.html)`(``Hist``(``time``, ``event``)`` ``~`` ``X1`` ``+`` ``X2`` ``+`` ``X7`` ``+`` ``X8``, data ``=`` ``d``)`\
\
`## Bootstrap cross-validation with 100 bootstrap samples`\
`sc`` ``<-`` `[`Score`](https://rdrr.io/pkg/riskRegression/man/Score.html)`(`[`list`](https://rdrr.io/r/base/list.html)`(``"CSC"`` ``=`` ``fit``)``, data ``=`` ``d``,`\
`            formula ``=`` ``Hist``(``time``, ``event``)`` ``~`` ``1``,`\
`            times ``=`` ``5``, B ``=`` ``100``, split.method ``=`` ``"bootcv"``)`

Here [`Score()`](https://rdrr.io/pkg/riskRegression/man/Score.html)
evaluates sequentially, but we can easily make it evaluate in parallel
by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`riskRegression`](https://github.com/tagteam/riskRegression)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`survival`](https://github.com/therneau/survival)`)`\
\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``42``)`\
`d`` ``<-`` `[`sampleData`](https://rdrr.io/pkg/riskRegression/man/sampleData.html)`(``200``, outcome ``=`` ``"competing.risks"``)`\
`fit`` ``<-`` `[`CSC`](https://rdrr.io/pkg/riskRegression/man/CSC.html)`(``Hist``(``time``, ``event``)`` ``~`` ``X1`` ``+`` ``X2`` ``+`` ``X7`` ``+`` ``X8``, data ``=`` ``d``)`\
\
`sc`` ``<-`` `[`Score`](https://rdrr.io/pkg/riskRegression/man/Score.html)`(`[`list`](https://rdrr.io/r/base/list.html)`(``"CSC"`` ``=`` ``fit``)``, data ``=`` ``d``,`\
`            formula ``=`` ``Hist``(``time``, ``event``)`` ``~`` ``1``,`\
`            times ``=`` ``5``, B ``=`` ``100``, split.method ``=`` ``"bootcv"``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the bootstrap samples across the available parallel
workers, given that we have set up parallel workers, e.g.

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

The following **riskRegression** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`Score()`](https://rdrr.io/pkg/riskRegression/man/Score.html) for
  ‘list’ with `seed = TRUE` as the default

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`Score()`](https://rdrr.io/pkg/riskRegression/man/Score.html) using the
**parallel** and **doParallel** packages directly, without **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`riskRegression`](https://github.com/tagteam/riskRegression)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`survival`](https://github.com/therneau/survival)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`doParallel`](https://github.com/RevolutionAnalytics/doparallel)`)`\
\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``42``)`\
`d`` ``<-`` `[`sampleData`](https://rdrr.io/pkg/riskRegression/man/sampleData.html)`(``200``, outcome ``=`` ``"competing.risks"``)`\
`fit`` ``<-`` `[`CSC`](https://rdrr.io/pkg/riskRegression/man/CSC.html)`(``Hist``(``time``, ``event``)`` ``~`` ``X1`` ``+`` ``X2`` ``+`` ``X7`` ``+`` ``X8``, data ``=`` ``d``)`\
\
`## Set up a PSOCK cluster and register it with foreach`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
[`registerDoParallel`](https://rdrr.io/pkg/doParallel/man/registerDoParallel.html)`(``cl``)`\
\
`## Bootstrap cross-validation in parallel via foreach`\
`sc`` ``<-`` `[`Score`](https://rdrr.io/pkg/riskRegression/man/Score.html)`(`[`list`](https://rdrr.io/r/base/list.html)`(``"CSC"`` ``=`` ``fit``)``, data ``=`` ``d``,`\
`            formula ``=`` ``Hist``(``time``, ``event``)`` ``~`` ``1``,`\
`            times ``=`` ``5``, B ``=`` ``100``, split.method ``=`` ``"bootcv"``,`\
`            parallel ``=`` ``"as.registered"``)`\
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
