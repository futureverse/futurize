# Parallelize 'terra' functions

![The 'terra' logo](../reference/figures/cran-terra-logo.webp)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.webp)= ![The
'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`terra`](https://rspatial.org/)`)`\
\
`r`` ``<-`` `[`rast`](https://rspatial.github.io/terra/reference/rast.html)`(`[`system.file`](https://rdrr.io/r/base/system.file.html)`(``"ex/elev.tif"``, package ``=`` ``"terra"``)``)`\
`res`` ``<-`` `[`focal`](https://rspatial.github.io/terra/reference/focal.html)`(``r``, w ``=`` ``5``, fun ``=`` ``function``(``v``)`` `[`mean`](https://rspatial.github.io/terra/reference/summarize-generics.html)`(``v``, na.rm ``=`` ``TRUE``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[terra](https://cran.r-project.org/package=terra)** functions such as
[`focal()`](https://rspatial.github.io/terra/reference/focal.html),
[`tile_apply()`](https://rspatial.github.io/terra/reference/tile_apply.html),
[`app()`](https://rspatial.github.io/terra/reference/app.html),
[`lapp()`](https://rspatial.github.io/terra/reference/lapp.html), and
[`predict()`](https://rspatial.github.io/terra/reference/predict.html).

The **[terra](https://cran.r-project.org/package=terra)** package
provides classes and methods for spatial data analysis with raster and
vector data. Operations that apply a function to each cell, window, or
tile of a large raster can be computationally intensive, making them
candidates for parallelization.

Several of **terra**’s functions have support for parallelization, which
allows **futurize** to support them:
[`app()`](https://rspatial.github.io/terra/reference/app.html),
[`lapp()`](https://rspatial.github.io/terra/reference/lapp.html),
[`focal()`](https://rspatial.github.io/terra/reference/focal.html),
[`predict()`](https://rspatial.github.io/terra/reference/predict.html)
and
[`tile_apply()`](https://rspatial.github.io/terra/reference/tile_apply.html).

### Example: Parallelizing a moving-window calculation

The [`focal()`](https://rspatial.github.io/terra/reference/focal.html)
function calculates for each cell a value that is a function of the
values of the cells around it (a “moving window” calculation). By
default, a non-built-in `fun` runs sequentially. By piping the result to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md),
we can easily enable parallel processing.

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`terra`](https://rspatial.org/)`)`\
\
`r`` ``<-`` `[`rast`](https://rspatial.github.io/terra/reference/rast.html)`(`[`system.file`](https://rdrr.io/r/base/system.file.html)`(``"ex/elev.tif"``, package ``=`` ``"terra"``)``)`\
\
`## Calculate the per-window mean, ignoring missing values`\
`res`` ``<-`` `[`focal`](https://rspatial.github.io/terra/reference/focal.html)`(``r``, w ``=`` ``5``, fun ``=`` ``function``(``v``)`` `[`mean`](https://rspatial.github.io/terra/reference/summarize-generics.html)`(``v``, na.rm ``=`` ``TRUE``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

When you pipe a
[`focal()`](https://rspatial.github.io/terra/reference/focal.html) or
[`tile_apply()`](https://rspatial.github.io/terra/reference/tile_apply.html)
call to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md),
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

Note that **terra** recognizes a small set of built-in functions, such
as
[`mean()`](https://rspatial.github.io/terra/reference/summarize-generics.html),
[`median()`](https://rspatial.github.io/terra/reference/summarize-generics.html),
and [`sum()`](https://rdrr.io/r/base/sum.html). For those special
functions, it always runs them via its own C++ code, ignoring
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md).
To override this behavior for these special cases, use something like
`fun = function(v) mean(v, na.rm = TRUE)`.

### Example: Parallelizing a tiled raster operation

The
[`tile_apply()`](https://rspatial.github.io/terra/reference/tile_apply.html)
function splits a raster into tiles, applies a function to each tile,
and assembles the results back into a single raster. This too can be
parallelized via
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`terra`](https://rspatial.org/)`)`\
\
`r`` ``<-`` `[`rast`](https://rspatial.github.io/terra/reference/rast.html)`(`[`system.file`](https://rdrr.io/r/base/system.file.html)`(``"ex/elev.tif"``, package ``=`` ``"terra"``)``)`\
\
`res`` ``<-`` `[`tile_apply`](https://rspatial.github.io/terra/reference/tile_apply.html)`(``r``, ``function``(``x``)`` ``x`` ``*`` ``2``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

### Example: Applying a function cell-by-cell or predicting from a model

The [`app()`](https://rspatial.github.io/terra/reference/app.html) and
[`lapp()`](https://rspatial.github.io/terra/reference/lapp.html)
functions apply a custom function to the layers of each cell of a
raster, and
[`predict()`](https://rspatial.github.io/terra/reference/predict.html)
produces a raster of predictions from a fitted model
(e.g. [`lm()`](https://rdrr.io/r/stats/lm.html),
[`glm()`](https://rdrr.io/r/stats/glm.html), or `randomForest()`). We
can parallelize these as:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`terra`](https://rspatial.org/)`)`\
\
`r`` ``<-`` `[`rast`](https://rspatial.github.io/terra/reference/rast.html)`(`[`system.file`](https://rdrr.io/r/base/system.file.html)`(``"ex/elev.tif"``, package ``=`` ``"terra"``)``)`\
\
`res`` ``<-`` `[`app`](https://rspatial.github.io/terra/reference/app.html)`(``r``, fun ``=`` ``function``(``v``)`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``v``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Supported Functions

The following **terra** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md),
with `seed = TRUE` as the default:

- [`app()`](https://rspatial.github.io/terra/reference/app.html)
- [`focal()`](https://rspatial.github.io/terra/reference/focal.html)
- [`lapp()`](https://rspatial.github.io/terra/reference/lapp.html)
- [`predict()`](https://rspatial.github.io/terra/reference/predict.html)
- [`tile_apply()`](https://rspatial.github.io/terra/reference/tile_apply.html)
