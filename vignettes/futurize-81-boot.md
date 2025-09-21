<!--
%\VignetteIndexEntry{Parallelize 'boot' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{boot}
%\VignetteKeyword{vignette}
%\VignetteKeyword{handlers}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-boot-logo.svg" alt="The 'boot' image">
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
library(boot)
library(futurize)
plan(multisession)

ratio <- function(d, w) sum(d$x * w)/sum(d$u * w)
b <- boot(city, ratio, R = 999, stype = "w") |> futurize()
```


# Introduction

This vignette demonstrates how use this approach to parallelize **[boot]**
functions such as `boot()` and `tsboot()`.


# Background

The **boot** `llply()` function is commonly used to apply a function to
the elements of a list and return a list. For example, 

```r
library(boot)

ratio <- function(d, w) sum(d$x * w)/sum(d$u * w)
b <- boot(city, ratio, R = 999, stype = "w")
```

Here `boot()` evaluates sequentially, but we can easily make it to
evaluate parallelly, by using:

```r
library(futurize)
library(boot)

ratio <- function(d, w) sum(d$x * w)/sum(d$u * w)
b <- boot(city, ratio, R = 999, stype = "w") |> futurize()
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
library(boot)
library(futurize)
plan(future.mirai::mirai_multisession)

lynx.fun <- function(tsb) {
     ar.fit <- ar(tsb, order.max = 25)
     c(ar.fit$order, mean(tsb), tsb)
}

lynx.1 <- tsboot(log(lynx), lynx.fun, R = 99, l = 20, sim = "geom") |> futurize()
```


# Supported Functions

The `futurize()` function supports parallelization of the common base
R functions. The following **boot** functions are supported:

* `boot()`
* `censboot()`
* `tsboot()`


[boot]: https://cran.r-project.org/package=boot
