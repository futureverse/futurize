# Parallelize 'rugarch' functions

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
library(rugarch)

data(sp500ret, package = "rugarch")
spec <- ugarchspec()
roll <- ugarchroll(spec, sp500ret, n.start = 1000, refit.window = "moving", refit.every = 100) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[rugarch](https://cran.r-project.org/package=rugarch)** functions such
as
[`ugarchroll()`](https://rdrr.io/pkg/rugarch/man/ugarchroll-methods.html),
[`ugarchdistribution()`](https://rdrr.io/pkg/rugarch/man/ugarchdistribution-methods.html),
and
[`ugarchboot()`](https://rdrr.io/pkg/rugarch/man/ugarchboot-methods.html).

The **[rugarch](https://cran.r-project.org/package=rugarch)** package
provides a comprehensive set of methods for Generalized Autoregressive
Conditional Heteroskedasticity (GARCH) modeling. Many of its functions,
especially those involving rolling estimation or bootstrapping, are
computationally intensive and benefit greatly from parallelization.

### Example: Rolling GARCH estimation

The
[`ugarchroll()`](https://rdrr.io/pkg/rugarch/man/ugarchroll-methods.html)
function performs rolling estimation and forecasting. This can be
time-consuming as it involves multiple fits of the GARCH model.

``` r

library(futurize)
plan(multisession)
library(rugarch)

data(sp500ret, package = "rugarch")
spec <- ugarchspec()

## Perform rolling estimation
roll <- ugarchroll(spec, sp500ret, n.start = 1000, 
                   refit.window = "moving", refit.every = 100) |> futurize()
```

### Example: GARCH parameter distribution

The
[`ugarchdistribution()`](https://rdrr.io/pkg/rugarch/man/ugarchdistribution-methods.html)
function simulates and estimates the parameter distribution of a GARCH
model.

``` r

library(futurize)
plan(multisession)
library(rugarch)

data(sp500ret, package = "rugarch")
spec <- ugarchspec()
fit <- ugarchfit(spec, sp500ret)

## Estimate parameter distribution
dist <- ugarchdistribution(fit, n.sim = 100, n.hist = 10) |> futurize()
```

## Supported Functions

The following **rugarch** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`arfimacv()`](https://rdrr.io/pkg/rugarch/man/arfimacv.html) with
  `seed = TRUE` as the default
- [`arfimadistribution()`](https://rdrr.io/pkg/rugarch/man/arfimadistribution-methods.html)
  with `seed = TRUE` as the default
- [`arfimaroll()`](https://rdrr.io/pkg/rugarch/man/arfimaroll-methods.html)
  with `seed = TRUE` as the default
- [`autoarfima()`](https://rdrr.io/pkg/rugarch/man/autoarfima.html) with
  `seed = TRUE` as the default
- [`multifilter()`](https://rdrr.io/pkg/rugarch/man/multifilter-methods.html)
  with `seed = TRUE` as the default
- [`multifit()`](https://rdrr.io/pkg/rugarch/man/multifit-methods.html)
  with `seed = TRUE` as the default
- [`multiforecast()`](https://rdrr.io/pkg/rugarch/man/multiforecast-methods.html)
  with `seed = TRUE` as the default
- [`ugarchboot()`](https://rdrr.io/pkg/rugarch/man/ugarchboot-methods.html)
  with `seed = TRUE` as the default
- [`ugarchdistribution()`](https://rdrr.io/pkg/rugarch/man/ugarchdistribution-methods.html)
  with `seed = TRUE` as the default
- [`ugarchroll()`](https://rdrr.io/pkg/rugarch/man/ugarchroll-methods.html)
  with `seed = TRUE` as the default

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`ugarchroll()`](https://rdrr.io/pkg/rugarch/man/ugarchroll-methods.html)
using the **parallel** package directly, without **futurize**:

``` r

library(rugarch)
library(parallel)

data(sp500ret, package = "rugarch")
spec <- ugarchspec()

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)

## Run rolling estimation in parallel
roll <- ugarchroll(spec, sp500ret, n.start = 1000, 
                   refit.window = "moving", refit.every = 100,
                   cluster = cl)

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
