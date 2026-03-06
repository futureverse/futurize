# Parallelize 'mice' functions

![The 'mice' hexlogo](../reference/figures/mice-logo.png)+ ![The
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
library(mice)

imp <- mice(nhanes, m = 5, printFlag = FALSE) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[mice](https://cran.r-project.org/package=mice)** functions such as
[`mice()`](https://amices.org/mice/reference/mice.html).

The **[mice](https://cran.r-project.org/package=mice)** package
(Multivariate Imputation by Chained Equations) provides a principled
approach to handling missing data. Its
[`mice()`](https://amices.org/mice/reference/mice.html) function creates
multiple imputed datasets by iterating a sequence of univariate
imputation models, one per variable with missing values. Each of the `m`
imputed datasets is generated independently, making the algorithm an
excellent candidate for parallelization.

### Example: Multiple imputation

The [`mice()`](https://amices.org/mice/reference/mice.html) function
generates `m` imputed copies of a dataset. For example, using the
built-in `nhanes` dataset, which contains missing values in three of its
four variables:

``` r

library(mice)

imp <- mice(nhanes, m = 5, printFlag = FALSE)
```

Here [`mice()`](https://amices.org/mice/reference/mice.html) evaluates
the `m = 5` imputations sequentially, but we can easily make it evaluate
them in parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)
library(mice)

imp <- mice(nhanes, m = 5, printFlag = FALSE) |> futurize()
```

This will distribute the imputations across the available parallel
workers, given that we have set up parallel workers, e.g.

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

The following **mice** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`mice()`](https://amices.org/mice/reference/mice.html)
