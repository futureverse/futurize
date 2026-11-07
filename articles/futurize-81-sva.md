# Parallelize 'sva' functions

![The 'sva' logo](../reference/figures/sva-logo.webp)+ ![The 'futurize'
hexlogo](../reference/figures/futurize-logo.webp)= ![The 'future'
logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``sva``)`\
\
`adjusted`` ``<-`` ``ComBat``(``dat ``=`` ``dat``, batch ``=`` ``batch``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[sva](https://bioconductor.org/packages/sva/)** functions.

The **[sva](https://bioconductor.org/packages/sva/)** Bioconductor
package provides functions for removing batch effects and other unwanted
variation in high-throughput experiments. The `ComBat()` function is a
widely used method for batch effect correction using an empirical Bayes
framework. It supports parallelization via BiocParallel’s BPPARAM
argument.

### Example: Running ComBat() in parallel

The `ComBat()` function adjusts for known batch effects in microarray or
RNA-seq data:

\
[`library`](https://rdrr.io/r/base/library.html)`(``sva``)`\
\
`# Create example data with batch effect`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``42``)`\
`n_genes`` ``<-`` ``200L`\
`n_samples`` ``<-`` ``40L`\
`dat`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_genes`` ``*`` ``n_samples``)``, nrow ``=`` ``n_genes``, ncol ``=`` ``n_samples``)`\
[`rownames`](https://rdrr.io/r/base/colnames.html)`(``dat``)`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"gene"``, `[`seq_len`](https://rdrr.io/r/base/seq.html)`(``n_genes``)``)`\
[`colnames`](https://rdrr.io/r/base/colnames.html)`(``dat``)`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"sample"``, `[`seq_len`](https://rdrr.io/r/base/seq.html)`(``n_samples``)``)`\
\
`batch`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``1``, ``2``)``, each ``=`` ``n_samples`` ``/`` ``2L``)`\
`dat``[``, ``batch`` ``==`` ``2``]`` ``<-`` ``dat``[``, ``batch`` ``==`` ``2``]`` ``+`` ``2`\
\
`adjusted`` ``<-`` ``ComBat``(``dat ``=`` ``dat``, batch ``=`` ``batch``)`

Here `ComBat()` runs sequentially, but we can easily make it run in
parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
\
`adjusted`` ``<-`` ``ComBat``(``dat ``=`` ``dat``, batch ``=`` ``batch``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

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

### Using ComBat() with a model matrix

You can also include a model matrix for biological covariates of
interest, which will be protected during batch correction:

\
`mod`` ``<-`` `[`model.matrix`](https://rdrr.io/r/stats/model.matrix.html)`(``~`` ``group``)`\
`adjusted`` ``<-`` ``ComBat``(``dat ``=`` ``dat``, batch ``=`` ``batch``, mod ``=`` ``mod``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Supported Functions

The following **sva** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- `ComBat()`
- `read.degradation.matrix()`
