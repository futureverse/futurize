<!--
%\VignetteIndexEntry{Parallelize 'strucchange' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{strucchange}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-strucchange-logo.svg" alt="The 'strucchange' image">
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
library(strucchange)

data("Nile")
bp.nile <- breakpoints(Nile ~ 1) |> futurize()
```


# Introduction

The **[strucchange]** package provides the `breakpoints()` function
for estimating one or more change points in a data trace,
e.g. in time-series data.


## Example: Finding breakpoints in time-series data

```r
library(futurize)
plan(multisession)
library(strucchange)

## UK Seatbelt data: a SARIMA(1,0,0)(1,0,0)_12 model
## (fitted by OLS) is used and reveals (at least) two
## breakpoints - one in 1973 associated with the oil crisis and
## one in 1983 due to the introduction of compulsory
## wearing of seatbelts in the UK.
data("UKDriverDeaths")

seatbelt <- log10(UKDriverDeaths)
seatbelt <- cbind(seatbelt, lag(seatbelt, k = -1), lag(seatbelt, k = -12))
colnames(seatbelt) <- c("y", "ylag1", "ylag12")
seatbelt <- window(seatbelt, start = c(1970, 1), end = c(1984, 12))
plot(seatbelt[,"y"], ylab = expression(log[10](casualties)))

## testing
re.seat <- efp(y ~ ylag1 + ylag12, data = seatbelt, type = "RE")
plot(re.seat)

## dating
bp.seat <- breakpoints(y ~ ylag1 + ylag12, data = seatbelt, h = 0.1) |> futurize()
lines(bp.seat, breaks = 2)
```

This will parallelize the dynamic programming algorithm for
computing the optimal breakpoints, given that we have set up
parallel workers, e.g.

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

The following **strucchange** functions are supported by `futurize()`:

* `breakpoints()` for 'formula'


# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
`breakpoints()` using the **parallel** and **doParallel** packages
directly, without **futurize**:

```r
library(strucchange)
library(parallel)
library(doParallel)

data("Nile")

## Set up a PSOCK cluster and register it with foreach
ncpus <- 4L
cl <- makeCluster(ncpus)
registerDoParallel(cl)

## Find breakpoints in parallel via foreach
bp.nile <- breakpoints(Nile ~ 1, hpc = "foreach")

## Tear down the cluster
stopCluster(cl)
registerDoSEQ()  ## reset foreach to sequential
```

This requires you to manually create a cluster, register it with
**doParallel**, and remember to tear it down and reset the
**foreach** backend when done. If you forget to call
`stopCluster()`, or if your code errors out before reaching it, you
leak background R processes. You also have to decide upfront how
many CPUs to use and what cluster type to use. Switching to another
parallel backend, e.g. a Slurm cluster, would require a completely
different setup. With **futurize**, all of this is handled for you - just pipe
to `futurize()` and control the backend with `plan()`.


[strucchange]: https://cran.r-project.org/package=strucchange
[other parallel backends]: https://www.futureverse.org/backends.html
