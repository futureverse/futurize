# Parallelize 'boot' functions

![The 'boot' image](../reference/figures/cran-boot-logo.svg)+ ![The
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
library(boot)

ratio <- function(pop, w) sum(w * pop$x) / sum(w * pop$u)
b <- boot(bigcity, statistic = ratio, R = 999, stype = "w") |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[boot](https://cran.r-project.org/package=boot)** functions such as
[`boot()`](https://rdrr.io/pkg/boot/man/boot.html),
[`censboot()`](https://rdrr.io/pkg/boot/man/censboot.html), and
[`tsboot()`](https://rdrr.io/pkg/boot/man/tsboot.html).

The **[boot](https://cran.r-project.org/package=boot)** package is one
of the “recommended” R packages, meaning it is officially endorsed by
the R Core Team, well maintained, and installed by default with R. The
package generates bootstrap samples and provides statistical methods
around them. Given the resampling nature of bootstrapping, the
algorithms are excellent candidates for parallelization.

### Example: Bootstrap sampling

The core function [`boot()`](https://rdrr.io/pkg/boot/man/boot.html)
produces bootstrap samples of a statistic applied to data. For example,
consider the `bigcity` dataset, which contains populations of 49 large
U.S. cities in 1920 (`u`) and 1930 (`x`):

``` r
library(boot)

## Draw 999 bootstrap samples of the population data. For each
## sample, calculate the ratio of mean-1930 over mean-1920 populations
ratio <- function(pop, w) sum(w * pop$x) / sum(w * pop$u)
b <- boot(bigcity, statistic = ratio, R = 999, stype = "w")
```

Here [`boot()`](https://rdrr.io/pkg/boot/man/boot.html) evaluates
sequentially, but we can easily make it evaluate in parallel by piping
to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r
library(futurize)
library(boot)

ratio <- function(pop, w) sum(w * pop$x) / sum(w * pop$u)
b <- boot(bigcity, statistic = ratio, R = 999, stype = "w") |> futurize()
```

This will distribute the 999 bootstrap samples across the available
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

### Example: Time series bootstrap

The [`tsboot()`](https://rdrr.io/pkg/boot/man/tsboot.html) function
generates bootstrap samples from time series data. For example, here we
fit autoregressive models to bootstrap replicates of the `lynx` time
series:

``` r
library(futurize)
plan(multisession)
library(boot)

## Fit AR models to bootstrap replicates of the lynx time series
lynx_fun <- function(tsb) {
    ar_fit <- ar(tsb, order.max = 25)
    c(ar_fit$order, mean(tsb), tsb)
}

lynx_boot <- tsboot(log(lynx), lynx_fun, R = 99, l = 20, sim = "geom") |> futurize()
```

## Supported Functions

The following **boot** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`boot()`](https://rdrr.io/pkg/boot/man/boot.html)
- [`censboot()`](https://rdrr.io/pkg/boot/man/censboot.html)
- [`tsboot()`](https://rdrr.io/pkg/boot/man/tsboot.html)
