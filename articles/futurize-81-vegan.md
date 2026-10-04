# Parallelize 'vegan' functions

![The 'vegan' logo](../reference/figures/cran-vegan-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`vegan`](https://vegandevs.github.io/vegan/)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``dune``)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``dune.env``)`\
`dune.mrpp`` ``<-`` `[`with`](https://rdrr.io/r/base/with.html)`(``dune.env``, ``{`` `[`mrpp`](https://vegandevs.github.io/vegan/reference/mrpp.html)`(``dune``, ``Management``)`` ``}``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

The **[vegan](https://cran.r-project.org/package=vegan)** package
provides methods for community and vegetation ecologists. Some of the
functions have built-in support for parallelization, which **futurize**
simplifies further.

### Example: MRPP

Example adopted from
[`help("mrpp", package = "vegan")`](https://vegandevs.github.io/vegan/reference/mrpp.html):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`vegan`](https://vegandevs.github.io/vegan/)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``dune``)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``dune.env``)`\
`dune.mrpp`` ``<-`` `[`with`](https://rdrr.io/r/base/with.html)`(``dune.env``, ``{`` `[`mrpp`](https://vegandevs.github.io/vegan/reference/mrpp.html)`(``dune``, ``Management``)`` ``}``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

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

### Example: anova() for ‘cca’ objects

The [`anova()`](https://rdrr.io/r/stats/anova.html) S3 method for ‘cca’
objects supports parallelization via the `parallel` argument. With
**futurize**, you can parallelize this directly. Example adopted from
[`help("anova.cca", package = "vegan")`](https://vegandevs.github.io/vegan/reference/anova.cca.html):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`vegan`](https://vegandevs.github.io/vegan/)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``dune``)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``dune.env``)`\
`ord`` ``<-`` `[`cca`](https://vegandevs.github.io/vegan/reference/cca.html)`(``dune`` ``~`` ``A1`` ``+`` ``Management``, data ``=`` ``dune.env``)`\
`res`` ``<-`` `[`anova`](https://rdrr.io/r/stats/anova.html)`(``ord``, permutations ``=`` ``99``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Supported Functions

The following **vegan** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`adonis()`](https://vegandevs.github.io/vegan/reference/vegan-defunct.html)
- [`adonis2()`](https://vegandevs.github.io/vegan/reference/adonis.html)
- [`anova()`](https://rdrr.io/r/stats/anova.html) for ‘cca’
- [`anosim()`](https://vegandevs.github.io/vegan/reference/anosim.html)
- [`cascadeKM()`](https://vegandevs.github.io/vegan/reference/cascadeKM.html)
  with `seed = TRUE` as the default
- [`estaccumR()`](https://vegandevs.github.io/vegan/reference/specpool.html)
- [`mantel()`](https://vegandevs.github.io/vegan/reference/mantel.html)
- [`mantel.partial()`](https://vegandevs.github.io/vegan/reference/mantel.html)
- [`metaMDSiter()`](https://vegandevs.github.io/vegan/reference/metaMDS.html)
- [`mrpp()`](https://vegandevs.github.io/vegan/reference/mrpp.html)
- [`oecosimu()`](https://vegandevs.github.io/vegan/reference/oecosimu.html)
- [`ordiareatest()`](https://vegandevs.github.io/vegan/reference/ordihull.html)
- [`permutest()`](https://vegandevs.github.io/vegan/reference/anova.cca.html)
  for ‘betadisper’, and ‘cca’

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`mrpp()`](https://vegandevs.github.io/vegan/reference/mrpp.html) using
the **parallel** package directly, without **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`vegan`](https://vegandevs.github.io/vegan/)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``dune``)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``dune.env``)`\
\
`## Set up a PSOCK cluster`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
\
`## Run MRPP in parallel`\
`dune.mrpp`` ``<-`` `[`with`](https://rdrr.io/r/base/with.html)`(``dune.env``, ``{`\
`  `[`mrpp`](https://vegandevs.github.io/vegan/reference/mrpp.html)`(``dune``, ``Management``, parallel ``=`` ``cl``)`\
`}``)`\
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
