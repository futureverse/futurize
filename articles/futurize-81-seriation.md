# Parallelize 'seriation' functions

![The 'seriation' image](../reference/figures/seriation-logo.webp)+
![The 'futurize' hexlogo](../reference/figures/futurize-logo.webp)=
![The 'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(seriation)

o <- seriation::seriate_best(d_supreme) |> futurize()
```

## Introduction

The **[seriation](https://cran.r-project.org/package=seriation)**
package provides functions for ordering objects using seriation,
ordination techniques for reordering matrices, dissimilarity matrices,
and dendrograms.

### Example: Seriate best

Example adopted from
[`help("seriate_best", package = "seriation")`](https://rdrr.io/pkg/seriation/man/seriate_best.html):

``` r

library(futurize)
plan(multisession)
library(seriation)

data(SupremeCourt)
d_supreme <- as.dist(SupremeCourt)

o <- seriate_best(d_supreme, criterion = "AR_events") |> futurize()
print(o)
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

The following **seriation** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`seriate_best()`](https://rdrr.io/pkg/seriation/man/seriate_best.html)
- [`seriate_rep()`](https://rdrr.io/pkg/seriation/man/seriate_best.html)
