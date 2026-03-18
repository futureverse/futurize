<!--
%\VignetteIndexEntry{Parallelize 'tm' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{tm}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-tm-logo.webp" alt="The 'tm' image">
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
library(tm)

data("crude")
m <- tm_map(crude, content_transformer(tolower)) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize **[tm]**
functions such as `tm_map()`.

The **[tm]** package provides a variety of text-mining methods. The
`tm_map()` function applies transformations to a corpus of text
documents, and `TermDocumentMatrix()` constructs document-term matrices.
When working with large corpora, these operations benefit greatly from
parallelization.


## Example: Transforming a text corpus

The `tm_map()` function applies a transformation to each document in
a corpus:

```r
library(tm)

## Load the crude oil news corpus holding 20 documents
data("crude")

## Convert all text to lowercase
m <- tm_map(crude, content_transformer(tolower))
```

Here `tm_map()` evaluates sequentially, but we can easily make it
evaluate in parallel by piping to `futurize()`:

```r
library(tm)
library(futurize)
plan(multisession)

data("crude")
m <- tm_map(crude, content_transformer(tolower)) |> futurize()
```

This will distribute the document transformations across the available
parallel workers, given that we have set up parallel workers, e.g.

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and works on all operating systems. There are [other
parallel backends] to choose from, including alternatives to
parallelize locally as well as distributed across remote machines,
e.g.

```r
plan(future.mirai::mirai_multisession)
```

and

```r
plan(future.batchtools::batchtools_slurm)
```


# Supported Functions

The following **tm** functions are supported by `futurize()`:

* `tm_map()`
* `tm_index()`
* `TermDocumentMatrix()`


# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize `tm_map()`
using the **parallel** package directly, without **futurize**:

```r
library(tm)
library(parallel)

data("crude")

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)

## Configure tm to use the cluster
old_engine <- tm_parLapply_engine()
tm_parLapply_engine(function(X, FUN, ...) parLapply(cl, X, FUN, ...))

## Transform the corpus in parallel
m <- tm_map(crude, content_transformer(tolower))

## Restore the old engine and tear down the cluster
tm_parLapply_engine(old_engine)
stopCluster(cl)
```

This requires you to manually create a cluster, configure **tm**'s
internal parallel engine, and remember to restore the engine and tear
down the cluster when done. If you forget to call `stopCluster()`,
or if your code errors out before reaching it, you leak background R
processes. You also have to decide upfront how many CPUs to use, what
cluster type to use. Switching to another parallel backend, e.g. a
Slurm cluster, would require a completely different setup. With
**futurize**, all of this is handled for you - just pipe to
`futurize()` and control the backend with `plan()`.


[tm]: https://cran.r-project.org/package=tm
[other parallel backends]: https://www.futureverse.org/backends.html
