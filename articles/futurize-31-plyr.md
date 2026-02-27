# Parallelize 'plyr' functions

![The 'plyr' image](../reference/figures/cran-plyr-logo.svg)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.png)= ![The
'future' logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(plyr)
library(futurize)
plan(multisession)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:1000
ys <- llply(xs, slow_fcn) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[plyr](https://cran.r-project.org/package=plyr)** functions such as
[`llply()`](https://rdrr.io/pkg/plyr/man/llply.html),
[`maply()`](https://rdrr.io/pkg/plyr/man/maply.html), and
[`ddply()`](https://rdrr.io/pkg/plyr/man/ddply.html).

The **plyr** [`llply()`](https://rdrr.io/pkg/plyr/man/llply.html)
function is commonly used to apply a function to the elements of a list
and return a list. For example,

``` r

library(plyr)
xs <- 1:1000
ys <- llply(xs, slow_fcn)
```

Here [`llply()`](https://rdrr.io/pkg/plyr/man/llply.html) evaluates
sequentially, but we can easily make it evaluate in parallel, by using:

``` r

library(futurize)
library(plyr)
xs <- 1:1000
ys <- xs |> llply(slow_fcn) |> futurize()
```

This will distribute the calculations across the available parallel
workers, given that we have set parallel workers, e.g.

``` r

plan(multisession)
```

The built-in `multisession` backend parallelizes on your local computer
and it works on all operating systems. There are [other parallel
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

Another example is:

``` r

library(plyr)
library(futurize)
plan(future.mirai::mirai_multisession)

ys <- llply(baseball, summary) |> futurize()
```

## Supported Functions

The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function supports parallelization of the following **plyr** functions:

- [`a_ply()`](https://rdrr.io/pkg/plyr/man/a_ply.html),
  [`aaply()`](https://rdrr.io/pkg/plyr/man/aaply.html),
  [`adply()`](https://rdrr.io/pkg/plyr/man/adply.html),
  [`alply()`](https://rdrr.io/pkg/plyr/man/alply.html)
- [`d_ply()`](https://rdrr.io/pkg/plyr/man/d_ply.html),
  [`daply()`](https://rdrr.io/pkg/plyr/man/daply.html),
  [`ddply()`](https://rdrr.io/pkg/plyr/man/ddply.html),
  [`dlply()`](https://rdrr.io/pkg/plyr/man/dlply.html)
- [`l_ply()`](https://rdrr.io/pkg/plyr/man/l_ply.html),
  [`laply()`](https://rdrr.io/pkg/plyr/man/laply.html),
  [`ldply()`](https://rdrr.io/pkg/plyr/man/ldply.html),
  [`llply()`](https://rdrr.io/pkg/plyr/man/llply.html)
- [`m_ply()`](https://rdrr.io/pkg/plyr/man/m_ply.html),
  [`maply()`](https://rdrr.io/pkg/plyr/man/maply.html),
  [`mdply()`](https://rdrr.io/pkg/plyr/man/mdply.html),
  [`mlply()`](https://rdrr.io/pkg/plyr/man/mlply.html)
