<!--
%\VignetteIndexEntry{Parallelize 'pvclust' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{pvclust}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/futurize-logo.webp" alt="The 'futurize' hexlogo">
<span>+</span>
<img src="../man/figures/future-logo.webp" alt="The 'future' logo">
</div>

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!


# TL;DR

```r
library(futurize)
plan(multisession)
library(pvclust)

data(mtcars, package = "datasets")
fit <- pvclust(mtcars, nboot = 1000) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize **[pvclust]**
functions, specifically `pvclust()`.

The **[pvclust]** package provides hierarchical clustering with
p-values (AU: Approximately Unbiased p-value, BP: Bootstrap
Probability) calculated via multiscale bootstrap resampling. This
method is computationally intensive because it requires repeating the
clustering process for many bootstrap replicates at different scales.
These calculations are naturally independent and thus excellent
candidates for parallelization.


## Example: Hierarchical clustering with p-values

The core function `pvclust()` performs multiscale bootstrap resampling
to assess the uncertainty in hierarchical cluster analysis. For
example, using the `mtcars` dataset:

```r
library(pvclust)

## Assess the uncertainty of hierarchical clustering of mtcars
## variables using 1000 bootstrap replicates
fit <- pvclust(mtcars, nboot = 1000)
```

Here `pvclust()` evaluates sequentially. We can easily make it
evaluate in parallel by piping to `futurize()`:

```r
library(futurize)
library(pvclust)

fit <- pvclust(mtcars, nboot = 1000) |> futurize()
```

This will distribute the bootstrap replications across the available
parallel workers, given that we have set up parallel workers, e.g.

```r
plan(multisession)
```

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


# Supported Functions

The following **pvclust** function is supported by `futurize()`:

* `pvclust()` with `seed = TRUE` as the default


# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize `pvclust()` using
the **parallel** package directly, without **futurize**:

```r
library(pvclust)
library(parallel)

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)

## Run pvclust in parallel
fit <- pvclust(mtcars, nboot = 1000, parallel = cl)

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


[pvclust]: https://cran.r-project.org/package=pvclust
[other parallel backends]: https://www.futureverse.org/backends.html
