# Parallelize 'TSP' functions

![The 'TSP' hexlogo](../reference/figures/TSP-logo.svg)+ ![The
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
library(TSP)

tour <- solve_TSP(USCA50, method = "nn", rep = 10L) |> futurize()
```

## Introduction

The **[TSP](https://cran.r-project.org/package=TSP)** package provides
algorithms for solving the traveling salesperson problem (TSP).

### Example:

Example adopted from `help("solve_RSP", package = "TSP")`:

``` r

library(futurize)
plan(multisession)
library(TSP)

data("USCA50")
methods <- c(
  "identity", "random", "nearest_insertion", "cheapest_insertion",
  "farthest_insertion", "arbitrary_insertion", "nn", "repetitive_nn", 
  "two_opt", "sa"
)

## calculate tours - each tour in parallel
tours <- lapply(methods, FUN = function(m) {
  solve_TSP(USCA50, rep = 10L, method = m) |> futurize()
})
names(tours) <- methods
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

The following **TSP** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`solve_TSP()`](https://rdrr.io/pkg/TSP/man/solve_TSP.html)
