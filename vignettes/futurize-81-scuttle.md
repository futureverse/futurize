<!--
%\VignetteIndexEntry{Parallelize 'scuttle' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{scuttle}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/bioconductor-scuttle-logo.webp" alt="The 'scuttle' logo">
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
library(scuttle)

sce <- logNormCounts(sce) |> futurize()
qc <- perCellQCMetrics(sce) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
the **[scuttle]** functions.

The **[scuttle]** Bioconductor package provides basic utility
functions for single-cell RNA-seq data analysis, including quality
control, normalization, and aggregation, which can be parallelized
across cells.


## Example: Log-normalizing counts in parallel

The `logNormCounts()` function computes log-normalized expression
values for a `SingleCellExperiment` object:

```r
library(scuttle)

# Simulate data
set.seed(42)
n_genes <- 200L
n_cells <- 100L
counts <- matrix(
  rpois(n_genes * n_cells, lambda = 10),
  nrow = n_genes,
  ncol = n_cells,
  dimnames = list(
    paste0("gene", seq_len(n_genes)),
    paste0("cell", seq_len(n_cells))
  )
)

sce <- SingleCellExperiment::SingleCellExperiment(
  assays = list(counts = counts)
)

sce <- logNormCounts(sce)
```

Here `logNormCounts()` runs sequentially, but we can easily make it
run in parallel by piping to `futurize()`:

```r
library(futurize)

sce <- logNormCounts(sce) |> futurize()
```

This will distribute the work across the available parallel workers,
given that we have set up parallel workers, e.g.

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

The following **scuttle** functions are supported by `futurize()`:

* `calculateAverage()`
* `logNormCounts()`
* `normalizeCounts()`
* `perCellQCMetrics()`
* `perFeatureQCMetrics()`
* `addPerCellQCMetrics()`
* `addPerFeatureQCMetrics()`
* `addPerCellQC()`
* `addPerFeatureQC()`
* `numDetectedAcrossCells()`
* `numDetectedAcrossFeatures()`
* `sumCountsAcrossCells()`
* `sumCountsAcrossFeatures()`
* `summarizeAssayByGroup()`
* `aggregateAcrossCells()`
* `aggregateAcrossFeatures()`
* `librarySizeFactors()`
* `computeLibraryFactors()`
* `geometricSizeFactors()`
* `computeGeometricFactors()`
* `medianSizeFactors()`
* `computeMedianFactors()`
* `pooledSizeFactors()`
* `computePooledFactors()`
* `fitLinearModel()`


[scuttle]: https://bioconductor.org/packages/scuttle/
[other parallel backends]: https://www.futureverse.org/backends.html
