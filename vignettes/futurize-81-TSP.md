<!--
%\VignetteIndexEntry{Parallelize 'TSP' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{TSP}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/TSP-logo.webp" alt="The 'TSP' hexlogo">
<span>+</span>
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
library(TSP)

data("USCA50")
tour <- solve_TSP(USCA50, method = "nn", rep = 10L) |> futurize()
```

# Introduction

The **[TSP]** package provides algorithms for solving the traveling
salesperson problem (TSP).

## Example: 

Example adopted from `help("solve_TSP", package = "TSP")`:

```r
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

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and works on all operating systems. There are [other
parallel backends] to choose from, including alternatives to
parallelize locally as well as distributed across remote machines,
e.g.

```r
plan(future.mirai::mirai_multisession)
```

and

```r
plan(future.batchtools::batchtools_slurm)
```


# Supported Functions

The following **TSP** functions are supported by `futurize()`:

* `solve_TSP()`


# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize `solve_TSP()`
using the **parallel** and **doParallel** packages directly, without
**futurize**:

```r
library(TSP)
library(parallel)
library(doParallel)

data("USCA50")

## Set up a PSOCK cluster and register it with foreach
ncpus <- 4L
cl <- makeCluster(ncpus)
registerDoParallel(cl)

## Solve the TSP in parallel via foreach
tour <- solve_TSP(USCA50, method = "nn", rep = 10L)

## Tear down the cluster
stopCluster(cl)
registerDoSEQ()  ## reset foreach to sequential
```

This requires you to manually create a cluster, register it with
**doParallel**, and remember to tear it down and reset the
**foreach** backend when done. If you forget to call
`stopCluster()`, or if your code errors out before reaching it, you
leak background R processes. You also have to decide upfront how
many CPUs to use and what cluster type to use. Switching to another
parallel backend, e.g. a Slurm cluster, would require a completely
different setup. With **futurize**, all of this is handled for you - just pipe
to `futurize()` and control the backend with `plan()`.


[TSP]: https://cran.r-project.org/package=TSP
[other parallel backends]: https://www.futureverse.org/backends.html
