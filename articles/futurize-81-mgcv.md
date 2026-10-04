# Parallelize 'mgcv' functions

![The 'mgcv' image](../reference/figures/cran-mgcv-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(``mgcv``)`\
\
`## Adopted from example("bam", package = "mgcv")`\
`dat`` ``<-`` `[`gamSim`](https://rdrr.io/pkg/mgcv/man/gamSim.html)`(``1``, n ``=`` ``25000``, dist ``=`` ``"normal"``, scale ``=`` ``20``)`\
`bs`` ``<-`` ``"cr"`\
`k`` ``<-`` ``12`\
\
`b`` ``<-`` `[`bam`](https://rdrr.io/pkg/mgcv/man/bam.html)`(``y`` ``~`` `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x0``, bs ``=`` ``bs``)`` ``+`` `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x1``, bs ``=`` ``bs``)`` ``+`` `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x2``, bs ``=`` ``bs``, k ``=`` ``k``)`` ``+`\
`             `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x3``, bs ``=`` ``bs``)``, data ``=`` ``dat``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[mgcv](https://cran.r-project.org/package=mgcv)** functions such as
[`bam()`](https://rdrr.io/pkg/mgcv/man/bam.html).

The **[mgcv](https://cran.r-project.org/package=mgcv)** package is one
of the “recommended” packages in R. It provides methods for fitting
Generalized Additive Models (GAMs). The
[`bam()`](https://rdrr.io/pkg/mgcv/man/bam.html) function can be used to
fit GAMs for massive datasets (“Big Additive Models”) with many
thousands of observations, making it an excellent candidate for
parallelization.

### Example: Fitting a Big Additive Model

The [`bam()`](https://rdrr.io/pkg/mgcv/man/bam.html) function supports
parallel processing by setting up a **parallel** cluster and passing it
as argument `cluster`. This is abstracted away by **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(``mgcv``)`\
\
`## Adopted from example("bam", package = "mgcv")`\
`dat`` ``<-`` `[`gamSim`](https://rdrr.io/pkg/mgcv/man/gamSim.html)`(``1``, n ``=`` ``25000``, dist ``=`` ``"normal"``, scale ``=`` ``20``)`\
`bs`` ``<-`` ``"cr"`\
`k`` ``<-`` ``12`\
\
`b`` ``<-`` `[`bam`](https://rdrr.io/pkg/mgcv/man/bam.html)`(``y`` ``~`` `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x0``, bs ``=`` ``bs``)`` ``+`` `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x1``, bs ``=`` ``bs``)`` ``+`` `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x2``, bs ``=`` ``bs``, k ``=`` ``k``)`` ``+`\
`             `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x3``, bs ``=`` ``bs``)``, data ``=`` ``dat``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the calculations across the available parallel
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

The following **mgcv** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`bam()`](https://rdrr.io/pkg/mgcv/man/bam.html)
- [`predict()`](https://rdrr.io/r/stats/predict.html) for ‘bam’

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`bam()`](https://rdrr.io/pkg/mgcv/man/bam.html) using the **parallel**
package directly, without **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(``mgcv``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
\
`## Adopted from example("bam", package = "mgcv")`\
`dat`` ``<-`` `[`gamSim`](https://rdrr.io/pkg/mgcv/man/gamSim.html)`(``1``, n ``=`` ``25000``, dist ``=`` ``"normal"``, scale ``=`` ``20``)`\
`bs`` ``<-`` ``"cr"`\
`k`` ``<-`` ``12`\
\
`## Set up a PSOCK cluster`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
\
`## Fit the model in parallel`\
`b`` ``<-`` `[`bam`](https://rdrr.io/pkg/mgcv/man/bam.html)`(``y`` ``~`` `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x0``, bs ``=`` ``bs``)`` ``+`` `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x1``, bs ``=`` ``bs``)`` ``+`` `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x2``, bs ``=`` ``bs``, k ``=`` ``k``)`` ``+`\
`             `[`s`](https://rdrr.io/pkg/mgcv/man/s.html)`(``x3``, bs ``=`` ``bs``)``, data ``=`` ``dat``, cluster ``=`` ``cl``)`\
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
