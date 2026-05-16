<!--
%\VignetteIndexEntry{Parallelize 'multtest' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{multtest}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteKeyword{Bioconductor}
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
library(multtest)

data(golub)
res <- MTP(golub[1:50, ], golub.cl, B = 1000) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize **[multtest]**
functions, such as `MTP()` and `EBMTP()`.

The **[multtest]** Bioconductor package provides methods for multiple testing 
procedures based on resampling (bootstrap or permutation). These procedures are 
computationally intensive because they involve thousands of resampling 
iterations to estimate the null distribution of test statistics. Since each 
resampling iteration is independent, they are perfectly suited for 
parallelization.


## Example: Multiple Testing Procedures (MTP)

The `MTP()` function performs resampling-based multiple hypothesis testing. 
For example, using the `golub` dataset:

```r
library(multtest)
data(golub)

## Perform MTP with 1000 bootstrap replicates
res <- MTP(golub[1:50, ], golub.cl, B = 1000)
```

By default, `MTP()` runs sequentially. You can easily make it run in 
parallel by piping to `futurize()`:

```r
library(futurize)
library(multtest)

res <- MTP(golub[1:50, ], golub.cl, B = 1000) |> futurize()
```

This will distribute the bootstrap replications across the available
parallel workers, provided you have configured a parallel backend, e.g.

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local computer. 
You can also use [other parallel backends], such as those providing 
high-performance computing (HPC) support:

```r
plan(future.batchtools::batchtools_slurm)
```


# Supported Functions

The following **multtest** functions are supported by `futurize()`:

* `MTP()` with `seed = TRUE` as the default
* `EBMTP()` with `seed = TRUE` as the default


# Without futurize: Manual snow cluster setup

For comparison, here is how you would parallelize `MTP()` using the
(legacy) **snow** package directly, as traditionally supported by
**multtest**:

```r
library(multtest)
library(snow)

## Set up a cluster
ncpus <- 4L
cl <- makeCluster(ncpus, type = "SOCK")

## Run MTP in parallel
res <- MTP(golub[1:50, ], golub.cl, B = 1000, cluster = cl)

## Tear down the cluster
stopCluster(cl)
```

This requires manual cluster management. If you forget to call `stopCluster()`, 
you leak background R processes. Moreover, changing the parallel backend 
(e.g., to an MPI cluster or a job scheduler) requires significant code changes. 
With **futurize**, you simply use `plan()` to change the backend without 
modifying your analysis code.


# Technical Details: Legacy 'snow' and 'futurize' Patches

The **[multtest]** package was developed before the **parallel** package 
became part of base R. Because of this, it relies on the legacy **snow** 
package for its parallelization. This historical dependency introduces 
several limitations that `futurize()` handles automatically:

1. **Strict Cluster Checks**: `MTP()` and `EBMTP()` explicitly check if 
   the provided `cluster` object inherits from specific **snow** classes 
   (e.g., `SOCKcluster`). A standard cluster created by `parallel::makePSOCKcluster()` 
   will **not** be recognized by **multtest**, even though they are 
   functionally compatible.
2. **Missing Imports**: **multtest** does not officially import **snow**, 
   meaning it expects the user to have the **snow** package attached and 
   available on the search path.
3. **Load Balancing**: The package internally calls `clusterApplyLB()`. 
   Standard `FutureCluster` objects (used by `future::makeClusterFuture()`) 
   do not support load balancing in the same way as legacy **snow** clusters.

When you use `futurize()`, it automatically applies several "bug patches" 
to work around these issues:

*   It temporarily masks `clusterApplyLB()` with a compatible
    `parallel::clusterApply()` implementation.
*   It injects the required **snow** class names into the `FutureCluster` 
    object to satisfy **multtest**'s internal type checks.
*   It ensures the `parallel` package is loaded and available for the 
    duration of the call.

These patches ensure that you can use modern **future** backends with 
**multtest** without having to worry about its legacy internal 
implementation.


[multtest]: https://bioconductor.org/packages/multtest/
[other parallel backends]: https://www.futureverse.org/backends.html
