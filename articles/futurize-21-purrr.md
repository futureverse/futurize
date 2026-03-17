# Parallelize 'purrr' functions

![The 'purrr' logo](../reference/figures/purrr-logo.png)+ ![The
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
library(purrr)

slow_fcn <- function(x) {
  message("x = ", x)
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:10
ys <- xs |> map(slow_fcn) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[purrr](https://cran.r-project.org/package=purrr)** functions such as
[`map()`](https://purrr.tidyverse.org/reference/map.html),
[`map_dbl()`](https://purrr.tidyverse.org/reference/map.html), and
[`walk()`](https://purrr.tidyverse.org/reference/map.html).

The **purrr** [`map()`](https://purrr.tidyverse.org/reference/map.html)
function is commonly used to apply a function to the elements of a
vector or a list. For example,

``` r

library(purrr)
xs <- 1:1000
ys <- map(xs, slow_fcn)
```

or equivalently using pipe syntax

``` r

xs <- 1:1000
ys <- xs |> map(slow_fcn)
```

Here [`map()`](https://purrr.tidyverse.org/reference/map.html) evaluates
sequentially, but we can easily make it evaluate in parallel, by using:

``` r

library(purrr)

library(futurize)
plan(multisession) ## parallelize on local machine

xs <- 1:1000
ys <- xs |> map(slow_fcn) |> futurize()
#> x = 1
#> x = 2
#> x = 3
#> ...
#> x = 10
```

Note how messages produced on parallel workers are relayed as-is back to
the main R session as they complete. Not only messages, but also
warnings and other types of conditions are relayed back as-is. Likewise,
standard output produced by [`cat()`](https://rdrr.io/r/base/cat.html),
[`print()`](https://rdrr.io/r/base/print.html),
[`str()`](https://rdrr.io/r/utils/str.html), and so on is relayed in the
same way. This is a unique feature of Futureverse - other parallel
frameworks in R, such as **parallel**, **foreach** with **doParallel**,
and **BiocParallel**, silently drop standard output, messages, and
warnings produced on workers. With **futurize**, your code behaves the
same whether it runs sequentially or in parallel: nothing is lost in
translation.

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

library(purrr)
library(futurize)
plan(future.mirai::mirai_multisession)

ys <- 1:10 |>
        map(rnorm, n = 10) |> futurize(seed = TRUE) |>
        map_dbl(mean) |> futurize()
```

## Supported Functions

The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function supports parallelization of the following **purrr** functions:

- [`map()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_chr()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_dbl()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_int()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_lgl()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_raw()`](https://purrr.tidyverse.org/reference/map_raw.html),
  [`map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`map_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`walk()`](https://purrr.tidyverse.org/reference/map.html)
- [`map2()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_chr()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_dbl()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_int()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_lgl()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_raw()`](https://purrr.tidyverse.org/reference/map_raw.html),
  [`map2_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`map2_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`walk2()`](https://purrr.tidyverse.org/reference/map2.html)
- [`pmap()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_chr()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_dbl()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_int()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_lgl()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_raw()`](https://purrr.tidyverse.org/reference/map_raw.html),
  [`pmap_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`pmap_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`pwalk()`](https://purrr.tidyverse.org/reference/pmap.html)
- [`imap()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_chr()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_dbl()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_int()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_lgl()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_raw()`](https://purrr.tidyverse.org/reference/map_raw.html),
  [`imap_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`imap_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`iwalk()`](https://purrr.tidyverse.org/reference/imap.html)
- [`modify()`](https://purrr.tidyverse.org/reference/modify.html),
  [`modify_if()`](https://purrr.tidyverse.org/reference/modify.html),
  [`modify_at()`](https://purrr.tidyverse.org/reference/modify.html)
- [`map_if()`](https://purrr.tidyverse.org/reference/map_if.html),
  [`map_at()`](https://purrr.tidyverse.org/reference/map_if.html)
- [`invoke_map()`](https://purrr.tidyverse.org/reference/invoke.html),
  [`invoke_map_chr()`](https://purrr.tidyverse.org/reference/invoke.html),
  [`invoke_map_dbl()`](https://purrr.tidyverse.org/reference/invoke.html),
  [`invoke_map_int()`](https://purrr.tidyverse.org/reference/invoke.html),
  [`invoke_map_lgl()`](https://purrr.tidyverse.org/reference/invoke.html),
  [`invoke_map_raw()`](https://purrr.tidyverse.org/reference/invoke.html),
  [`invoke_map_dfr()`](https://purrr.tidyverse.org/reference/invoke.html),
  [`invoke_map_dfc()`](https://purrr.tidyverse.org/reference/invoke.html)
