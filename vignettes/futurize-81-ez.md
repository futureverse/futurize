<!--
%\VignetteIndexEntry{Parallelize 'ez' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{ez}
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
library(ez)

data(ANT)
rt <- ezBoot(
  data = ANT,
  dv = rt,
  wid = subnum,
  within = .(cue, flank),
  between = group,
  iterations = 1e3
) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
**[ez]** functions such as `ezBoot()`, `ezPerm()`, and `ezPlot2()`.
The functions `ezBoot()`, `ezPerm()`, and `ezPlot2()` support parallel
evaluation via the `parallel` argument. By piping to `futurize()`, you
can leverage any future-based parallel backend for these computations.


## Example: Bootstrap resampling

The `ezBoot()` function computes bootstrap resampled predictions for
each cell in an experimental design. We can parallelize this as:

```r
library(futurize)
plan(multisession)
library(ez)

data(ANT)
rt <- ezBoot(
  data = ANT,
  dv = rt,
  wid = subnum,
  within = .(cue, flank),
  between = group,
  iterations = 1e3
) |> futurize()
```

This will distribute the bootstrap iterations across the available
parallel workers.


## Example: Permutation testing

The `ezPerm()` function performs a non-parametric factorial
permutation test, and can be parallelized as:

```r
library(futurize)
plan(multisession)
library(ez)
library(plyr)

data(ANT)
cell_stats <- ddply(
  .data = ANT,
  .variables = .(subnum, group, cue, flank),
  .fun = function(x) {
    data.frame(mrt = mean(x$rt[x$error == 0]))
  }
)
gmrt <- ddply(
  .data = cell_stats,
  .variables = .(subnum, group),
  .fun = function(x) {
    data.frame(mrt = mean(x$mrt))
  }
)

mean_rt_perm <- ezPerm(
  data = gmrt,
  dv = mrt,
  wid = subnum,
  between = group,
  perms = 1e3
) |> futurize()
```


# Supported Functions

The following **ez** functions are supported by `futurize()`:

* `ezBoot()` with `seed = TRUE` as the default
* `ezPerm()` with `seed = TRUE` as the default
* `ezPlot2()`


[ez]: https://cran.r-project.org/package=ez
[other parallel backends]: https://www.futureverse.org/backends.html
