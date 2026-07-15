# Parallelize 'SingleCellExperiment' functions

![The 'SingleCellExperiment'
logo](../reference/figures/SingleCellExperiment-logo.webp)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.webp)= ![The
'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(SingleCellExperiment)
library(scuttle)

result <- applySCE(sce, perFeatureQCMetrics) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[SingleCellExperiment](https://bioconductor.org/packages/SingleCellExperiment/)**
functions.

The
**[SingleCellExperiment](https://bioconductor.org/packages/SingleCellExperiment/)**
Bioconductor package defines the `SingleCellExperiment` class for
storing single-cell genomics data, including alternative experiments
(e.g. spike-in transcripts, antibody tags). The `applySCE()` function
applies a given function to the main experiment and each alternative
experiment, passing additional arguments such as `BPPARAM` via `...` to
enable parallelization of the applied function.

### Example: Computing per-feature QC metrics in parallel

The `applySCE()` function applies a function across the main experiment
and its alternative experiments:

``` r

library(SingleCellExperiment)
library(scuttle)

# Simulate data
sce <- mockSCE()

result <- applySCE(sce, perFeatureQCMetrics)
```

Here `applySCE()` runs `perFeatureQCMetrics()` from the
**[scuttle](https://bioconductor.org/packages/scuttle/)** package
sequentially on each experiment, but we can easily make it run in
parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)

result <- applySCE(sce, perFeatureQCMetrics) |> futurize()
```

It is actually not `SingleCellExperiment::applySCE()` that orchestrates
the parallelization, but `scuttle::perFeatureQCMetrics()`, which hands
of the parallelization to
**[BiocParallel](https://bioconductor.org/packages/BiocParallel/)**
which in turn hands it of to futureverse.

The above will distribute the work across the available parallel
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

The following **SingleCellExperiment** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- `applySCE()`
