# Parallelize 'modelsummary' functions

![The 'modelsummary'
hexlogo](../reference/figures/modelsummary-logo.webp)+ ![The 'futurize'
hexlogo](../reference/figures/futurize-logo.webp)= ![The 'future'
logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(modelsummary)

fit1 <- lm(mpg ~ cyl, data = mtcars)
fit2 <- lm(mpg ~ cyl + hp, data = mtcars)
models <- list(Model1 = fit1, Model2 = fit2)

modelsummary(models) |> futurize()
```

## Introduction

The **[modelsummary](https://cran.r-project.org/package=modelsummary)**
package creates customizable tables and plots to summarize statistical
models side-by-side. For example,

``` r

library(futurize)
plan(multisession)
library(modelsummary)

## fit multiple linear models
fit1 <- lm(mpg ~ cyl, data = mtcars)
fit2 <- lm(mpg ~ cyl + hp, data = mtcars)
models <- list(Model1 = fit1, Model2 = fit2)

## generate modelsummary table in parallel
tbl <- modelsummary(models, output = "data.frame") |> futurize()
print(tbl)
```

will parallelize model summary statistics extraction, given that we have
set up parallel workers, e.g.

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

The following **modelsummary** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`modelsummary()`](https://modelsummary.com/man/modelsummary.html)
  with `seed = TRUE` as the default
- [`msummary()`](https://modelsummary.com/man/msummary.html) with
  `seed = TRUE` as the default
- [`modelplot()`](https://modelsummary.com/man/modelplot.html) with
  `seed = TRUE` as the default
