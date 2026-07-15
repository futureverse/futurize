# Parallelize 'Sim.DiffProc' functions

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
library(Sim.DiffProc)

# Define 1D SDE model
f <- expression(0)
g <- expression(1)
mod1d <- snssde1d(drift = f, diffusion = g, x0 = 1, M = 10, N = 100)
stat <- function(x, ...) mean(x)

res <- MCM.sde(mod1d, statistic = stat, R = 10, time = 0.5) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[Sim.DiffProc](https://cran.r-project.org/package=Sim.DiffProc)**
functions such as
[`MCM.sde()`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html).

The **[Sim.DiffProc](https://cran.r-project.org/package=Sim.DiffProc)**
package provides a comprehensive framework for numerical simulation and
inference of Stochastic Differential Equations (SDEs) in R. Because
Monte Carlo simulation is highly iterative, running multiple
replications in parallel can significantly reduce execution times.

### Example: Monte Carlo simulation of SDEs

The [`MCM.sde()`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html)
function performs Monte Carlo simulations for SDEs. For example:

``` r

library(Sim.DiffProc)

f <- expression(0)
g <- expression(1)
mod1d <- snssde1d(drift = f, diffusion = g, x0 = 1, M = 10, N = 100)
stat <- function(x, ...) mean(x)

res <- MCM.sde(mod1d, statistic = stat, R = 10, time = 0.5)
```

Here [`MCM.sde()`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html)
evaluates sequentially. To run in parallel, pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)
library(Sim.DiffProc)

res <- MCM.sde(mod1d, statistic = stat, R = 10, time = 0.5) |> futurize()
```

This will distribute the Monte Carlo replications across the available
parallel workers, given that we have set up parallel workers, e.g.

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

The following **Sim.DiffProc** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`MCM.sde()`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html) with
  `seed = TRUE` as the default
