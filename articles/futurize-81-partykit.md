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
`airq`` ``<-`` `[`na.omit`](https://rdrr.io/r/stats/na.fail.html)`(``airquality``)`\
`cf`` ``<-`` `[`cforest`](https://rdrr.io/pkg/partykit/man/cforest.html)`(``Ozone`` ``~`` ``.``, data ``=`` ``airq``)`\
`vi`` ``<-`` `[`varimp`](https://rdrr.io/pkg/partykit/man/varimp.html)`(``cf``, conditional ``=`` ``TRUE``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

The **[partykit](https://cran.r-project.org/package=partykit)** package
provides a toolkit for recursive partitioning.

### Example: Conditional variable importance

Conditional variable importance is one of the most computationally
expensive steps when working with conditional random forests. It is
estimated one tree at a time, which makes it well suited for parallel
processing. Example adopted from
[`help("varimp", package = "partykit")`](https://rdrr.io/pkg/partykit/man/varimp.html):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`partykit`](https://codeberg.org/thothorn/partykit)`)`\
\
`## conditional inference forest for the complete cases of 'airquality'`\
`airq`` ``<-`` `[`na.omit`](https://rdrr.io/r/stats/na.fail.html)`(``airquality``)`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``42``)`\
`cf`` ``<-`` `[`cforest`](https://rdrr.io/pkg/partykit/man/cforest.html)`(``Ozone`` ``~`` ``.``, data ``=`` ``airq``, ntree ``=`` ``500L``)`\
\
`## conditional variable importance, estimated in parallel`\
`vi`` ``<-`` `[`varimp`](https://rdrr.io/pkg/partykit/man/varimp.html)`(``cf``, conditional ``=`` ``TRUE``, nperm ``=`` ``10L``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``vi``)`

This will parallelize the estimation of the variable importance across
the trees of the forest, given that we have set up parallel workers,
e.g.

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`

With 500 trees and 10 permutations per tree, this takes roughly 13
seconds sequentially and about half of that on four parallel workers
(single runs on a laptop; the speedup grows with the number of trees and
permutations).

The same pattern applies to growing the forest itself, i.e.
`cforest(...) |> futurize()`, but the variable-importance step typically
dominates the run time.

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
[`varimp()`](https://rdrr.io/pkg/partykit/man/varimp.html) using the
**parallel** package directly, without **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`partykit`](https://codeberg.org/thothorn/partykit)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
\
`airq`` ``<-`` `[`na.omit`](https://rdrr.io/r/stats/na.fail.html)`(``airquality``)`\
`cf`` ``<-`` `[`cforest`](https://rdrr.io/pkg/partykit/man/cforest.html)`(``Ozone`` ``~`` ``.``, data ``=`` ``airq``, ntree ``=`` ``500L``)`\
\
`## Set up a PSOCK cluster`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
\
`## Estimate the conditional variable importance in parallel`\
`vi`` ``<-`` `[`varimp`](https://rdrr.io/pkg/partykit/man/varimp.html)`(``cf``, conditional ``=`` ``TRUE``, nperm ``=`` ``10L``,`\
`             applyfun ``=`` ``function``(``X``, ``FUN``, ``...``)`` `[`parLapply`](https://rdrr.io/r/parallel/clusterApply.html)`(``cl``, ``X``, ``FUN``, ``...``)``)`\
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
