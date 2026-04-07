# Parallelize 'pbapply' functions

![The 'pbapply' image](../reference/figures/cran-pbapply-logo.webp)+
![The 'futurize' hexlogo](../reference/figures/futurize-logo.webp)=
![The 'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

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

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[pbapply](https://cran.r-project.org/package=pbapply)** functions such
as
[`pblapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html),
[`pbsapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html),
and
[`pbvapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html).

The **[pbapply](https://cran.r-project.org/package=pbapply)** package
provides progress-bar versions of the base-R `*apply()` family of
functions. It supports parallel processing via the `cl` argument, which
accepts a PSOCK cluster object or, when used with **futurize**, the
string `"future"`.

### Example: Parallel lapply with progress bar

The
[`pblapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
function works like
[`lapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html) but
displays a progress bar. For example:

``` r

library(pbapply)

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  sqrt(x)
}

## Apply a function to each element with a progress bar
xs <- 1:100
ys <- pblapply(xs, slow_fcn)
```

Here
[`pblapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
evaluates sequentially, but we can easily make it evaluate in parallel
by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(pbapply)

library(futurize)
plan(multisession) ## parallelize on local machine

xs <- 1:100
ys <- pblapply(xs, slow_fcn) |> futurize()
```

Comment: The `message("x = ", x)` output is not relayed to the main R
session by design, because if it were, it would clutter up the progress
bar that **pbapply** renders, which is the whole purpose of using
**pbapply** in the first place.

The built-in `multisession` backend parallelizes on your local computer
and works on all operating systems. There are [other parallel
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

### Example: Parallel sapply with progress bar

The
[`pbsapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
function simplifies the result like
[`sapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html):

``` r

library(futurize)
plan(multisession)
library(pbapply)

xs <- 1:100
ys <- pbsapply(xs, slow_fcn) |> futurize()
```

## Supported Functions

The following **pbapply** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`pbapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
- [`pbby()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
- [`pbeapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
- [`pblapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
- [`pbreplicate()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
- [`pbsapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
- [`pbtapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
- [`pbvapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
- [`pbwalk()`](https://peter.solymos.org/pbapply/reference/pbapply.html)

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`pblapply()`](https://peter.solymos.org/pbapply/reference/pbapply.html)
using the **parallel** package directly, without **futurize**:

``` r

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

This requires you to manually create and manage the cluster lifecycle.
If you forget to call
[`stopCluster()`](https://rdrr.io/r/parallel/makeCluster.html), or if
your code errors out before reaching it, you leak background R
processes. You also have to decide upfront how many CPUs to use and what
cluster type to use. Switching to another parallel backend, e.g. a Slurm
cluster, would require a completely different setup. With **futurize**,
all of this is handled for you - just pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
and control the backend with
[`plan()`](https://future.futureverse.org/reference/plan.html).

## Progress Reporting via progressr

An alternative to using **pbapply** for progress reporting is to use the
**[progressr](https://progressr.futureverse.org/)** package, which is
specially designed to work with the Futureverse ecosystem and provide
progress updates from parallelized computations in a near-live fashion.
See the
[`vignette("futurize-11-apply", package = "futurize")`](https://futurize.futureverse.org/articles/futurize-11-apply.md)
for more details.
