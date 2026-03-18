# Parallelize 'scater' functions

![The 'scater' logo](../reference/figures/scater-logo.webp)+ ![The
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
library(scater)

sce <- scuttle::logNormCounts(sce)
sce <- runPCA(sce) |> futurize()
sce <- runUMAP(sce) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[scater](https://bioconductor.org/packages/scater/)** functions.

The **[scater](https://bioconductor.org/packages/scater/)** Bioconductor
package provides tools for single-cell RNA-seq data analysis, including
dimensionality reduction methods such as PCA, t-SNE, and UMAP, which can
be parallelized across cells.

### Example: Running PCA in parallel

The [`runPCA()`](https://rdrr.io/pkg/BiocSingular/man/runPCA.html)
function performs PCA on a `SingleCellExperiment` object:

``` r

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

Here [`runPCA()`](https://rdrr.io/pkg/BiocSingular/man/runPCA.html) runs
sequentially, but we can easily make it run in parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)

sce <- runPCA(sce) |> futurize()
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

The following **scater** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`calculatePCA()`](https://rdrr.io/pkg/scater/man/runPCA.html)
- [`calculateTSNE()`](https://rdrr.io/pkg/scater/man/runTSNE.html)
- [`calculateUMAP()`](https://rdrr.io/pkg/scater/man/runUMAP.html)
- [`runPCA()`](https://rdrr.io/pkg/BiocSingular/man/runPCA.html)
- [`runTSNE()`](https://rdrr.io/pkg/scater/man/runTSNE.html)
- [`runUMAP()`](https://rdrr.io/pkg/scater/man/runUMAP.html)
- [`runColDataPCA()`](https://rdrr.io/pkg/scater/man/runColDataPCA.html)
- [`nexprs()`](https://rdrr.io/pkg/scater/man/nexprs.html)
- [`getVarianceExplained()`](https://rdrr.io/pkg/scater/man/getVarianceExplained.html)
- [`plotRLE()`](https://rdrr.io/pkg/scater/man/plotRLE.html)
