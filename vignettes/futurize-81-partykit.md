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
<img src="../man/figures/cran-partykit-logo.svg" alt="The 'partykit' image">
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
library(partykit)

cf <- partykit::cforest(dist ~ speed, data = cars) |> futurize()
```


# Introduction

The **[partykit]** package provides a toolkit for recursive
partitioning.


## Example: Conditional random forests inference

Example adopted from `help("cforest", package = "partykit")`:

```r
library(futurize)
plan(multisession)
library(partykit)

## basic example: conditional inference forest for cars data
cf <- cforest(dist ~ speed, data = cars) |> futurize()

## prediction of fitted mean and visualization
nd <- data.frame(speed = 4:25)
nd$mean  <- predict(cf, newdata = nd, type = "response")
plot(dist ~ speed, data = cars)
lines(mean ~ speed, data = nd)
```

This will parallelize the computations of the variable selection
criterion, given that we have set up parallel workers, e.g.

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

The following **partykit** functions are supported by `futurize()`:

* `cforest()`
* `ctree_control()`
* `mob_control()`
* `varimp()` for `cforest`


# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize `cforest()`
using the **parallel** package directly, without **futurize**:

```r
library(partykit)
library(parallel)

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)

## Fit a conditional inference forest in parallel
cf <- cforest(dist ~ speed, data = cars,
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
