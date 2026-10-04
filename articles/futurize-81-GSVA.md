# Parallelize 'GSVA' functions

![The 'GSVA' logo](../reference/figures/GSVA-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(``GSVA``)`\
\
`param`` ``<-`` ``gsvaParam``(``expr``, ``geneSets``)`\
`es`` ``<-`` ``gsva``(``param``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[GSVA](https://bioconductor.org/packages/GSVA/)** functions.

The **[GSVA](https://bioconductor.org/packages/GSVA/)** Bioconductor
package implements gene set variation analysis, a non-parametric,
unsupervised method for estimating variation of gene set enrichment
through the samples of an expression data set. The main function
`gsva()` computes enrichment scores for each gene set and sample, which
can be parallelized across gene sets.

### Example: Running gsva() in parallel

The `gsva()` function computes gene set enrichment scores using
different methods depending on the parameter object passed to it:

\
[`library`](https://rdrr.io/r/base/library.html)`(``GSVA``)`\
\
`# Create example data`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``42``)`\
`n_genes`` ``<-`` ``200L`\
`n_samples`` ``<-`` ``120L`\
`expr`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_genes`` ``*`` ``n_samples``)``, nrow ``=`` ``n_genes``, ncol ``=`` ``n_samples``)`\
[`rownames`](https://rdrr.io/r/base/colnames.html)`(``expr``)`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"gene"``, `[`seq_len`](https://rdrr.io/r/base/seq.html)`(``n_genes``)``)`\
[`colnames`](https://rdrr.io/r/base/colnames.html)`(``expr``)`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"sample"``, `[`seq_len`](https://rdrr.io/r/base/seq.html)`(``n_samples``)``)`\
\
`geneSets`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`  geneSet1 ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"gene"``, `[`sample`](https://rdrr.io/r/base/sample.html)`(``n_genes``, ``30L``)``)``,`\
`  geneSet2 ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"gene"``, `[`sample`](https://rdrr.io/r/base/sample.html)`(``n_genes``, ``50L``)``)``,`\
`  geneSet3 ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"gene"``, `[`sample`](https://rdrr.io/r/base/sample.html)`(``n_genes``, ``40L``)``)`\
`)`\
\
`param`` ``<-`` ``gsvaParam``(``expr``, ``geneSets``)`\
`es`` ``<-`` ``gsva``(``param``)`

Here `gsva()` runs sequentially, but we can easily make it run in
parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
\
`es`` ``<-`` ``gsva``(``param``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

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

### Other enrichment methods

GSVA supports multiple enrichment methods through different parameter
objects. All of them can be parallelized with
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
`## ssGSEA method`\
`es`` ``<-`` ``gsva``(``ssgseaParam``(``expr``, ``geneSets``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`## PLAGE method`\
`es`` ``<-`` ``gsva``(``plageParam``(``expr``, ``geneSets``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`## Combined z-score method`\
`es`` ``<-`` ``gsva``(``zscoreParam``(``expr``, ``geneSets``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Supported Functions

The following **GSVA** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- `gsva()`
- `gsvaRanks()`
- `gsvaScores()`
- `spatCor()`
