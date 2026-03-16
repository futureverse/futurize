# Parallelize 'SimDesign' functions

![The CRAN 'SimDesign'
package](../reference/figures/cran-SimDesign-logo.svg)+ ![The 'futurize'
hexlogo](../reference/figures/futurize-logo.png)= ![The 'future'
logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(SimDesign)

res <- runSimulation(
  design = Design,
  replications = 1000,
  generate = Generate,
  analyse = Analyse,
  summarise = Summarise
) |> futurize()
```

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

``` r

library(SimDesign)

Design <- createDesign(
  sample_size = c(10, 20, 40),
  distribution = c("norm", "chi")
)

Generate <- function(condition, fixed_objects) {
  N <- condition$sample_size
  dist <- condition$distribution
  if (dist == "norm") rnorm(N) else rchisq(N, df = 5)
}

Analyse <- function(condition, dat, fixed_objects) {
  c(mean_est = mean(dat))
}

Summarise <- function(condition, results, fixed_objects) {
  obs_bias <- bias(results[, "mean_est"],
    parameter = ifelse(condition$distribution == "norm", 0, 5))
  obs_RMSE <- RMSE(results[, "mean_est"],
    parameter = ifelse(condition$distribution == "norm", 0, 5))
  c(bias = obs_bias, RMSE = obs_RMSE)
}

res <- runSimulation(
  design = Design,
  replications = 100,
  generate = Generate,
  analyse = Analyse,
  summarise = Summarise
)
```

Here
[`runSimulation()`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)
evaluates sequentially. To run in parallel, pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)
library(SimDesign)

res <- runSimulation(
  design = Design,
  replications = 100,
  generate = Generate,
  analyse = Analyse,
  summarise = Summarise
) |> futurize()
```

This will distribute the replications across the available parallel
workers, given that we have set up parallel workers, e.g.

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

The following **SimDesign** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`runSimulation()`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)
- [`runArraySimulation()`](http://philchalmers.github.io/SimDesign/reference/runArraySimulation.md)
