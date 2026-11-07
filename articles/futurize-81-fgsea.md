# Parallelize 'fgsea' functions

![The 'fgsea' logo](../reference/figures/bioconductor-fgsea-logo.webp)+
![The 'futurize' hexlogo](../reference/figures/futurize-logo.webp)=
![The 'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``fgsea``)`\
\
`res`` ``<-`` ``fgsea``(``pathways``, ``stats``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[fgsea](https://bioconductor.org/packages/fgsea/)** functions.

The **[fgsea](https://bioconductor.org/packages/fgsea/)** Bioconductor
package implements fast preranked gene set enrichment analysis (GSEA).
The main functions `fgsea()`, `fgseaMultilevel()`, and `fgseaSimple()`
perform permutation-based enrichment testing, which can be parallelized
across gene sets.

### Example: Running fgseaSimple() in parallel

The `fgseaSimple()` function performs permutation-based gene set
enrichment analysis:

\
[`library`](https://rdrr.io/r/base/library.html)`(``fgsea``)`\
\
`# Create example data`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``42``)`\
`n_genes`` ``<-`` ``1000L`\
`stats`` ``<-`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n_genes``)`\
[`names`](https://rdrr.io/r/base/names.html)`(``stats``)`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"gene"``, `[`seq_len`](https://rdrr.io/r/base/seq.html)`(``n_genes``)``)`\
\
`pathways`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`  pathway1 ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"gene"``, `[`sample`](https://rdrr.io/r/base/sample.html)`(``n_genes``, ``50L``)``)``,`\
`  pathway2 ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"gene"``, `[`sample`](https://rdrr.io/r/base/sample.html)`(``n_genes``, ``100L``)``)``,`\
`  pathway3 ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"gene"``, `[`sample`](https://rdrr.io/r/base/sample.html)`(``n_genes``, ``150L``)``)`\
`)`\
\
`res`` ``<-`` ``fgseaSimple``(``pathways``, ``stats``, nperm ``=`` ``10000``)`

Here `fgseaSimple()` runs sequentially, but we can easily make it run in
parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
\
`res`` ``<-`` ``fgseaSimple``(``pathways``, ``stats``, nperm ``=`` ``10000``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

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

The following **fgsea** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- `fgsea()`
- `fgseaMultilevel()`
- `fgseaSimple()`
- `fgseaLabel()`
- `geseca()`
- `gesecaSimple()`
- `collapsePathwaysGeseca()`
