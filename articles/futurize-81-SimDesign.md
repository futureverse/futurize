# Parallelize 'SimDesign' functions

![The CRAN 'SimDesign'
package](../reference/figures/cran-SimDesign-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`SimDesign`](http://philchalmers.github.io/SimDesign/)`)`\
\
`res`` ``<-`` `[`runSimulation`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)`(`\
`  design ``=`` ``Design``,`\
`  replications ``=`` ``1000``,`\
`  generate ``=`` ``Generate``,`\
`  analyse ``=`` ``Analyse``,`\
`  summarise ``=`` ``Summarise`\
`)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[SimDesign](https://cran.r-project.org/package=SimDesign)** functions
such as
[`runSimulation()`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md).

The **[SimDesign](https://cran.r-project.org/package=SimDesign)**
package provides a comprehensive framework for organizing Monte Carlo
simulation experiments in R. It uses a structured
generate-analyse-summarise workflow for designing, executing, and
summarizing simulation studies. The replication-based nature of
simulations makes them excellent candidates for parallelization.

### Example: Monte Carlo simulation

The
[`runSimulation()`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)
function runs Monte Carlo simulations over a design of experimental
conditions. For example:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`SimDesign`](http://philchalmers.github.io/SimDesign/)`)`\
\
`Design`` ``<-`` `[`createDesign`](http://philchalmers.github.io/SimDesign/reference/createDesign.md)`(`\
`  sample_size ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``10``, ``20``, ``40``)``,`\
`  distribution ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"norm"``, ``"chi"``)`\
`)`\
\
`Generate`` ``<-`` ``function``(``condition``, ``fixed_objects``)`` ``{`\
`  ``N`` ``<-`` ``condition``$``sample_size`\
`  ``dist`` ``<-`` ``condition``$``distribution`\
`  ``if`` ``(``dist`` ``==`` ``"norm"``)`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``N``)`` ``else`` `[`rchisq`](https://rdrr.io/r/stats/Chisquare.html)`(``N``, df ``=`` ``5``)`\
`}`\
\
`Analyse`` ``<-`` ``function``(``condition``, ``dat``, ``fixed_objects``)`` ``{`\
`  `[`c`](https://rdrr.io/r/base/c.html)`(``mean_est ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``dat``)``)`\
`}`\
\
`Summarise`` ``<-`` ``function``(``condition``, ``results``, ``fixed_objects``)`` ``{`\
`  ``obs_bias`` ``<-`` `[`bias`](http://philchalmers.github.io/SimDesign/reference/bias.md)`(``results``[``, ``"mean_est"``]``,`\
`    parameter ``=`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``condition``$``distribution`` ``==`` ``"norm"``, ``0``, ``5``)``)`\
`  ``obs_RMSE`` ``<-`` `[`RMSE`](http://philchalmers.github.io/SimDesign/reference/RMSE.md)`(``results``[``, ``"mean_est"``]``,`\
`    parameter ``=`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``condition``$``distribution`` ``==`` ``"norm"``, ``0``, ``5``)``)`\
`  `[`c`](https://rdrr.io/r/base/c.html)`(``bias ``=`` ``obs_bias``, RMSE ``=`` ``obs_RMSE``)`\
`}`\
\
`res`` ``<-`` `[`runSimulation`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)`(`\
`  design ``=`` ``Design``,`\
`  replications ``=`` ``100``,`\
`  generate ``=`` ``Generate``,`\
`  analyse ``=`` ``Analyse``,`\
`  summarise ``=`` ``Summarise`\
`)`

Here
[`runSimulation()`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)
evaluates sequentially. To run in parallel, pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`SimDesign`](http://philchalmers.github.io/SimDesign/)`)`\
\
`res`` ``<-`` `[`runSimulation`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)`(`\
`  design ``=`` ``Design``,`\
`  replications ``=`` ``100``,`\
`  generate ``=`` ``Generate``,`\
`  analyse ``=`` ``Analyse``,`\
`  summarise ``=`` ``Summarise`\
`)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the replications across the available parallel
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

The following **SimDesign** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`runSimulation()`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)
- [`runArraySimulation()`](http://philchalmers.github.io/SimDesign/reference/runArraySimulation.md)
