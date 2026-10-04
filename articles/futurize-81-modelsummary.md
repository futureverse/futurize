# Parallelize 'modelsummary' functions

![The 'modelsummary'
hexlogo](../reference/figures/modelsummary-logo.webp)+ ![The 'futurize'
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`modelsummary`](https://modelsummary.com)`)`\
\
`fit1`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``mpg`` ``~`` ``cyl``, data ``=`` ``mtcars``)`\
`fit2`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``mpg`` ``~`` ``cyl`` ``+`` ``hp``, data ``=`` ``mtcars``)`\
`models`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``Model1 ``=`` ``fit1``, Model2 ``=`` ``fit2``)`\
\
[`modelsummary`](https://modelsummary.com/man/modelsummary.html)`(``models``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

The **[modelsummary](https://cran.r-project.org/package=modelsummary)**
package creates customizable tables and plots to summarize statistical
models side-by-side. For example,

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`modelsummary`](https://modelsummary.com)`)`\
\
`## fit multiple linear models`\
`fit1`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``mpg`` ``~`` ``cyl``, data ``=`` ``mtcars``)`\
`fit2`` ``<-`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``mpg`` ``~`` ``cyl`` ``+`` ``hp``, data ``=`` ``mtcars``)`\
`models`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``Model1 ``=`` ``fit1``, Model2 ``=`` ``fit2``)`\
\
`## generate modelsummary table in parallel`\
`tbl`` ``<-`` `[`modelsummary`](https://modelsummary.com/man/modelsummary.html)`(``models``, output ``=`` ``"data.frame"``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``tbl``)`

will parallelize model summary statistics extraction, given that we have
set up parallel workers, e.g.

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

The following **modelsummary** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`modelsummary()`](https://modelsummary.com/man/modelsummary.html)
  with `seed = TRUE` as the default
- [`msummary()`](https://modelsummary.com/man/msummary.html) with
  `seed = TRUE` as the default
- [`modelplot()`](https://modelsummary.com/man/modelplot.html) with
  `seed = TRUE` as the default
