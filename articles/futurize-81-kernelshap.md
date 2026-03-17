# Parallelize 'kernelshap' functions

![The 'kernelshap' logo](../reference/figures/kernelshap-logo.png)+
![The 'futurize' hexlogo](../reference/figures/futurize-logo.png)= ![The
'future' logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(kernelshap)

ks <- kernelshap(
  model, X = x_explain, bg_X = bg_X
) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[kernelshap](https://cran.r-project.org/package=kernelshap)**
functions such as
[`kernelshap()`](https://rdrr.io/pkg/kernelshap/man/kernelshap.html) and
[`permshap()`](https://rdrr.io/pkg/kernelshap/man/permshap.html).

The **[kernelshap](https://cran.r-project.org/package=kernelshap)**
package provides efficient implementations of Kernel SHAP and
permutation SHAP for explaining predictions from any machine learning
model. These functions iterate over observations to compute Shapley
value estimates, making the computation an excellent candidate for
parallelization.

### Example: Computing Kernel SHAP values in parallel

The [`kernelshap()`](https://rdrr.io/pkg/kernelshap/man/kernelshap.html)
function computes Kernel SHAP values for a set of observations. For
example, using a simple linear model:

``` r

library(kernelshap)

## Fit a model
x_train <- data.frame(x1 = rnorm(100), x2 = rnorm(100))
y_train <- 2 * x_train$x1 + x_train$x2 + rnorm(100)
model <- lm(y ~ ., data = cbind(y = y_train, x_train))

## Compute Kernel SHAP values
x_explain <- x_train[1:5, ]
bg_X <- x_train[1:20, ]
ks <- kernelshap(model, X = x_explain, bg_X = bg_X)
```

Here
[`kernelshap()`](https://rdrr.io/pkg/kernelshap/man/kernelshap.html)
processes observations sequentially, but we can easily make it process
them in parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)
library(kernelshap)

ks <- kernelshap(
  model, X = x_explain, bg_X = bg_X
) |> futurize()
```

This will distribute the observation-level computations across the
available parallel workers, given that we have set up parallel workers,
e.g.

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

### Example: Computing permutation SHAP values in parallel

The [`permshap()`](https://rdrr.io/pkg/kernelshap/man/permshap.html)
function works the same way:

``` r

library(futurize)
library(kernelshap)

ps <- permshap(
  model, X = x_explain, bg_X = bg_X
) |> futurize()
```

## Supported Functions

The following **kernelshap** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`kernelshap()`](https://rdrr.io/pkg/kernelshap/man/kernelshap.html)
- [`permshap()`](https://rdrr.io/pkg/kernelshap/man/permshap.html)

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`kernelshap()`](https://rdrr.io/pkg/kernelshap/man/kernelshap.html)
using the **parallel** and **doParallel** packages directly, without
**futurize**:

``` r

library(kernelshap)
library(parallel)
library(doParallel)

## Fit a model
x_train <- data.frame(x1 = rnorm(100), x2 = rnorm(100))
y_train <- 2 * x_train$x1 + x_train$x2 + rnorm(100)
model <- lm(y ~ ., data = cbind(y = y_train, x_train))

x_explain <- x_train[1:5, ]
bg_X <- x_train[1:20, ]

## Set up a PSOCK cluster and register it with foreach
ncpus <- 4L
cl <- makeCluster(ncpus)
registerDoParallel(cl)

## Compute Kernel SHAP values in parallel via foreach
ks <- kernelshap(model, X = x_explain, bg_X = bg_X, parallel = TRUE)

## Tear down the cluster
stopCluster(cl)
registerDoSEQ()  ## reset foreach to sequential
```

This requires you to manually create a cluster, register it with
**doParallel**, and remember to tear it down and reset the **foreach**
backend when done. If you forget to call
[`stopCluster()`](https://rdrr.io/r/parallel/makeCluster.html), or if
your code errors out before reaching it, you leak background R
processes. You also have to decide upfront how many CPUs to use and what
cluster type to use. Switching to another parallel backend, e.g. a Slurm
cluster, would require a completely different setup. With **futurize**,
all of this is handled for you - just pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
and control the backend with
[`plan()`](https://future.futureverse.org/reference/plan.html).
