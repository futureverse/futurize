<!--
%\VignetteIndexEntry{Parallelize 'crossmap' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{crossmap}
%\VignetteKeyword{vignette}
%\VignetteKeyword{handlers}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/crossmap-logo.png" alt="The 'crossmap' image">
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
library(crossmap)
library(futurize)
plan(multisession)

xs <- list(1:5, 1:5)
y <- xmap(xs, ~ .y * .x) |> futurize()
```


# Introduction

This vignette demonstrates how use this approach to parallelize
**[crossmap]** functions such as `xmap()` and `xwalk()`.


# Background

The **crossmap** `xmap()` function can be used to iterate over every
combination of elements in an input list. For example,

```r
library(crossmap)
xs <- list(1:5, 1:5)
y <- xmap(xs, ~ .y * .x)
```

Here `xmap()` evaluates sequentially over each combination of (.y, .x)
elements. We can easily make it to evaluate parallelly, by using:

```r
library(futurize)
library(crossmap)
xs <- list(1:5, 1:5)
y <- xmap(xs, ~ .y * .x) |> futurize()
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


# Supported Functions

The `futurize()` function supports parallelization of the common base
R functions. The following **crossmap** functions are supported:

* `imap_vec()`, `map_vec()`, `map2_vec()`, `pmap_vec()`, `xmap_vec()`
* `xmap()`
* `xmap_chr()`, `xmap_dbl()`, `xmap_int()`, `xmap_lgl()`, `xmap_raw()`
* `xmap_dfc()`, `xmap_dfr()`
* `xmap_mat()`, `xmap_arr()`
* `xwalk()`


[crossmap]: https://cran.r-project.org/package=crossmap
