# Parallelize 'TSP' functions

![The 'TSP' hexlogo](../reference/figures/TSP-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`TSP`](https://github.com/mhahsler/TSP)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"USCA50"``)`\
`tour`` ``<-`` `[`solve_TSP`](https://rdrr.io/pkg/TSP/man/solve_TSP.html)`(``USCA50``, method ``=`` ``"nn"``, rep ``=`` ``10L``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

The **[TSP](https://cran.r-project.org/package=TSP)** package provides
algorithms for solving the traveling salesperson problem (TSP).

### Example:

Example adopted from
[`help("solve_TSP", package = "TSP")`](https://rdrr.io/pkg/TSP/man/solve_TSP.html):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`TSP`](https://github.com/mhahsler/TSP)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"USCA50"``)`\
`methods`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`  ``"identity"``, ``"random"``, ``"nearest_insertion"``, ``"cheapest_insertion"``,`\
`  ``"farthest_insertion"``, ``"arbitrary_insertion"``, ``"nn"``, ``"repetitive_nn"``, `\
`  ``"two_opt"``, ``"sa"`\
`)`\
\
`## calculate tours - each tour in parallel`\
`tours`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``methods``, FUN ``=`` ``function``(``m``)`` ``{`\
`  `[`solve_TSP`](https://rdrr.io/pkg/TSP/man/solve_TSP.html)`(``USCA50``, rep ``=`` ``10L``, method ``=`` ``m``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`}``)`\
[`names`](https://rdrr.io/r/base/names.html)`(``tours``)`` ``<-`` ``methods`

This will parallelize the computations, given that we have set up
parallel workers, e.g.

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

The following **TSP** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`solve_TSP()`](https://rdrr.io/pkg/TSP/man/solve_TSP.html) with
  `seed = TRUE` as the default

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`solve_TSP()`](https://rdrr.io/pkg/TSP/man/solve_TSP.html) using the
**parallel** and **doParallel** packages directly, without **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`TSP`](https://github.com/mhahsler/TSP)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`doParallel`](https://github.com/RevolutionAnalytics/doparallel)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"USCA50"``)`\
\
`## Set up a PSOCK cluster and register it with foreach`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
[`registerDoParallel`](https://rdrr.io/pkg/doParallel/man/registerDoParallel.html)`(``cl``)`\
\
`## Solve the TSP in parallel via foreach`\
`tour`` ``<-`` `[`solve_TSP`](https://rdrr.io/pkg/TSP/man/solve_TSP.html)`(``USCA50``, method ``=`` ``"nn"``, rep ``=`` ``10L``)`\
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
