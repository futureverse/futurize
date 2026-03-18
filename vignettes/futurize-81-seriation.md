<!--
%\VignetteIndexEntry{Parallelize 'seriation' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{seriation}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/seriation-logo.webp" alt="The 'seriation' image">
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
library(seriation)

o <- seriation::seriate_best(d_supreme) |> futurize()
```


# Introduction

The **[seriation]** package provides functions for ordering objects
using seriation, ordination techniques for reordering matrices,
dissimilarity matrices, and dendrograms.


## Example: Seriate best

Example adopted from `help("seriate_best", package = "seriation")`:

```r
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

The following **seriation** functions are supported by `futurize()`:

* `seriate_best()`
* `seriate_rep()`


[seriation]: https://cran.r-project.org/package=seriation
[other parallel backends]: https://www.futureverse.org/backends.html
