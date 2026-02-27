# Parallelize 'crossmap' functions

![The 'crossmap' image](../reference/figures/crossmap-logo.png)+ ![The
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
library(crossmap)

xs <- list(1:5, 1:5)
ys <- xmap(xs, ~ .y * .x) |> futurize()
```

## Introduction

The **[crossmap](https://cran.r-project.org/package=crossmap)** package
adds to the **\[purrr\]**-set of functions. For example,
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
can apply a function to every combination of elements in a list, e.g.

``` r

library(crossmap)

# Multiply the 15 combinations of values in 1:3 and -2:2
xs <- list(1:3, -2:2)
ys <- xmap(xs, function(x, y) x * y) |> futurize()
```

Here
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
evaluates sequentially over each combination of (.y, .x) elements. The
**crossmap** package provides its own future-counterpart functions,
e.g. there is a
[`future_xmap()`](https://pkg.rossellhayes.com/crossmap/reference/future_xmap.html)
that mimics
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html).
The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
transpiles
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
into
[`future_xmap()`](https://pkg.rossellhayes.com/crossmap/reference/future_xmap.html),
meaning you can do:

``` r

library(futurize)

# Multiply the 15 combinations of values in 1:3 and -2:2
xs <- list(1:3, -2:2)
ys <- xmap(xs, function(x, y) x * y) |> futurize()
```

to process this
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
call concurrently, which allows you to execute it on a set parallel
workers, e.g.

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

## Supported Functions

The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function supports parallelization of the following **crossmap**
functions:

- [`imap_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`map_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`map2_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`pmap_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`xmap_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html)
- [`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
- [`xmap_chr()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_dbl()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_int()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_lgl()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_raw()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
- [`xmap_dfc()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_dfr()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
- [`xmap_mat()`](https://pkg.rossellhayes.com/crossmap/reference/xmap_mat.html),
  [`xmap_arr()`](https://pkg.rossellhayes.com/crossmap/reference/xmap_mat.html)
- [`xwalk()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
