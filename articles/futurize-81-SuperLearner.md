# Parallelize 'SuperLearner' functions

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
[`library`](https://rdrr.io/r/base/library.html)`(`[`SuperLearner`](https://github.com/ecpolley/SuperLearner)`)`\
\
`res`` ``<-`` `[`CV.SuperLearner`](https://rdrr.io/pkg/SuperLearner/man/CV.SuperLearner.html)`(``Y ``=`` ``Y``, X ``=`` ``X``, SL.library ``=`` ``SL.library``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[SuperLearner](https://cran.r-project.org/package=SuperLearner)**
functions such as
[`CV.SuperLearner()`](https://rdrr.io/pkg/SuperLearner/man/CV.SuperLearner.html).

The **[SuperLearner](https://cran.r-project.org/package=SuperLearner)**
package provides a framework for ensemble machine learning in R. The
algorithm utilizes V-fold cross-validation to combine multiple
prediction algorithms into a single ensemble predictor. Since
cross-validation involves training many models independently, it is a
perfect candidate for parallelization.

### Example: Cross-Validated Super Learner

The
[`CV.SuperLearner()`](https://rdrr.io/pkg/SuperLearner/man/CV.SuperLearner.html)
function evaluates the cross-validated risk of the Super Learner
ensemble. For example:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`SuperLearner`](https://github.com/ecpolley/SuperLearner)`)`\
\
`n`` ``<-`` ``100`\
`p`` ``<-`` ``5`\
`X`` ``<-`` `[`as.data.frame`](https://rdrr.io/r/base/as.data.frame.html)`(`[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n`` ``*`` ``p``)``, ``n``, ``p``)``)`\
`Y`` ``<-`` ``X``[``, ``1``]`` ``+`` ``X``[``, ``2``]`` ``+`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n``)`\
`SL.library`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"SL.glm"``, ``"SL.mean"``)`\
\
`res`` ``<-`` `[`CV.SuperLearner`](https://rdrr.io/pkg/SuperLearner/man/CV.SuperLearner.html)`(``Y ``=`` ``Y``, X ``=`` ``X``, V ``=`` ``10``, SL.library ``=`` ``SL.library``)`

Here
[`CV.SuperLearner()`](https://rdrr.io/pkg/SuperLearner/man/CV.SuperLearner.html)
evaluates sequentially. To run in parallel, pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`SuperLearner`](https://github.com/ecpolley/SuperLearner)`)`\
\
`res`` ``<-`` `[`CV.SuperLearner`](https://rdrr.io/pkg/SuperLearner/man/CV.SuperLearner.html)`(``Y ``=`` ``Y``, X ``=`` ``X``, V ``=`` ``10``, SL.library ``=`` ``SL.library``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the cross-validation fold evaluations across the
available parallel workers, given that we have set up parallel workers,
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

The following **SuperLearner** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`CV.SuperLearner()`](https://rdrr.io/pkg/SuperLearner/man/CV.SuperLearner.html)
  with `seed = TRUE` as the default
