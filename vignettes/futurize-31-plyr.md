<!--
%\VignetteIndexEntry{Parallelize 'plyr' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{plyr}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-plyr-logo.svg" alt="The 'plyr' image">
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
library(plyr)
library(futurize)
plan(multisession)

slow_fcn <- function(x) {
  message("x = ", x)
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:10
ys <- llply(xs, slow_fcn) |> futurize()
```

# Introduction

This vignette demonstrates how to use this approach to parallelize
**[plyr]** functions such as `llply()`, `maply()`, and `ddply()`.

The **plyr** `llply()` function is commonly used to apply a function
to the elements of a list and return a list. For example,

```r
library(plyr)
xs <- 1:1000
ys <- llply(xs, slow_fcn)
```

Here `llply()` evaluates sequentially, but we can easily make it
evaluate in parallel, by using:

```r
library(plyr)

library(futurize)
plan(multisession) ## parallelize on local machine

xs <- 1:1000
ys <- xs |> llply(slow_fcn) |> futurize()
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
library(plyr)
library(futurize)
plan(future.mirai::mirai_multisession)

ys <- llply(baseball, summary) |> futurize()
```


# Supported Functions

The `futurize()` function supports parallelization of the following
**plyr** functions:

* `a_ply()`, `aaply()`, `adply()`, `alply()`
* `d_ply()`, `daply()`, `ddply()`, `dlply()`
* `l_ply()`, `laply()`, `ldply()`, `llply()`
* `m_ply()`, `maply()`, `mdply()`, `mlply()`


# Progress Reporting via progressr

For progress reporting, please see the **[progressr]** package. It is
specially designed to work with the Futureverse ecosystem and provide
progress updates from parallelized computations in a near-live
fashion. See the `vignette("futurize-11-apply", package = "futurize")`
for more details and an example.


[plyr]: https://cran.r-project.org/package=plyr
[other parallel backends]: https://www.futureverse.org/backends.html
