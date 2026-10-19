<!--
%\VignetteIndexEntry{Parallelize 'terra' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{terra}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-terra-logo.webp" alt="The 'terra' logo">
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
library(terra)

r <- rast(system.file("ex/elev.tif", package = "terra"))
res <- focal(r, w = 5, fun = function(v) mean(v, na.rm = TRUE)) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
**[terra]** functions such as `focal()`, `tile_apply()`, `app()`,
`lapp()`, and `predict()`.

The **[terra]** package provides classes and methods for spatial data
analysis with raster and vector data. Operations that apply a function
to each cell, window, or tile of a large raster can be computationally
intensive, making  them candidates for parallelization.

Several of **terra**'s functions have support for parallelization,
which allows **futurize** to support them: `app()`, `lapp()`,
`focal()`, `predict()` and `tile_apply()`.


## Example: Parallelizing a moving-window calculation

The `focal()` function calculates for each cell a value that is a
function of the values of the cells around it (a "moving window"
calculation). By default, a non-built-in `fun` runs sequentially. By
piping the result to `futurize()`, we can easily enable parallel
processing.

```r
library(futurize)
library(terra)

r <- rast(system.file("ex/elev.tif", package = "terra"))

## Calculate the per-window mean, ignoring missing values
res <- focal(r, w = 5, fun = function(v) mean(v, na.rm = TRUE)) |> futurize()
```

When you pipe a `focal()` or `tile_apply()` call to `futurize()`, the
computation is distributed across the parallel workers defined by your
current `plan()`.

For example, to parallelize on your local machine:

```r
plan(multisession)
```

The **futurize** package handles all the details of setting up the
parallel environment, ensuring that global variables and packages
are correctly exported to the workers, and that any output or
conditions (like messages and warnings) are relayed back to your
main R session.

Note that **terra** recognizes a small set of built-in functions, such
as `mean()`, `median()`, and `sum()`. For those special functions, it
always runs them via its own C++ code, ignoring `futurize()`. To
override this behavior for these special cases, use something like
`fun = function(v) mean(v, na.rm = TRUE)`.


## Example: Parallelizing a tiled raster operation

The `tile_apply()` function splits a raster into tiles, applies a
function to each tile, and assembles the results back into a single
raster. This too can be parallelized via `futurize()`:

```r
library(futurize)
library(terra)

r <- rast(system.file("ex/elev.tif", package = "terra"))

res <- tile_apply(r, function(x) x * 2) |> futurize()
```


## Example: Applying a function cell-by-cell or predicting from a model

The `app()` and `lapp()` functions apply a custom function to the
layers of each cell of a raster, and `predict()` produces a raster of
predictions from a fitted model (e.g. `lm()`, `glm()`, or
`randomForest()`). We can parallelize these as:

```r
library(futurize)
library(terra)

r <- rast(system.file("ex/elev.tif", package = "terra"))

res <- app(r, fun = function(v) sum(v)) |> futurize()
```


# Supported Functions

The following **terra** functions are supported by `futurize()`, with
`seed = TRUE` as the default:

* `app()`
* `focal()`
* `lapp()`
* `predict()`
* `tile_apply()`


[terra]: https://cran.r-project.org/package=terra
