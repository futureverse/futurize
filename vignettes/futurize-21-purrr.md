<!--
%\VignetteIndexEntry{Parallelize 'purrr' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{purrr}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/purrr-logo.webp" alt="The 'purrr' logo">
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
library(purrr)

slow_fcn <- function(x) {
  message("x = ", x)
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:10
ys <- xs |> map(slow_fcn) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
**[purrr]** functions such as `map()`, `map_dbl()`, and `walk()`.

The **purrr** `map()` function is commonly used to apply a function to
the elements of a vector or a list. For example,

```r
library(purrr)
xs <- 1:1000
ys <- map(xs, slow_fcn)
```

or equivalently using pipe syntax

```r
xs <- 1:1000
ys <- xs |> map(slow_fcn)
```

Here `map()` evaluates sequentially, but we can easily make it
evaluate in parallel, by using:

```r
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

Note how messages produced on parallel workers are relayed as-is back
to the main R session as they complete. Not only messages, but also
warnings and other types of conditions are relayed back as-is.
Likewise, standard output produced by `cat()`, `print()`, `str()`, and
so on is relayed in the same way. This is a unique feature of
Futureverse - other parallel frameworks in R, such as **parallel**,
**foreach** with **doParallel**, and **BiocParallel**, silently drop
standard output, messages, and warnings produced on workers. With
**futurize**, your code behaves the same whether it runs sequentially
or in parallel: nothing is lost in translation.

The built-in `multisession` backend parallelizes on your local
computer and it works on all operating systems. There are [other
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

The `futurize()` function supports parallelization of the following **purrr** functions:

 * `map()`, `map_chr()`, `map_dbl()`, `map_int()`, `map_lgl()`, `map_dfr()`, `map_dfc()`, `walk()`
 * `map2()`, `map2_chr()`, `map2_dbl()`, `map2_int()`, `map2_lgl()`, `map2_dfr()`, `map2_dfc()`, `walk2()`
 * `pmap()`, `pmap_chr()`, `pmap_dbl()`, `pmap_int()`, `pmap_lgl()`, `pmap_dfr()`, `pmap_dfc()`, `pwalk()`
 * `imap()`, `imap_chr()`, `imap_dbl()`, `imap_int()`, `imap_lgl()`, `imap_dfr()`, `imap_dfc()`, `iwalk()`
 * `modify()`, `modify_if()`, `modify_at()`
 * `map_if()`, `map_at()`


# Progress Reporting via progressr

For progress reporting, please see the **[progressr]** package. It is
specially designed to work with the Futureverse ecosystem and provide
progress updates from parallelized computations in a near-live
fashion. See the `vignette("futurize-11-apply", package = "futurize")`
for more details and an example.


[progressr]: https://progressr.futureverse.org/
[purrr]: https://cran.r-project.org/package=purrr
[other parallel backends]: https://www.futureverse.org/backends.html
