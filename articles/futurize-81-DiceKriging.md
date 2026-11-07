# Parallelize 'DiceKriging' functions

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
[`library`](https://rdrr.io/r/base/library.html)`(`[`DiceKriging`](https://dicekrigingclub.github.io/www/)`)`\
\
`design`` ``<-`` `[`expand.grid`](https://rdrr.io/r/base/expand.grid.html)`(``x1 ``=`` `[`seq`](https://rdrr.io/r/base/seq.html)`(``0``, ``1``, length ``=`` ``15``)``, x2 ``=`` `[`seq`](https://rdrr.io/r/base/seq.html)`(``0``, ``1``, length ``=`` ``15``)``)`\
`y`` ``<-`` `[`apply`](https://rdrr.io/r/base/apply.html)`(``design``, ``1``, ``function``(``x``)`` ``x``[``1``]``^``2`` ``+`` ``x``[``2``]``^``2``)`\
`m`` ``<-`` `[`km`](https://rdrr.io/pkg/DiceKriging/man/km.html)`(``~``.``, design ``=`` ``design``, response ``=`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``y ``=`` ``y``)``,`\
`        multistart ``=`` ``20``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use **futurize** to parallelize
**[DiceKriging](https://cran.r-project.org/package=DiceKriging)**
functions, specifically
[`km()`](https://rdrr.io/pkg/DiceKriging/man/km.html). When fitting a
kriging model via [`km()`](https://rdrr.io/pkg/DiceKriging/man/km.html),
the parameters of the covariance function are estimated by maximum
likelihood or cross-validation. The optimization can be started from
multiple points (to avoid local optima), which can be done in parallel.

### Example: kriging model with multi-start optimization

Fitting a kriging model with a single starting point:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`DiceKriging`](https://dicekrigingclub.github.io/www/)`)`\
\
`design`` ``<-`` `[`expand.grid`](https://rdrr.io/r/base/expand.grid.html)`(``x1 ``=`` `[`seq`](https://rdrr.io/r/base/seq.html)`(``0``, ``1``, length ``=`` ``15``)``, x2 ``=`` `[`seq`](https://rdrr.io/r/base/seq.html)`(``0``, ``1``, length ``=`` ``15``)``)`\
`y`` ``<-`` `[`apply`](https://rdrr.io/r/base/apply.html)`(``design``, MARGIN ``=`` ``1``, FUN ``=`` ``function``(``x``)`` ``x``[``1``]``^``2`` ``+`` ``x``[``2``]``^``2``)`\
`m`` ``<-`` `[`km`](https://rdrr.io/pkg/DiceKriging/man/km.html)`(``~``.``, design ``=`` ``design``, response ``=`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``y ``=`` ``y``)``)`

To run multiple optimizer starts in parallel, set `multistart > 1` and
pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`DiceKriging`](https://dicekrigingclub.github.io/www/)`)`\
\
`design`` ``<-`` `[`expand.grid`](https://rdrr.io/r/base/expand.grid.html)`(``x1 ``=`` `[`seq`](https://rdrr.io/r/base/seq.html)`(``0``, ``1``, length ``=`` ``15``)``, x2 ``=`` `[`seq`](https://rdrr.io/r/base/seq.html)`(``0``, ``1``, length ``=`` ``15``)``)`\
`y`` ``<-`` `[`apply`](https://rdrr.io/r/base/apply.html)`(``design``, MARGIN ``=`` ``1``, FUN ``=`` ``function``(``x``)`` ``x``[``1``]``^``2`` ``+`` ``x``[``2``]``^``2``)`\
`m`` ``<-`` `[`km`](https://rdrr.io/pkg/DiceKriging/man/km.html)`(``~``.``, design ``=`` ``design``, response ``=`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``y ``=`` ``y``)``,`\
`        multistart ``=`` ``20``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This distributes the multi-start runs across the available parallel
workers, given that we have set up a parallel plan, e.g.

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

The following **DiceKriging** function is supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`km()`](https://rdrr.io/pkg/DiceKriging/man/km.html)
