# Parallelize 'BiocNeighbors' functions

![The 'futurize' hexlogo](../reference/figures/futurize-logo.png)= ![The
'future' logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(BiocNeighbors)

res <- findKNN(X, k = 10) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[BiocNeighbors](https://bioconductor.org/packages/BiocNeighbors/)**
functions.

The
**[BiocNeighbors](https://bioconductor.org/packages/BiocNeighbors/)**
Bioconductor package implements exact and approximate methods for
nearest neighbor detection, in a framework that allows them to be easily
switched within Bioconductor packages or workflows. It supports several
algorithms including k-means clustering for k-nearest neighbors (KMKNN),
vantage point trees, Annoy, and HNSW. The package supports
parallelization via BiocParallel’s BPPARAM argument.

### Example: Finding k-nearest neighbors in parallel

The [`findKNN()`](https://rdrr.io/pkg/BiocNeighbors/man/findKNN.html)
function finds the k-nearest neighbors for each point in a dataset:

``` r

library(BiocNeighbors)

set.seed(42)
n_points <- 1000L
n_dims <- 50L
X <- matrix(rnorm(n_points * n_dims), nrow = n_points, ncol = n_dims)

res <- findKNN(X, k = 10)
```

Here [`findKNN()`](https://rdrr.io/pkg/BiocNeighbors/man/findKNN.html)
runs sequentially, but we can easily make it run in parallel by piping
to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)

res <- findKNN(X, k = 10) |> futurize()
```

This will distribute the work across the available parallel workers,
given that we have set up parallel workers, e.g.

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

### Querying nearest neighbors

You can also query nearest neighbors for new data points against an
existing dataset:

``` r

query <- matrix(rnorm(20 * n_dims), nrow = 20, ncol = n_dims)
res <- queryKNN(X, query = query, k = 10) |> futurize()
```

### Range-based neighbor searches

For finding all neighbors within a distance threshold:

``` r

res <- findNeighbors(X, threshold = 3) |> futurize()
```

## Supported Functions

The following **BiocNeighbors** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`findKNN()`](https://rdrr.io/pkg/BiocNeighbors/man/findKNN.html)
- [`findNeighbors()`](https://rdrr.io/pkg/BiocNeighbors/man/findNeighbors.html)
- [`queryKNN()`](https://rdrr.io/pkg/BiocNeighbors/man/queryKNN.html)
- [`queryNeighbors()`](https://rdrr.io/pkg/BiocNeighbors/man/queryNeighbors.html)
