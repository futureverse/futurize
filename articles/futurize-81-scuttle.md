# Parallelize 'scuttle' functions

![The 'scuttle'
logo](../reference/figures/bioconductor-scuttle-logo.webp)+ ![The
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
library(scuttle)

sce <- logNormCounts(sce) |> futurize()
qc <- perCellQCMetrics(sce) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[scuttle](https://bioconductor.org/packages/scuttle/)** functions.

The **[scuttle](https://bioconductor.org/packages/scuttle/)**
Bioconductor package provides basic utility functions for single-cell
RNA-seq data analysis, including quality control, normalization, and
aggregation, which can be parallelized across cells.

### Example: Log-normalizing counts in parallel

The
[`logNormCounts()`](https://rdrr.io/pkg/scuttle/man/logNormCounts.html)
function computes log-normalized expression values for a
`SingleCellExperiment` object:

``` r

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

Here
[`logNormCounts()`](https://rdrr.io/pkg/scuttle/man/logNormCounts.html)
runs sequentially, but we can easily make it run in parallel by piping
to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)

sce <- logNormCounts(sce) |> futurize()
```

This will distribute the work across the available parallel workers,
given that we have set up parallel workers, e.g.

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

The following **scuttle** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`calculateAverage()`](https://rdrr.io/pkg/scuttle/man/calculateAverage.html)
- [`logNormCounts()`](https://rdrr.io/pkg/scuttle/man/logNormCounts.html)
- [`normalizeCounts()`](https://rdrr.io/pkg/scuttle/man/normalizeCounts.html)
- [`perCellQCMetrics()`](https://rdrr.io/pkg/scuttle/man/perCellQCMetrics.html)
- [`perFeatureQCMetrics()`](https://rdrr.io/pkg/scuttle/man/perFeatureQCMetrics.html)
- [`addPerCellQCMetrics()`](https://rdrr.io/pkg/scuttle/man/addPerCellQCMetrics.html)
- [`addPerFeatureQCMetrics()`](https://rdrr.io/pkg/scuttle/man/addPerCellQCMetrics.html)
- [`addPerCellQC()`](https://rdrr.io/pkg/scuttle/man/addPerCellQCMetrics.html)
- [`addPerFeatureQC()`](https://rdrr.io/pkg/scuttle/man/addPerCellQCMetrics.html)
- [`numDetectedAcrossCells()`](https://rdrr.io/pkg/scuttle/man/numDetectedAcrossCells.html)
- [`numDetectedAcrossFeatures()`](https://rdrr.io/pkg/scuttle/man/numDetectedAcrossFeatures.html)
- [`sumCountsAcrossCells()`](https://rdrr.io/pkg/scuttle/man/sumCountsAcrossCells.html)
- [`sumCountsAcrossFeatures()`](https://rdrr.io/pkg/scuttle/man/sumCountsAcrossFeatures.html)
- [`summarizeAssayByGroup()`](https://rdrr.io/pkg/scuttle/man/summarizeAssayByGroup.html)
- [`aggregateAcrossCells()`](https://rdrr.io/pkg/scuttle/man/aggregateAcrossCells.html)
- [`aggregateAcrossFeatures()`](https://rdrr.io/pkg/scuttle/man/aggregateAcrossFeatures.html)
- [`librarySizeFactors()`](https://rdrr.io/pkg/scuttle/man/librarySizeFactors.html)
- [`computeLibraryFactors()`](https://rdrr.io/pkg/scuttle/man/librarySizeFactors.html)
- [`geometricSizeFactors()`](https://rdrr.io/pkg/scuttle/man/geometricSizeFactors.html)
- [`computeGeometricFactors()`](https://rdrr.io/pkg/scuttle/man/geometricSizeFactors.html)
- [`medianSizeFactors()`](https://rdrr.io/pkg/scuttle/man/medianSizeFactors.html)
- [`computeMedianFactors()`](https://rdrr.io/pkg/scuttle/man/medianSizeFactors.html)
- [`pooledSizeFactors()`](https://rdrr.io/pkg/scuttle/man/computePooledFactors.html)
- [`computePooledFactors()`](https://rdrr.io/pkg/scuttle/man/computePooledFactors.html)
- [`fitLinearModel()`](https://rdrr.io/pkg/scuttle/man/fitLinearModel.html)
