# Parallelize 'scater' functions

![The 'scater' logo](../reference/figures/scater-logo.webp)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.webp)= ![The
'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``scater``)`\
\
`sce`` ``<-`` ``scuttle``::``logNormCounts``(``sce``)`\
`sce`` ``<-`` ``runPCA``(``sce``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`sce`` ``<-`` ``runUMAP``(``sce``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[scater](https://bioconductor.org/packages/scater/)** functions.

The **[scater](https://bioconductor.org/packages/scater/)** Bioconductor
package provides tools for single-cell RNA-seq data analysis, including
dimensionality reduction methods such as PCA, t-SNE, and UMAP, which can
be parallelized across cells.

### Example: Running PCA in parallel

The `runPCA()` function performs PCA on a `SingleCellExperiment` object:

\
[`library`](https://rdrr.io/r/base/library.html)`(``scater``)`\
\
`# Simulate data`\
`sce`` ``<-`` ``scuttle``::``mockSCE``(``)`\
`sce`` ``<-`` ``scuttle``::``logNormCounts``(``sce``)`\
\
`sce`` ``<-`` ``runPCA``(``sce``)`

Here `runPCA()` runs sequentially, but we can easily make it run in
parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
\
`sce`` ``<-`` ``runPCA``(``sce``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the work across the available parallel workers,
given that we have set up parallel workers, e.g.

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`

The built-in `multisession` backend parallelizes on your local computer
and works on all operating systems. There are [other parallel
backends](https://www.futureverse.org/backends.html) to choose from,
including alternatives to parallelize locally as well as distributed
across remote machines, e.g.

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``future.mirai``::`[`mirai_multisession`](https://future.mirai.futureverse.org/reference/mirai_multisession.html)`)`

and

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``future.batchtools``::`[`batchtools_slurm`](https://future.batchtools.futureverse.org/reference/batchtools_slurm.html)`)`

## Supported Functions

The following **scater** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- `calculatePCA()`
- `calculateTSNE()`
- `calculateUMAP()`
- `runPCA()`
- `runTSNE()`
- `runUMAP()`
- `runColDataPCA()`
- `nexprs()`
- `getVarianceExplained()`
- `plotRLE()`
