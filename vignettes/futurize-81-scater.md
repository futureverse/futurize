<!--
%\VignetteIndexEntry{Parallelize 'scater' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{scater}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/futurize-logo.png" alt="The 'futurize' hexlogo">
<span>=</span>
<img src="../man/figures/future-logo.png" alt="The 'future' logo">
</div>

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!


# TL;DR

```r
library(futurize)
plan(multisession)
library(scater)

sce <- scuttle::logNormCounts(sce)
sce <- runPCA(sce) |> futurize()
sce <- runUMAP(sce) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
the **[scater]** functions.

The **[scater]** Bioconductor package provides tools for
single-cell RNA-seq data analysis, including dimensionality
reduction methods such as PCA, t-SNE, and UMAP, which can be
parallelized across cells.


## Example: Running PCA in parallel

The `runPCA()` function performs PCA on a `SingleCellExperiment`
object:

```r
library(scater)

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
sce <- scuttle::logNormCounts(sce)

sce <- runPCA(sce)
```

Here `runPCA()` runs sequentially, but we can easily make it run in
parallel by piping to `futurize()`:

```r
library(futurize)

sce <- runPCA(sce) |> futurize()
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

The following **scater** functions are supported by `futurize()`:

* `calculatePCA()`
* `calculateTSNE()`
* `calculateUMAP()`
* `runPCA()`
* `runTSNE()`
* `runUMAP()`
* `runColDataPCA()`
* `nexprs()`
* `getVarianceExplained()`
* `plotRLE()`


[scater]: https://bioconductor.org/packages/scater/
[other parallel backends]: https://www.futureverse.org/backends.html
