<!--
%\VignetteIndexEntry{Parallelize 'plyr' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{plyr}
%\VignetteKeyword{vignette}
%\VignetteKeyword{handlers}
%\VignetteEngine{futurize::selfonly}
-->

# TL;DR

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!

```r
library(plyr)
library(futurize)
plan(multisession)

xs <- 1:1000
y <- llply(xs, slow_fcn) |> futurize()
```


# Introduction

This vignette demonstrates how use this approach to parallelize **[plyr]**
functions such as `llply()`, `maply()`, and `ddply()`.


# Background

The **plyr** `llply()` function is commonly used to apply a function to
the elements of a list and return a list. For example, 

```r
library(plyr)
xs <- 1:1000
y <- llply(xs, slow_fcn)
```

Here `llply()` evaluates sequentially, but we can easily make it to
evaluate parallelly, by using:

```r
library(futurize)
library(plyr)
xs <- 1:1000
y <- xs |> llply(slow_fcn) |> futurize()
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
library(plyr)
library(futurize)
plan(future.mirai::mirai_multisession)

y <- llply(baseball, summary) |> futurize()
```


# Supported Functions

The `futurize()` function supports parallelization of the common base
R functions. The following **plyr** functions are supported:

* `a_ply()`, `aaply()`, `adply()`, `alply()`,
* `d_ply()`, `daply()`, `ddply()`, `dlply()`
* `l_ply()`, `laply()`, `ldply()`, `llply()`
* `m_ply()`, `maply()`, `mdply()`, `mlply()`


[plyr]: https://cran.r-project.org/package=plyr
