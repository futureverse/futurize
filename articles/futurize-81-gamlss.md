# Parallelize 'gamlss' functions

![The 'gamlss' image](../reference/figures/cran-gamlss-logo.svg)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.png)= ![The
'future' logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(gamlss)

data(abdom, package = "gamlss.data")
cv <- gamlssCV(y ~ pb(x), data = abdom, K.fold = 10) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[gamlss](https://cran.r-project.org/package=gamlss)** functions such
as [`gamlssCV()`](https://rdrr.io/pkg/gamlss/man/gamlssVGD.html),
[`add1All()`](https://rdrr.io/pkg/gamlss/man/stepGAIC.html),
[`drop1All()`](https://rdrr.io/pkg/gamlss/man/stepGAIC.html),
[`add1TGD()`](https://rdrr.io/pkg/gamlss/man/gamlssVGD.html), and
[`drop1TGD()`](https://rdrr.io/pkg/gamlss/man/gamlssVGD.html).

The **[gamlss](https://cran.r-project.org/package=gamlss)** package
implements Generalized Additive Models for Location, Scale, and Shape
(GAMLSS). GAMLSS models extend traditional generalized additive models
(GAMs) by allowing all parameters of a distribution — not just the mean
— to be modeled as functions of explanatory variables. The package
provides tools for model fitting, selection, and diagnostics.

Several gamlss functions support parallel evaluation via the `parallel`,
`ncpus`, and `cl` arguments. By piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md),
you can leverage any future-based parallel backend for these
computations.

### Example: k-fold cross-validation

The [`gamlssCV()`](https://rdrr.io/pkg/gamlss/man/gamlssVGD.html)
function performs k-fold cross-validation for model selection. This is
computationally intensive and benefits greatly from parallelization:

``` r

library(gamlss)

data(abdom, package = "gamlss.data")
cv <- gamlssCV(y ~ pb(x), data = abdom, K.fold = 10)
```

Here [`gamlssCV()`](https://rdrr.io/pkg/gamlss/man/gamlssVGD.html)
evaluates each fold sequentially, but we can easily make it evaluate in
parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)
library(gamlss)

data(abdom, package = "gamlss.data")
cv <- gamlssCV(y ~ pb(x), data = abdom, K.fold = 10) |> futurize()
```

This will distribute the cross-validation folds across the available
parallel workers, given that we have set up parallel workers, e.g.

``` r

plan(multisession)
```

Unlike other parallel backends in R,
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
relays standard output, messages, and warnings produced by the parallel
workers back to your main R session. For instance, when running the
above, you will see the progress output from each optimizer as it
completes:

    > cv <- gamlssCV(y ~ pb(x), data = abdom, K.fold = 10) |> futurize()
    fold 1
    fold 2
    fold 3
    fold 4
    fold 5
    fold 6
    fold 7
    fold 8
    fold 9
    fold 10
    > 

This output originates from the parallel workers and is relayed to your
R session, so you get the same informative feedback as when running
sequentially.

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

### Example: Drop terms from a model

The [`drop1All()`](https://rdrr.io/pkg/gamlss/man/stepGAIC.html)
function evaluates the effect of dropping each term from a fitted GAMLSS
model, which can be parallelized:

``` r

library(futurize)
plan(multisession)
library(gamlss)

data(abdom, package = "gamlss.data")
m <- gamlss(y ~ pb(x) + x, data = abdom)
d <- drop1All(m) |> futurize()
```

## Supported Functions

The following **gamlss** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`add1All()`](https://rdrr.io/pkg/gamlss/man/stepGAIC.html)
- [`add1TGD()`](https://rdrr.io/pkg/gamlss/man/gamlssVGD.html)
- [`drop1All()`](https://rdrr.io/pkg/gamlss/man/stepGAIC.html)
- [`drop1TGD()`](https://rdrr.io/pkg/gamlss/man/gamlssVGD.html)
- [`gamlssCV()`](https://rdrr.io/pkg/gamlss/man/gamlssVGD.html)

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`gamlssCV()`](https://rdrr.io/pkg/gamlss/man/gamlssVGD.html) using the
**parallel** package directly, without **futurize**:

``` r

library(gamlss)
library(parallel)

data(abdom, package = "gamlss.data")

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)
clusterEvalQ(cl, library(gamlss))

## Perform k-fold cross-validation in parallel
cv <- gamlssCV(y ~ pb(x), data = abdom, K.fold = 10,
               parallel = "snow", ncpus = ncpus, cl = cl)

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
