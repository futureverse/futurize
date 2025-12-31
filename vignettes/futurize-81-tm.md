<!--
%\VignetteIndexEntry{Parallelize 'tm' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{tm}
%\VignetteKeyword{vignette}
%\VignetteKeyword{handlers}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-tm-logo.svg" alt="The 'tm' image">
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
library(tm)
library(futurize)
plan(multisession)

data("crude")
m <- tm_map(crude, content_transformer(tolower)) |> futurize()
```


# Introduction

This vignette demonstrates how use this approach to parallelize **[tm]**
functions such as `tm_map()`.


# Background

The **tm** `tm_map()` function is commonly used to apply a function to
the elements of a list and return a list. For example, 

```r
library(tm)

data("crude")
m <- tm_map(crude, content_transformer(tolower))
```

Here `tm()` evaluates sequentially, but we can easily make it to
evaluate parallelly, by using:

```r
library(tm)
library(futurize)
plan(multisession)

data("crude")
m <- tm_map(crude, content_transformer(tolower)) |> futurize()
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
R functions. The following **tm** functions are supported:

* `tm_map()`
* `tm_index()`
* `TermDocumentMatrix()`


[tm]: https://cran.r-project.org/package=tm
