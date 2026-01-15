<!--
%\VignetteIndexEntry{Parallelize 'purrr' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{purrr}
%\VignetteKeyword{vignette}
%\VignetteKeyword{handlers}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/purrr-logo.png" alt="The 'purrr' logo">
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
library(purrr)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:1000
ys <- xs |> map(slow_fcn) |> futurize()
```


# Introduction

This vignette demonstrates how use this approach to parallelize **[purrr]**
functions such as `map()`, `map_dbl()`, and `walk()`.

The **purrr** `map()` function is commonly used to apply a function to
the elements of a vector or a list. For example, 

```r
library(purrr)
xs <- 1:1000
ys <- map(xs, slow_fcn)
```

or equivalently using pipe syntax

```r
library(purrr)
xs <- 1:1000
ys <- xs |> map(slow_fcn)
```

Here `map()` evaluates sequentially, but we can easily make it to
evaluate parallelly, by using:

```r
library(futurize)
library(purrr)
xs <- 1:1000
ys <- xs |> map(slow_fcn) |> futurize()
```

This will distribute the calculations across the available parallel
workers, given that we have set parallel workers, e.g.

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and it works on all operating system. There are [other
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

Another example is:

```r
library(purrr)
library(futurize)
plan(future.mirai::mirai_multisession)

ys <- 1:10 |>
        map(rnorm, n = 10) |> futurize(seed = TRUE) |>
        map_dbl(mean) |> futurize()
```


# Supported Functions

The `futurize()` function supports parallelization of the common base
R functions. The following **purrr** functions are supported:

 * `map()`, `map_chr()`, `map_dbl()`, `map_int()`, `map_lgl()`, `map_raw()`, `map_dfr()`, `map_dfc()`, `walk()`
 * `map2()`, `map2_chr()`, `map2_dbl()`, `map2_int()`, `map2_lgl()`, `map2_raw()`, `map2_dfr()`, `map2_dfc()`, `walk2()`
 * `pmap()`, `pmap_chr()`, `pmap_dbl()`, `pmap_int()`, `pmap_lgl()`, `pmap_raw()`, `pmap_dfr()`, `pmap_dfc()`, `pwalk()`
   `imap()`, `imap_chr()`, `imap_dbl()`, `imap_int()`, `imap_lgl()`, `imap_raw()`, `imap_dfr()`, `imap_dfc()`, `iwalk()`
 * `modify()`, `modify_if()`, `modify_at()`
 * `map_if()`, `map_at()`
 * `invoke_map()`, `invoke_map_chr()`, `invoke_map_dbl()`, `invoke_map_int()`, `invoke_map_lgl()`, `invoke_map_raw()`, `invoke_map_dfr()`, `invoke_map_dfc()`


[purrr]: https://cran.r-project.org/package=purrr
