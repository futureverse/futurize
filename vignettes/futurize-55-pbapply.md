<!--
%\VignetteIndexEntry{Parallelize 'pbapply' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{pbapply}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-pbapply-logo.svg" alt="The 'pbapply' image">
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
library(futurize)
plan(multisession)
library(pbapply)

slow_fcn <- function(x) {
  message("x = ", x)
  Sys.sleep(0.1)  # emulate work
  sqrt(x)
}

xs <- 1:100
ys <- pblapply(xs, slow_fcn) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
**[pbapply]** functions such as `pblapply()`, `pbsapply()`, and
`pbvapply()`.

The **[pbapply]** package provides progress-bar versions of the
base-R `*apply()` family of functions. It supports parallel
processing via the `cl` argument, which accepts a PSOCK cluster
object or, when used with **futurize**, the string `"future"`.


## Example: Parallel lapply with progress bar

The `pblapply()` function works like `lapply()` but displays a
progress bar. For example:

```r
library(pbapply)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  sqrt(x)
}

## Apply a function to each element with a progress bar
xs <- 1:100
ys <- pblapply(xs, slow_fcn)
```

Here `pblapply()` evaluates sequentially, but we can easily make it
evaluate in parallel by piping to `futurize()`:

```r
library(pbapply)

library(futurize)
plan(multisession) ## parallelize on local machine

xs <- 1:100
ys <- pblapply(xs, slow_fcn) |> futurize()
```

Comment: The `message("x = ", x)` output is not relayed to the main R
session by design, because if it were, it would clutter up the
progress bar that **pbapply** renders, which is the whole purpose of
using **pbapply** in the first place.

The built-in `multisession` backend parallelizes on your local
computer and works on all operating systems. There are [other
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


## Example: Parallel sapply with progress bar

The `pbsapply()` function simplifies the result like `sapply()`:

```r
library(futurize)
plan(multisession)
library(pbapply)

xs <- 1:100
ys <- pbsapply(xs, slow_fcn) |> futurize()
```


# Supported Functions

The following **pbapply** functions are supported by `futurize()`:

* `pbapply()`
* `pbby()`
* `pbeapply()`
* `pblapply()`
* `pbreplicate()`
* `pbsapply()`
* `pbtapply()`
* `pbvapply()`
* `pbwalk()`


# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize `pblapply()`
using the **parallel** package directly, without **futurize**:

```r
library(pbapply)
library(parallel)

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)

## Run pblapply in parallel
xs <- 1:100
ys <- pblapply(xs, slow_fcn, cl = cl)

## Tear down the cluster
stopCluster(cl)
```

This requires you to manually create and manage the cluster
lifecycle. If you forget to call `stopCluster()`, or if your code
errors out before reaching it, you leak background R processes. You
also have to decide upfront how many CPUs to use and what cluster
type to use. Switching to another parallel backend, e.g. a Slurm
cluster, would require a completely different setup. With
**futurize**, all of this is handled for you - just pipe to
`futurize()` and control the backend with `plan()`.


# Progress Reporting via progressr

An alternative to using **pbapply** for progress reporting is to use
the **[progressr]** package, which is specially designed to work with
the Futureverse ecosystem and provide progress updates from
parallelized computations in a near-live fashion. See the
`vignette("futurize-11-apply", package = "futurize")` for more
details.


[pbapply]: https://cran.r-project.org/package=pbapply
[progressr]: https://cran.r-project.org/package=progressr
[other parallel backends]: https://www.futureverse.org/backends.html
