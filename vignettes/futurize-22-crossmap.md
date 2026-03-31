<!--
%\VignetteIndexEntry{Parallelize 'crossmap' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{crossmap}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/crossmap-logo.webp" alt="The 'crossmap' image">
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
library(crossmap)

xs <- list(1:5, 1:5)
ys <- xmap(xs, ~ .y * .x) |> futurize()
```


# Introduction

The **[crossmap]** package adds to the **[purrr]**-set of functions. For example, `xmap()` can apply a function to every combination of elements in a list, e.g.

```r
library(crossmap)

# Multiply the 15 combinations of values in 1:3 and -2:2
xs <- list(1:3, -2:2)
ys <- xmap(xs, function(x, y) x * y) |> futurize()
```

Here `xmap()` evaluates sequentially over each combination of (.y, .x)
elements. The **crossmap** package provides its own future-counterpart functions, e.g. there is a `future_xmap()` that mimics `xmap()`. The `futurize()` function transpiles `xmap()` into `future_xmap()`, meaning you can do:

```r
library(futurize)

# Multiply the 15 combinations of values in 1:3 and -2:2
xs <- list(1:3, -2:2)
ys <- xmap(xs, function(x, y) x * y) |> futurize()
```

to process this `xmap()` call concurrently, which allows you to
execute it on a set of parallel workers, e.g.

```r
plan(multisession)
```

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


# Supported Functions

The `futurize()` function supports parallelization of the following **crossmap** functions:

* `imap_vec()`, `map_vec()`, `map2_vec()`, `pmap_vec()`, `xmap_vec()`
* `xmap()`
* `xmap_chr()`, `xmap_dbl()`, `xmap_int()`, `xmap_lgl()`
* `xmap_dfc()`, `xmap_dfr()`
* `xmap_mat()`, `xmap_arr()`
* `xwalk()`


[crossmap]: https://cran.r-project.org/package=crossmap
[other parallel backends]: https://www.futureverse.org/backends.html
