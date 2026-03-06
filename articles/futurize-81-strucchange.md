# Parallelize 'strucchange' functions

![The 'strucchange'
image](../reference/figures/cran-strucchange-logo.svg)+ ![The 'futurize'
hexlogo](../reference/figures/futurize-logo.png)= ![The 'future'
logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(strucchange)

data("Nile")
bp.nile <- breakpoints(Nile ~ 1) |> futurize()
```

## Introduction

The **[strucchange](https://cran.r-project.org/package=strucchange)**
package provides the
[`breakpoints()`](https://rdrr.io/pkg/strucchange/man/breakpoints.html)
function for estimating one or more change points in a data trace,
e.g. in time-series data.

### Example: Finding breakpoints in time-series data

``` r

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

This will parallelize the dynamic programming algorithm used by
algorithm for computing the optimal breakpoints, given that we have set
up parallel workers, e.g.

``` r

plan(multisession)
```

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

## Supported Functions

The following **strucchange** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`breakpoints()`](https://rdrr.io/pkg/strucchange/man/breakpoints.html)
  for ‘formula’
