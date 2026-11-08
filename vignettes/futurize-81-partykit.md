<!--
%\VignetteIndexEntry{Parallelize 'partykit' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{partykit}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-partykit-logo.webp" alt="The 'partykit' image">
<span>+</span>
<img src="../man/figures/futurize-logo.webp" alt="The 'futurize' hexlogo">
<span>=</span>
<img src="../man/figures/future-logo.webp" alt="The 'future' logo">
</div>

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!


# TL;DR

```r
library(futurize)
plan(multisession)
library(partykit)

airq <- na.omit(airquality)
cf <- cforest(Ozone ~ ., data = airq)
vi <- varimp(cf, conditional = TRUE) |> futurize()
```


# Introduction

The **[partykit]** package provides a toolkit for recursive
partitioning.


## Example: Conditional variable importance

Conditional variable importance is one of the most computationally
expensive steps when working with conditional random forests. It is
estimated one tree at a time, which makes it well suited for parallel
processing. Example adopted from `help("varimp", package = "partykit")`:

```r
library(futurize)
plan(multisession)
library(partykit)

## conditional inference forest for the complete cases of 'airquality'
airq <- na.omit(airquality)
set.seed(42)
cf <- cforest(Ozone ~ ., data = airq, ntree = 500L)

## conditional variable importance, estimated in parallel
vi <- varimp(cf, conditional = TRUE, nperm = 10L) |> futurize()
print(vi)
```

This will parallelize the estimation of the variable importance
across the trees of the forest, given that we have set up parallel
workers, e.g.

```r
plan(multisession)
```

With 500 trees and 10 permutations per tree, this takes roughly 13
seconds sequentially and about half of that on four parallel workers
(single runs on a laptop; the speedup grows with the number of trees
and permutations).

The same pattern applies to growing the forest itself, i.e.
`cforest(...) |> futurize()`, but the variable-importance step
typically dominates the run time.

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

The following **partykit** functions are supported by `futurize()`:

* `cforest()` with `seed = TRUE` as the default
* `ctree_control()` with `seed = TRUE` as the default
* `mob_control()` with `seed = TRUE` as the default
* `varimp()` for `cforest` with `seed = TRUE` as the default


# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize `varimp()`
using the **parallel** package directly, without **futurize**:

```r
library(partykit)
library(parallel)

airq <- na.omit(airquality)
cf <- cforest(Ozone ~ ., data = airq, ntree = 500L)

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)

## Estimate the conditional variable importance in parallel
vi <- varimp(cf, conditional = TRUE, nperm = 10L,
             applyfun = function(X, FUN, ...) parLapply(cl, X, FUN, ...))

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


[partykit]: https://cran.r-project.org/package=partykit
[other parallel backends]: https://www.futureverse.org/backends.html
