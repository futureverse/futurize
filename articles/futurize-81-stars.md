# Parallelize 'stars' functions

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
library(stars)

m <- matrix(1:20, nrow = 5, ncol = 4)
s <- st_as_stars(m)
res <- st_apply(s, MARGIN = 1, FUN = mean) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[stars](https://cran.r-project.org/package=stars)** functions such as
[`st_apply()`](https://r-spatial.github.io/stars/reference/st_apply.html).

The **[stars](https://cran.r-project.org/package=stars)** package
provides a framework for “Spatiotemporal Arrays” (raster and vector data
cubes). It is a powerful tool for working with large-scale spatial and
temporal data. Many operations in **stars**, particularly those
involving applying functions across dimensions, can be computationally
intensive and thus benefit significantly from parallelization.

### Example: Applying a function across dimensions

The
[`st_apply()`](https://r-spatial.github.io/stars/reference/st_apply.html)
function applies a function to one or more dimensions of a `stars`
object. By default, it runs sequentially. By piping the result to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md),
we can easily enable parallel processing.

``` r

library(futurize)
library(stars)

## Create a small stars object
m <- matrix(1:10000, nrow = 100, ncol = 100)
s <- st_as_stars(m)

## Calculate the mean across the first dimension
res <- st_apply(s, MARGIN = 1, FUN = mean) |> futurize()
```

When you pipe a
[`st_apply()`](https://r-spatial.github.io/stars/reference/st_apply.html)
call to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md),
it automatically configures the internal parallelization mechanism of
the **stars** package to use the **future** framework. This ensures that
the computation is distributed across the parallel workers defined by
your current
[`plan()`](https://future.futureverse.org/reference/plan.html).

For example, to parallelize on your local machine:

``` r

plan(multisession)
```

The **futurize** package handles all the details of setting up the
parallel environment, ensuring that global variables and packages are
correctly exported to the workers, and that any output or conditions
(like messages and warnings) are relayed back to your main R session.

## Supported Functions

The following **stars** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`st_apply()`](https://r-spatial.github.io/stars/reference/st_apply.html)
