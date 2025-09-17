<!--
%\VignetteIndexEntry{Parallelize 'purrr' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteKeyword{handlers}
%\VignetteEngine{futurize::selfonly}
-->

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!


# TL;DR

```r
library(futurize)
plan(multisession)

xs <- 1:1000
y <- lapply(xs, slow_fcn) |> futurize()
```


# Introduction

This vignette demonstrates how use this approach to parallelize
functions such as `lapply()`, `tapply()`, `apply()`, and `replicate()`
in the **base** package, and `kernapply()` in the **stats**
package. For example, consider the base R `lapply()` function, which
is commonly used to apply a function to the elements of a vector or a
list, as in:

```r
xs <- 1:1000
y <- lapply(xs, slow_fcn)
```

Here `lapply()` evaluates sequentially, but we can easily make it to
evaluate parallelly, by using:

```r
library(futurize)
y <- lapply(xs, slow_fcn) |> futurize()
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
R functions. The following  **base** package functions are supported:

 * `lapply()`, `vapply()`, `sapply()`, `tapply()`
 * `mapply()`, `.mapply()`, `Map()`
 * `eapply()`
 * `apply()`
 * `replicate()`
 * `by()`
 * `Filter()`

The `rapply()` function is not supported by `futurize()`.

The following **stats** package function is also supported:

 * `kernapply()`


# Notes

 * Not all functions passed to `apply()` are guaranteed to be safe for
   parallelization. Ensure that the function is side-effect free and
   does not depend on external state.


[other parallel backends]: https://www.futureverse.org/backends.html
