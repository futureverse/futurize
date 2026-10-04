# Parallelize 'metafor' functions

![The CRAN 'metafor'
package](../reference/figures/cran-metafor-logo.webp)+ ![The 'futurize'
hexlogo](../reference/figures/futurize-logo.webp)= ![The 'future'
logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`metafor`](https://www.metafor-project.org)`)`\
\
`dat`` ``<-`` `[`escalc`](https://wviechtb.github.io/metafor/reference/escalc.html)`(``measure ``=`` ``"RR"``, ai ``=`` ``tpos``, bi ``=`` ``tneg``,`\
`              ci ``=`` ``cpos``, di ``=`` ``cneg``, data ``=`` ``dat.bcg``)`\
`fit`` ``<-`` `[`rma`](https://wviechtb.github.io/metafor/reference/rma.uni.html)`(``yi``, ``vi``, data ``=`` ``dat``)`\
`pr`` ``<-`` `[`profile`](https://rdrr.io/r/stats/profile.html)`(``fit``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[metafor](https://cran.r-project.org/package=metafor)** functions such
as [`profile()`](https://rdrr.io/r/stats/profile.html),
[`rstudent()`](https://rdrr.io/r/stats/influence.measures.html),
[`cooks.distance()`](https://rdrr.io/r/stats/influence.measures.html),
and [`dfbetas()`](https://rdrr.io/r/stats/influence.measures.html).

The **[metafor](https://cran.r-project.org/package=metafor)** package
provides a comprehensive collection of functions for conducting
meta-analyses in R. It supports fixed-effects, random-effects, and
mixed-effects (meta-regression) models and includes functions for model
diagnostics and profiling. Several of these computations involve fitting
the model repeatedly, making them excellent candidates for
parallelization.

### Example: Likelihood profile for a random-effects model

The [`profile()`](https://rdrr.io/r/stats/profile.html) function
computes the likelihood profile for model parameters such as the
variance component in a random-effects meta-analysis. For example, using
the built-in BCG vaccine dataset:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`metafor`](https://www.metafor-project.org)`)`\
\
`## Calculate log risk ratios and sampling variances`\
`dat`` ``<-`` `[`escalc`](https://wviechtb.github.io/metafor/reference/escalc.html)`(``measure ``=`` ``"RR"``, ai ``=`` ``tpos``, bi ``=`` ``tneg``,`\
`              ci ``=`` ``cpos``, di ``=`` ``cneg``, data ``=`` ``dat.bcg``)`\
\
`## Fit a random-effects model`\
`fit`` ``<-`` `[`rma`](https://wviechtb.github.io/metafor/reference/rma.uni.html)`(``yi``, ``vi``, data ``=`` ``dat``)`\
\
`## Compute likelihood profile`\
`pr`` ``<-`` `[`profile`](https://rdrr.io/r/stats/profile.html)`(``fit``)`

Here [`profile()`](https://rdrr.io/r/stats/profile.html) is calculated
sequentially. To calculate in parallel, we can pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`metafor`](https://www.metafor-project.org)`)`\
\
`dat`` ``<-`` `[`escalc`](https://wviechtb.github.io/metafor/reference/escalc.html)`(``measure ``=`` ``"RR"``, ai ``=`` ``tpos``, bi ``=`` ``tneg``,`\
`              ci ``=`` ``cpos``, di ``=`` ``cneg``, data ``=`` ``dat.bcg``)`\
`fit`` ``<-`` `[`rma`](https://wviechtb.github.io/metafor/reference/rma.uni.html)`(``yi``, ``vi``, data ``=`` ``dat``)`\
`pr`` ``<-`` `[`profile`](https://rdrr.io/r/stats/profile.html)`(``fit``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the profile computations across the available
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

The following **metafor** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`profile()`](https://rdrr.io/r/stats/profile.html) for ‘rma.uni’,
  ‘rma.mv’, ‘rma.ls’, and ‘rma.uni.selmodel’
- [`rstudent()`](https://rdrr.io/r/stats/influence.measures.html) for
  ‘rma.mv’
- [`cooks.distance()`](https://rdrr.io/r/stats/influence.measures.html)
  for ‘rma.mv’
- [`dfbetas()`](https://rdrr.io/r/stats/influence.measures.html) for
  ‘rma.mv’

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`profile()`](https://rdrr.io/r/stats/profile.html) using the
**parallel** package directly, without **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`metafor`](https://www.metafor-project.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
\
`## Calculate log risk ratios and sampling variances`\
`dat`` ``<-`` `[`escalc`](https://wviechtb.github.io/metafor/reference/escalc.html)`(``measure ``=`` ``"RR"``, ai ``=`` ``tpos``, bi ``=`` ``tneg``,`\
`              ci ``=`` ``cpos``, di ``=`` ``cneg``, data ``=`` ``dat.bcg``)`\
\
`## Fit a random-effects model`\
`fit`` ``<-`` `[`rma`](https://wviechtb.github.io/metafor/reference/rma.uni.html)`(``yi``, ``vi``, data ``=`` ``dat``)`\
\
`## Set up a PSOCK cluster`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
\
`## Compute likelihood profile in parallel`\
`pr`` ``<-`` `[`profile`](https://rdrr.io/r/stats/profile.html)`(``fit``, parallel ``=`` ``"snow"``, ncpus ``=`` ``ncpus``, cl ``=`` ``cl``)`\
\
`## Tear down the cluster`\
[`stopCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``cl``)`

This requires you to manually create and manage the cluster lifecycle.
If you forget to call
[`stopCluster()`](https://rdrr.io/r/parallel/makeCluster.html), or if
your code errors out before reaching it, you leak background R
processes. You also have to decide upfront how many CPUs to use and what
cluster type to use. Switching to another parallel backend, e.g. a Slurm
cluster, would require a completely different setup. With **futurize**,
all of this is handled for you - just pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
and control the backend with
[`plan()`](https://future.futureverse.org/reference/plan.html).
