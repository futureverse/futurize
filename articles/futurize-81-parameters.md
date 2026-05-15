# Parallelize 'parameters' functions

![The 'parameters' hexlogo](../reference/figures/parameters-logo.webp)+
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
library(parameters)

model <- lm(mpg ~ wt, data = mtcars)
fit <- bootstrap_model(model, iterations = 1000) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[parameters](https://cran.r-project.org/package=parameters)**
functions, such as
[`bootstrap_model()`](https://easystats.github.io/parameters/reference/bootstrap_model.html)
and
[`bootstrap_parameters()`](https://easystats.github.io/parameters/reference/bootstrap_parameters.html).

The **[parameters](https://cran.r-project.org/package=parameters)**
package (part of the **easystats** ecosystem) provides utilities for
processing and summarizing statistical models. The
[`bootstrap_model()`](https://easystats.github.io/parameters/reference/bootstrap_model.html)
function generates a distribution of model estimates by refitting the
model multiple times using bootstrapped samples. This process can be
computationally demanding, especially for complex models or a large
number of iterations. Since each bootstrap iteration is independent, it
is a perfect candidate for parallelization.

### Example: Bootstrapping a linear model

Consider a linear model where we want to obtain bootstrapped estimates
of the coefficients:

``` r

library(parameters)

model <- lm(mpg ~ wt + cyl, data = mtcars)

## Generate 1000 bootstrap replicates (sequentially)
boot_dist <- bootstrap_model(model, iterations = 1000)
```

To parallelize this using **futurize**, simply pipe the call to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)
library(parameters)

model <- lm(mpg ~ wt + cyl, data = mtcars)

## Generate 1000 bootstrap replicates (in parallel)
boot_dist <- bootstrap_model(model, iterations = 1000) |> futurize()
```

This will distribute the bootstrap iterations across the available
parallel workers, given that we have set up a parallel backend, e.g.

``` r

plan(multisession)
```

### Example: Bootstrapped parameters summary

The
[`bootstrap_parameters()`](https://easystats.github.io/parameters/reference/bootstrap_parameters.html)
function is a higher-level wrapper that calls
[`bootstrap_model()`](https://easystats.github.io/parameters/reference/bootstrap_model.html)
and then summarizes the results. It can also be parallelized in the same
way:

``` r

library(futurize)
plan(multisession)
library(parameters)

model <- lm(mpg ~ wt + cyl, data = mtcars)
boot_params <- bootstrap_parameters(model, iterations = 1000) |> futurize()
```

## Supported Functions

The following **parameters** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`bootstrap_model()`](https://easystats.github.io/parameters/reference/bootstrap_model.html)
  with `seed = TRUE` as the default
- [`bootstrap_parameters()`](https://easystats.github.io/parameters/reference/bootstrap_parameters.html)
  with `seed = TRUE` as the default
- `parameters_bootstrap()` with `seed = TRUE` as the default

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`bootstrap_model()`](https://easystats.github.io/parameters/reference/bootstrap_model.html)
using the **parallel** package directly, without **futurize**:

``` r

library(parameters)
library(parallel)

model <- lm(mpg ~ wt + cyl, data = mtcars)

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)

## Run bootstrapping in parallel
boot_dist <- bootstrap_model(model, iterations = 1000, 
                             parallel = "snow", n_cpus = ncpus, 
                             cluster = cl)

## Tear down the cluster
stopCluster(cl)
```

With **futurize**, the cluster management is handled automatically. You
just control the backend with
[`plan()`](https://future.futureverse.org/reference/plan.html).
