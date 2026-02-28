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
<img src="../man/figures/TSP-logo.svg" alt="The 'TSP' hexlogo">
<span>+</span>
<img src="../man/figures/futurize-logo.png" alt="The 'futurize' hexlogo">
<span>=</span>
<img src="../man/figures/future-logo.png" alt="The 'future' logo">
</div>

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!


# TL;DR

```r
library(futurize)
plan(multisession)
library(TSP)

tour <- solve_TSP(USCA50, method = "nn", rep = 10L) |> futurize()
```

# Introduction

The **[TSP]** package provides algorithms for solving the traveling
salesperson problem (TSP).

## Example: 

Example adopted from `help("solve_RSP", package = "TSP")`:

```r
library(futurize)
plan(multisession)
library(TSP)

data("USCA50")
methods <- c("identity", "random", "nearest_insertion", "cheapest_insertion", "farthest_insertion", "arbitrary_insertion", "nn", "repetitive_nn", "two_opt", "
sa")

## calculate tours
tours <- lapply(methods, FUN = function(m) solve_TSP(USCA50, method = m))
names(tours) <- methods

tours$'nn+rep_10' <- solve_TSP(USCA50, method = "nn", rep = 10L) |> futurize()
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


[TSP]: https://cran.r-project.org/package=TSP
[other parallel backends]: https://www.futureverse.org/backends.html
