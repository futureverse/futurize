# Parallelize 'strucchange' functions

![The 'strucchange'
image](../reference/figures/cran-strucchange-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`strucchange`](https://zeileis.codeberg.page/strucchange/)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"Nile"``)`\
`bp.nile`` ``<-`` `[`breakpoints`](https://rdrr.io/pkg/strucchange/man/breakpoints.html)`(``Nile`` ``~`` ``1``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

The **[strucchange](https://cran.r-project.org/package=strucchange)**
package provides the
[`breakpoints()`](https://rdrr.io/pkg/strucchange/man/breakpoints.html)
function for estimating one or more change points in a data trace,
e.g. in time-series data.

### Example: Finding breakpoints in time-series data

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`strucchange`](https://zeileis.codeberg.page/strucchange/)`)`\
\
`## UK Seatbelt data: a SARIMA(1,0,0)(1,0,0)_12 model`\
`## (fitted by OLS) is used and reveals (at least) two`\
`## breakpoints - one in 1973 associated with the oil crisis and`\
`## one in 1983 due to the introduction of compulsory`\
`## wearing of seatbelts in the UK.`\
[`data`](https://rdrr.io/r/utils/data.html)`(``"UKDriverDeaths"``)`\
\
`seatbelt`` ``<-`` `[`log10`](https://rdrr.io/r/base/Log.html)`(``UKDriverDeaths``)`\
`seatbelt`` ``<-`` `[`cbind`](https://rdrr.io/r/base/cbind.html)`(``seatbelt``, `[`lag`](https://rdrr.io/r/stats/lag.html)`(``seatbelt``, k ``=`` ``-``1``)``, `[`lag`](https://rdrr.io/r/stats/lag.html)`(``seatbelt``, k ``=`` ``-``12``)``)`\
[`colnames`](https://rdrr.io/r/base/colnames.html)`(``seatbelt``)`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"y"``, ``"ylag1"``, ``"ylag12"``)`\
`seatbelt`` ``<-`` `[`window`](https://rdrr.io/r/stats/window.html)`(``seatbelt``, start ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``1970``, ``1``)``, end ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``1984``, ``12``)``)`\
[`plot`](https://rdrr.io/r/graphics/plot.default.html)`(``seatbelt``[``,``"y"``]``, ylab ``=`` `[`expression`](https://rdrr.io/r/base/expression.html)`(``log``[``10``]``(``casualties``)``)``)`\
\
`## testing`\
`re.seat`` ``<-`` `[`efp`](https://rdrr.io/pkg/strucchange/man/efp.html)`(``y`` ``~`` ``ylag1`` ``+`` ``ylag12``, data ``=`` ``seatbelt``, type ``=`` ``"RE"``)`\
[`plot`](https://rdrr.io/r/graphics/plot.default.html)`(``re.seat``)`\
\
`## dating`\
`bp.seat`` ``<-`` `[`breakpoints`](https://rdrr.io/pkg/strucchange/man/breakpoints.html)`(``y`` ``~`` ``ylag1`` ``+`` ``ylag12``, data ``=`` ``seatbelt``, h ``=`` ``0.1``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
[`lines`](https://rdrr.io/r/graphics/lines.html)`(``bp.seat``, breaks ``=`` ``2``)`

This will parallelize the dynamic programming algorithm for computing
the optimal breakpoints, given that we have set up parallel workers,
e.g.

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

The following **strucchange** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`breakpoints()`](https://rdrr.io/pkg/strucchange/man/breakpoints.html)
  for ‘formula’

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`breakpoints()`](https://rdrr.io/pkg/strucchange/man/breakpoints.html)
using the **parallel** and **doParallel** packages directly, without
**futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`strucchange`](https://zeileis.codeberg.page/strucchange/)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`doParallel`](https://github.com/RevolutionAnalytics/doparallel)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"Nile"``)`\
\
`## Set up a PSOCK cluster and register it with foreach`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
[`registerDoParallel`](https://rdrr.io/pkg/doParallel/man/registerDoParallel.html)`(``cl``)`\
\
`## Find breakpoints in parallel via foreach`\
`bp.nile`` ``<-`` `[`breakpoints`](https://rdrr.io/pkg/strucchange/man/breakpoints.html)`(``Nile`` ``~`` ``1``, hpc ``=`` ``"foreach"``)`\
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
