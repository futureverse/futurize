# Parallelize 'tm' functions

![The 'tm' image](../reference/figures/cran-tm-logo.svg)+ ![The
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
library(tm)

data("crude")
m <- tm_map(crude, content_transformer(tolower)) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[tm](https://cran.r-project.org/package=tm)** functions such as
[`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html).

The **[tm](https://cran.r-project.org/package=tm)** package provides a
variety of text-mining methods. The
[`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html) function applies
transformations to a corpus of text documents, and
[`TermDocumentMatrix()`](https://rdrr.io/pkg/tm/man/matrix.html)
constructs document-term matrices. When working with large corpora,
these operations benefit greatly from parallelization.

### Example: Transforming a text corpus

The [`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html) function
applies a transformation to each document in a corpus:

``` r

library(tm)

## Load the crude oil news corpus holding 20 documents
data("crude")

## Convert all text to lowercase
m <- tm_map(crude, content_transformer(tolower))
```

Here [`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html) evaluates
sequentially, but we can easily make it evaluate in parallel by piping
to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(tm)
library(futurize)
plan(multisession)

data("crude")
m <- tm_map(crude, content_transformer(tolower)) |> futurize()
```

This will distribute the document transformations across the available
parallel workers, given that we have set up parallel workers, e.g.

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

The following **tm** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html)
- [`tm_index()`](https://rdrr.io/pkg/tm/man/tm_filter.html)
- [`TermDocumentMatrix()`](https://rdrr.io/pkg/tm/man/matrix.html)
