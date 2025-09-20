<!--
%\VignetteIndexEntry{Parallelize 'foreach' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{foreach}
%\VignetteKeyword{vignette}
%\VignetteKeyword{handlers}
%\VignetteEngine{futurize::selfonly}
-->

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!

<div class="logos">
<strong>{foreach}</strong>
<span>+</span>
<img src="../man/figures/futurize-logo.png" alt="The 'futurize' hexlogo">
<span>=</span>
<img src="../man/figures/future-logo.png" alt="The 'future' logo">
</div>


# TL;DR

```r
library(foreach)
library(futurize)
plan(multisession)

xs <- 1:1000
y <- foreach(x = xs) %do% slow_fcn(x) |> futurize()
```


# Introduction

This vignette demonstrates how use this approach to parallelize
functions such as `foreach()` and `times()` of the
**[foreach]** package. For example, consider:

```r
library(foreach)
xs <- 1:1000
y <- foreach(x = xs) %do% slow_fcn(x)
```

This `foreach()` construct is resolved sequentially. We can use
the **futurize** package to tell **foreach** to hand over the
orchestration of parallel tasks to futureverse. All we need to do is
to pass the expression to `futurize()` as in:

```r
library(futurize)
library(foreach)
xs <- 1:1000
y <- foreach(x = xs) %do% slow_fcn(x) |> futurize()
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

Here is another examples that parallelizes `times()` of the
**foreach** package via the futureverse ecosystem:


```r
library(futurize)
library(foreach)
y <- times(10) %do% rnorm(3) |> futurize()
```


# Supported Functions

The `futurize()` function supports parallelization of the following
**foreach** functions:

 * `foreach()` with `%do%`
 * `times()` with `%do%`


[foreach]: https://cran.r-project.org/package=foreach
[other parallel backends]: https://www.futureverse.org/backends.html
