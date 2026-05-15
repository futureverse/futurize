<!--
%\VignetteIndexEntry{Parallelize 'parameters' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{parameters}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/parameters-logo.webp" alt="The 'parameters' hexlogo">
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
library(parameters)

model <- lm(mpg ~ wt, data = mtcars)
fit <- bootstrap_model(model, iterations = 1000) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize **[parameters]**
functions, such as `bootstrap_model()` and `bootstrap_parameters()`.

The **[parameters]** package (part of the **easystats** ecosystem)
provides utilities for processing and summarizing statistical models.
The `bootstrap_model()` function generates a distribution of model
estimates by refitting the model multiple times using bootstrapped
samples. This process can be computationally demanding, especially for
complex models or a large number of iterations. Since each bootstrap
iteration is independent, it is a perfect candidate for
parallelization.


## Example: Bootstrapping a linear model

Consider a linear model where we want to obtain bootstrapped
estimates of the coefficients:

```r
library(parameters)

model <- lm(mpg ~ wt + cyl, data = mtcars)

## Generate 1000 bootstrap replicates (sequentially)
boot_dist <- bootstrap_model(model, iterations = 1000)
```

To parallelize this using **futurize**, simply pipe the call to
`futurize()`:

```r
library(futurize)
library(parameters)

model <- lm(mpg ~ wt + cyl, data = mtcars)

## Generate 1000 bootstrap replicates (in parallel)
boot_dist <- bootstrap_model(model, iterations = 1000) |> futurize()
```

This will distribute the bootstrap iterations across the available
parallel workers, given that we have set up a parallel backend, e.g.

```r
plan(multisession)
```


## Example: Bootstrapped parameters summary

The `bootstrap_parameters()` function is a higher-level wrapper that
calls `bootstrap_model()` and then summarizes the results. It can
also be parallelized in the same way:

```r
library(futurize)
plan(multisession)
library(parameters)

model <- lm(mpg ~ wt + cyl, data = mtcars)
boot_params <- bootstrap_parameters(model, iterations = 1000) |> futurize()
```


# Supported Functions

The following **parameters** functions are supported by `futurize()`:

* `bootstrap_model()` with `seed = TRUE` as the default
* `bootstrap_parameters()` with `seed = TRUE` as the default

# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize `bootstrap_model()` using
the **parallel** package directly, without **futurize**:

```r
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

With **futurize**, the cluster management is handled automatically.
You just control the backend with `plan()`.


[parameters]: https://cran.r-project.org/package=parameters
[other parallel backends]: https://www.futureverse.org/backends.html
