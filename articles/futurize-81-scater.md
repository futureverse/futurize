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
[`library`](https://rdrr.io/r/base/library.html)`(`[`scater`](http://bioconductor.org/packages/scater/)`)`\
\
`sce`` ``<-`` ``scuttle``::`[`logNormCounts`](https://rdrr.io/pkg/scuttle/man/logNormCounts.html)`(``sce``)`\
`sce`` ``<-`` `[`runPCA`](https://rdrr.io/pkg/BiocSingular/man/runPCA.html)`(``sce``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`sce`` ``<-`` `[`runUMAP`](https://rdrr.io/pkg/scater/man/runUMAP.html)`(``sce``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

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

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`scater`](http://bioconductor.org/packages/scater/)`)`\
\
`# Simulate data`\
`sce`` ``<-`` ``scuttle``::`[`mockSCE`](https://rdrr.io/pkg/scuttle/man/mockSCE.html)`(``)`\
`sce`` ``<-`` ``scuttle``::`[`logNormCounts`](https://rdrr.io/pkg/scuttle/man/logNormCounts.html)`(``sce``)`\
\
`sce`` ``<-`` `[`runPCA`](https://rdrr.io/pkg/BiocSingular/man/runPCA.html)`(``sce``)`

Here [`runPCA()`](https://rdrr.io/pkg/BiocSingular/man/runPCA.html) runs
sequentially, but we can easily make it run in parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
\
`sce`` ``<-`` `[`runPCA`](https://rdrr.io/pkg/BiocSingular/man/runPCA.html)`(``sce``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

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
