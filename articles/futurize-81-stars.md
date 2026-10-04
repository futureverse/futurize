# Parallelize 'stars' functions

![The 'futurize' hexlogo](../reference/figures/futurize-logo.webp)=
![The 'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`stars`](https://r-spatial.github.io/stars/)`)`\
\
`m`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(``1``:``20``, nrow ``=`` ``5``, ncol ``=`` ``4``)`\
`s`` ``<-`` `[`st_as_stars`](https://r-spatial.github.io/stars/reference/st_as_stars.html)`(``m``)`\
`res`` ``<-`` `[`st_apply`](https://r-spatial.github.io/stars/reference/st_apply.html)`(``s``, MARGIN ``=`` ``1``, FUN ``=`` ``mean``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

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

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`stars`](https://r-spatial.github.io/stars/)`)`\
\
`## Create a small stars object`\
`m`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(``1``:``10000``, nrow ``=`` ``100``, ncol ``=`` ``100``)`\
`s`` ``<-`` `[`st_as_stars`](https://r-spatial.github.io/stars/reference/st_as_stars.html)`(``m``)`\
\
`## Calculate the mean across the first dimension`\
`res`` ``<-`` `[`st_apply`](https://r-spatial.github.io/stars/reference/st_apply.html)`(``s``, MARGIN ``=`` ``1``, FUN ``=`` ``mean``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

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

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`

The **futurize** package handles all the details of setting up the
parallel environment, ensuring that global variables and packages are
correctly exported to the workers, and that any output or conditions
(like messages and warnings) are relayed back to your main R session.

## Supported Functions

The following **stars** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`st_apply()`](https://r-spatial.github.io/stars/reference/st_apply.html)
