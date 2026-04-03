<!--
%\VignetteIndexEntry{Parallelize 'stars' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{stars}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
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
library(stars)

m <- matrix(1:20, nrow = 5, ncol = 4)
s <- st_as_stars(m)
res <- st_apply(s, MARGIN = 1, FUN = mean) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize **[stars]**
functions such as `st_apply()`.

The **[stars]** package provides a framework for "Spatiotemporal Arrays"
(raster and vector data cubes). It is a powerful tool for working with 
large-scale spatial and temporal data. Many operations in **stars**, 
particularly those involving applying functions across dimensions, 
can be computationally intensive and thus benefit significantly from 
parallelization.


## Example: Applying a function across dimensions

The `st_apply()` function applies a function to one or more dimensions 
of a `stars` object. By default, it runs sequentially. By piping the 
result to `futurize()`, we can easily enable parallel processing.

```r
library(futurize)
library(stars)

## Create a small stars object
m <- matrix(1:10000, nrow = 100, ncol = 100)
s <- st_as_stars(m)

## Calculate the mean across the first dimension
res <- st_apply(s, MARGIN = 1, FUN = mean) |> futurize()
```

When you pipe a `st_apply()` call to `futurize()`, it automatically 
configures the internal parallelization mechanism of the **stars** 
package to use the **future** framework. This ensures that the 
computation is distributed across the parallel workers defined by 
your current `plan()`.

For example, to parallelize on your local machine:

```r
plan(multisession)
```

The **futurize** package handles all the details of setting up the 
parallel environment, ensuring that global variables and packages 
are correctly exported to the workers, and that any output or 
conditions (like messages and warnings) are relayed back to your 
main R session.


# Supported Functions

The following **stars** functions are supported by `futurize()`:

* `st_apply()`


[stars]: https://cran.r-project.org/package=stars
