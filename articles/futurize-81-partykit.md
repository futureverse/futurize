# Parallelize 'partykit' functions

![The 'partykit' image](../reference/figures/cran-partykit-logo.webp)+
![The 'futurize' hexlogo](../reference/figures/futurize-logo.webp)=
![The 'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`partykit`](https://codeberg.org/thothorn/partykit)`)`\
\
`cf`` ``<-`` ``partykit``::`[`cforest`](https://rdrr.io/pkg/partykit/man/cforest.html)`(``dist`` ``~`` ``speed``, data ``=`` ``cars``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

The **[partykit](https://cran.r-project.org/package=partykit)** package
provides a toolkit for recursive partitioning.

### Example: Conditional random forests inference

Example adopted from
[`help("cforest", package = "partykit")`](https://rdrr.io/pkg/partykit/man/cforest.html):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`partykit`](https://codeberg.org/thothorn/partykit)`)`\
\
`## basic example: conditional inference forest for cars data`\
`cf`` ``<-`` `[`cforest`](https://rdrr.io/pkg/partykit/man/cforest.html)`(``dist`` ``~`` ``speed``, data ``=`` ``cars``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`## prediction of fitted mean and visualization`\
`nd`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``speed ``=`` ``4``:``25``)`\
`nd``$``mean``  ``<-`` `[`predict`](https://rdrr.io/r/stats/predict.html)`(``cf``, newdata ``=`` ``nd``, type ``=`` ``"response"``)`\
[`plot`](https://rdrr.io/r/graphics/plot.default.html)`(``dist`` ``~`` ``speed``, data ``=`` ``cars``)`\
[`lines`](https://rdrr.io/r/graphics/lines.html)`(``mean`` ``~`` ``speed``, data ``=`` ``nd``)`

This will parallelize the computations of the variable selection
criterion, given that we have set up parallel workers, e.g.

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

The following **partykit** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`cforest()`](https://rdrr.io/pkg/partykit/man/cforest.html) with
  `seed = TRUE` as the default
- [`ctree_control()`](https://rdrr.io/pkg/partykit/man/ctree_control.html)
  with `seed = TRUE` as the default
- [`mob_control()`](https://rdrr.io/pkg/partykit/man/mob_control.html)
  with `seed = TRUE` as the default
- [`varimp()`](https://rdrr.io/pkg/partykit/man/varimp.html) for
  `cforest` with `seed = TRUE` as the default

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`cforest()`](https://rdrr.io/pkg/partykit/man/cforest.html) using the
**parallel** package directly, without **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`partykit`](https://codeberg.org/thothorn/partykit)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
\
`## Set up a PSOCK cluster`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
\
`## Fit a conditional inference forest in parallel`\
`cf`` ``<-`` `[`cforest`](https://rdrr.io/pkg/partykit/man/cforest.html)`(``dist`` ``~`` ``speed``, data ``=`` ``cars``,`\
`              applyfun ``=`` ``function``(``X``, ``FUN``, ``...``)`` `[`parLapply`](https://rdrr.io/r/parallel/clusterApply.html)`(``cl``, ``X``, ``FUN``, ``...``)``)`\
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
