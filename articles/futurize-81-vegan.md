# Parallelize 'vegan' functions

![The 'vegan' logo](../reference/figures/cran-vegan-logo.svg)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.png)= ![The
'future' logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(vegan)

data(dune)
data(dune.env)
dune.mrpp <- with(dune.env, {
  mrpp(dune, Management) |> futurize()
})
```

## Introduction

The **[vegan](https://cran.r-project.org/package=vegan)** package
provides methods for community and vegetation ecologists. Some of the
functions has built-in support for parallelization, which the
**futurize** simplifies further.

### Example:

Example adopted from
[`help("mrpp", package = "vegan")`](https://vegandevs.github.io/vegan/reference/mrpp.html):

``` r

library(futurize)
plan(multisession)
library(vegan)

data(dune)
data(dune.env)
dune.mrpp <- with(dune.env, {
  mrpp(dune, Management) |> futurize()
})
```

This will parallelize the computations, given that we have set up
parallel workers, e.g.

``` r

plan(multisession)
```

The built-in `multisession` backend parallelizes on your local computer
and works on all operating systems. There are [other parallel
backends](https://www.futureverse.org/backends.html) to choose from,
including alternatives to parallelize locally as well as distributed
across remote machines, e.g.

``` r

plan(future.mirai::mirai_multisession)
```

and

``` r

plan(future.batchtools::batchtools_slurm)
```

## Supported Functions

The following **vegan** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`adonis()`](https://vegandevs.github.io/vegan/reference/vegan-defunct.html)
- [`adonis2()`](https://vegandevs.github.io/vegan/reference/adonis.html)
- [`anosim()`](https://vegandevs.github.io/vegan/reference/anosim.html)
- [`cascadeKM()`](https://vegandevs.github.io/vegan/reference/cascadeKM.html)
- [`estaccumR()`](https://vegandevs.github.io/vegan/reference/specpool.html)
- [`mantel()`](https://vegandevs.github.io/vegan/reference/mantel.html)
- [`mantel.partial()`](https://vegandevs.github.io/vegan/reference/mantel.html)
- [`metaMDSiter()`](https://vegandevs.github.io/vegan/reference/metaMDS.html)
- [`mrpp()`](https://vegandevs.github.io/vegan/reference/mrpp.html)
- [`oecosimu()`](https://vegandevs.github.io/vegan/reference/oecosimu.html)
- [`ordiareatest()`](https://vegandevs.github.io/vegan/reference/ordihull.html)
- [`simper()`](https://vegandevs.github.io/vegan/reference/simper.html)
