# Parallelize 'ez' functions

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

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[ez](https://cran.r-project.org/package=ez)** functions such as
[`ezBoot()`](https://rdrr.io/pkg/ez/man/ezBoot.html),
[`ezPerm()`](https://rdrr.io/pkg/ez/man/ezPerm.html), and
[`ezPlot2()`](https://rdrr.io/pkg/ez/man/ezPlot2.html). The functions
[`ezBoot()`](https://rdrr.io/pkg/ez/man/ezBoot.html),
[`ezPerm()`](https://rdrr.io/pkg/ez/man/ezPerm.html), and
[`ezPlot2()`](https://rdrr.io/pkg/ez/man/ezPlot2.html) support parallel
evaluation via the `parallel` argument. By piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md),
you can leverage any future-based parallel backend for these
computations.

### Example: Bootstrap resampling

The [`ezBoot()`](https://rdrr.io/pkg/ez/man/ezBoot.html) function
computes bootstrap resampled predictions for each cell in an
experimental design. We can parallelize this as:

``` r

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

### Example: Permutation testing

The [`ezPerm()`](https://rdrr.io/pkg/ez/man/ezPerm.html) function
performs a non-parametric factorial permutation test, and can be
parallelized as:

``` r

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

## Supported Functions

The following **ez** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`ezBoot()`](https://rdrr.io/pkg/ez/man/ezBoot.html) with
  `seed = TRUE` as the default
- [`ezPerm()`](https://rdrr.io/pkg/ez/man/ezPerm.html) with
  `seed = TRUE` as the default
- [`ezPlot2()`](https://rdrr.io/pkg/ez/man/ezPlot2.html)
