<!--
%\VignetteIndexEntry{Parallelize 'Sim.DiffProc' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Sim.DiffProc}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/futurize-logo.webp" alt="The 'futurize' hexlogo">
<span>=</span>
<img src="../man/figures/future-logo.webp" alt="The 'future' logo">
</div>

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!

# TL;DR

```r
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

# Introduction

This vignette demonstrates how to use this approach to parallelize
**[Sim.DiffProc]** functions such as `MCM.sde()`.

The **[Sim.DiffProc]** package provides a comprehensive framework for
numerical simulation and inference of Stochastic Differential
Equations (SDEs) in R. Because Monte Carlo simulation is highly
iterative, running multiple replications in parallel can significantly
reduce execution times.

## Example: Monte Carlo simulation of SDEs

The `MCM.sde()` function performs Monte Carlo simulations for SDEs.
For example:

```r
library(Sim.DiffProc)

f <- expression(0)
g <- expression(1)
mod1d <- snssde1d(drift = f, diffusion = g, x0 = 1, M = 10, N = 100)
stat <- function(x, ...) mean(x)

res <- MCM.sde(mod1d, statistic = stat, R = 10, time = 0.5)
```

Here `MCM.sde()` evaluates sequentially. To run in parallel,
pipe to `futurize()`:

```r
library(futurize)
library(Sim.DiffProc)

res <- MCM.sde(mod1d, statistic = stat, R = 10, time = 0.5) |> futurize()
```

This will distribute the Monte Carlo replications across the available
parallel workers, given that we have set up parallel workers, e.g.

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and works on all operating systems. There are [other parallel
backends] to choose from, including alternatives to parallelize
locally as well as distributed across remote machines, e.g.

```r
plan(future.mirai::mirai_multisession)
```

and

```r
plan(future.batchtools::batchtools_slurm)
```

# Supported Functions

The following **Sim.DiffProc** functions are supported by `futurize()`:

* `MCM.sde()` with `seed = TRUE` as the default

[Sim.DiffProc]: https://cran.r-project.org/package=Sim.DiffProc
[other parallel backends]: https://www.futureverse.org/backends.html
