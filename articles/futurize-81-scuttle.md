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

qc <- perFeatureQCMetrics(sce) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[scuttle](https://bioconductor.org/packages/scuttle/)** functions.

The **[scuttle](https://bioconductor.org/packages/scuttle/)**
Bioconductor package provides basic utility functions for single-cell
RNA-seq data analysis, including quality control, normalization, and
aggregation, which can be parallelized across cells or features.

### Example: Computing per-feature QC metrics in parallel

The `perFeatureQCMetrics()` function computes quality control metrics
for each feature (gene) in a `SingleCellExperiment` object:

``` r

library(scuttle)

# Simulate data
sce <- mockSCE()

qc <- perFeatureQCMetrics(sce)
```

Here `perFeatureQCMetrics()` runs sequentially, but we can easily make
it run in parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)

qc <- perFeatureQCMetrics(sce) |> futurize()
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

- `calculateAverage()`
- `perFeatureQCMetrics()`
- `numDetectedAcrossFeatures()`
- `summarizeAssayByGroup()`
- `medianSizeFactors()`
- `computeMedianFactors()`
- `pooledSizeFactors()`
- `computePooledFactors()`
- `fitLinearModel()`

The following **scuttle** functions are deprecated in **scuttle** (\>=
1.22) in favor of counter-part functions in Bioconductor package
**[scrapper](https://bioconductor.org/packages/scrapper/)**. Support for
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
of the these deprecated functions remains, but will be phased out;

- `logNormCounts()`
- `normalizeCounts()`
- `perCellQCMetrics()`
- `addPerCellQCMetrics()`
- `addPerFeatureQCMetrics()`
- `addPerCellQC()`
- `addPerFeatureQC()`
- `numDetectedAcrossCells()`
- `sumCountsAcrossCells()`
- `sumCountsAcrossFeatures()`
- `aggregateAcrossCells()`
- `aggregateAcrossFeatures()`
- `librarySizeFactors()`
- `computeLibraryFactors()`
- `geometricSizeFactors()`
- `computeGeometricFactors()`
