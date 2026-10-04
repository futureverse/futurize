# Parallelize 'seriation' functions

![The 'seriation' image](../reference/figures/seriation-logo.webp)+
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`seriation`](https://github.com/mhahsler/seriation)`)`\
\
`o`` ``<-`` ``seriation``::`[`seriate_best`](https://rdrr.io/pkg/seriation/man/seriate_best.html)`(``d_supreme``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

The **[seriation](https://cran.r-project.org/package=seriation)**
package provides functions for ordering objects using seriation,
ordination techniques for reordering matrices, dissimilarity matrices,
and dendrograms.

### Example: Seriate best

Example adopted from
[`help("seriate_best", package = "seriation")`](https://rdrr.io/pkg/seriation/man/seriate_best.html):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`seriation`](https://github.com/mhahsler/seriation)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``SupremeCourt``)`\
`d_supreme`` ``<-`` `[`as.dist`](https://rdrr.io/r/stats/dist.html)`(``SupremeCourt``)`\
\
`o`` ``<-`` `[`seriate_best`](https://rdrr.io/pkg/seriation/man/seriate_best.html)`(``d_supreme``, criterion ``=`` ``"AR_events"``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``o``)`

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

The following **seriation** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`seriate_best()`](https://rdrr.io/pkg/seriation/man/seriate_best.html)
  with `seed = TRUE` as the default
- [`seriate_rep()`](https://rdrr.io/pkg/seriation/man/seriate_best.html)
  with `seed = TRUE` as the default
