<!--
%\VignetteIndexEntry{Parallelize 'BiocParallel' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{BiocParallel}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/bioconductor-BiocParallel-logo.webp" alt="The Bioconductor 'BiocParallel' image">
<span>+</span>
<img src="../man/figures/futurize-logo.webp" alt="The 'futurize' hexlogo">
<span>=</span>
<img src="../man/figures/future-logo.webp" alt="The 'future' logo">
</div>

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!


# TL;DR

You can use **futurize** to make **[BiocParallel]** functions
parallelize via any of the [parallel backends] supported by
Futureverse, e.g.

```r
library(futurize)
plan(multisession)
library(BiocParallel)

slow_fcn <- function(x) {
  message("x = ", x)
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:10
ys <- bplapply(xs, slow_fcn) |> futurize()
```

# Introduction

This vignette demonstrates how to use this approach to parallelize
functions such as `bplapply()`, `bpmapply()`, and `bpvec()` in the
**BiocParallel** package. For example, consider the `bplapply()`
function. It works like base-R `lapply()`, but uses the
**BiocParallel** framework to process the tasks concurrently. It is
commonly used something like:

```r
library(BiocParallel)
xs <- 1:1000
ys <- bplapply(xs, slow_fcn)
```

The parallel backend is controlled by the `BiocParallel::register()`,
similar to how we use `future::plan()` in Futureverse. We can use
the **futurize** package to tell **BiocParallel** to hand over the
orchestration of parallel tasks to Futureverse. All we need to do is
to pass the expression to `futurize()` as in:

```r
library(BiocParallel)

library(futurize)
plan(multisession) ## parallelize on local machine

xs <- 1:1000
ys <- bplapply(xs, slow_fcn) |> futurize()
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


# Supported Functions

The `futurize()` function supports parallelization of all
**BiocParallel** functions that take argument
`BPPARAM`. Specifically,

 * `bplapply()` and `.bplapply_impl()`
 * `bpmapply()` and `.bpmapply_impl()`
 * `bpvec()`
 * `bpaggregate()`

The following functions are currently not supported:

 * `bpiterate()` - technically supported, but because this
   function does not support using `DoparParam()` with it, it
   effectively does not work with `futurize()`
 * `bpvectorize()`
 * `register()`


# Bioconductor packages using BiocParallel

Most Bioconductor packages that support parallelization do so via
**BiocParallel** internally. These packages typically expose a
`BPPARAM` argument in their functions, which controls the parallel
backend used. For example, `DESeq2::DESeq()` has a `BPPARAM` argument
that defaults to `BiocParallel::bpparam()`, which corresponds to the
currently registered **BiocParallel** backend. This means that, in
order to parallelize such a function, one can call
`BiocParallel::register()` to set a parallel backend, and then the
function will use it automatically.

However, not all packages default to `bpparam()`. For example,
`sva::ComBat()` defaults to `bpparam("SerialParam")`, which means it
always runs sequentially unless you explicitly pass a parallel
`BPPARAM` argument. Because of this, one cannot count on `bpparam()`
being the default everywhere - some functions require an explicit
`BPPARAM` to parallelize. With **futurize**, this is handled
automatically: `futurize()` injects the appropriate `BPPARAM` argument
regardless of what the default is, so that the parallel execution is
performed via the Futureverse, where the parallel backend is
controlled by `future::plan()`.


# Progress Reporting via progressr

For progress reporting, please see the **[progressr]** package. It is
specially designed to work with the Futureverse ecosystem and provide
progress updates from parallelized computations in a near-live
fashion. See the `vignette("futurize-11-apply", package = "futurize")`
for more details and an example.


[progressr]: https://progressr.futureverse.org/
[BiocParallel]: https://bioconductor.org/packages/BiocParallel/
[other parallel backends]: https://www.futureverse.org/backends.html
