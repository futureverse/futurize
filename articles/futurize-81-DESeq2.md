# Parallelize 'DESeq2' functions

![The 'DESeq2' logo](../reference/figures/DESeq2-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(``DESeq2``)`\
\
`dds`` ``<-`` ``DESeqDataSetFromMatrix``(``countData``, ``colData``, design ``=`` ``~`` ``condition``)`\
`dds`` ``<-`` ``DESeq``(``dds``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[DESeq2](https://bioconductor.org/packages/DESeq2/)** `DESeq()`
function.

The **[DESeq2](https://bioconductor.org/packages/DESeq2/)** Bioconductor
package provides methods to test for differential expression in RNA-seq
data. The main function `DESeq()` runs a pipeline of gene-wise
dispersion estimation, fitting, and statistical testing, which can be
parallelized across genes.

### Example: Running DESeq() in parallel

The `DESeq()` function performs the full differential expression
analysis:

\
[`library`](https://rdrr.io/r/base/library.html)`(``DESeq2``)`\
\
`# Simulate data`\
`n_genes`` ``<-`` ``100L`\
`n_samples`` ``<-`` ``8L`\
`counts`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`\
`  `[`as.integer`](https://rdrr.io/r/base/integer.html)`(`[`runif`](https://rdrr.io/r/stats/Uniform.html)`(``n_genes`` ``*`` ``n_samples``, min ``=`` ``0``, max ``=`` ``1000``)``)``,`\
`  nrow ``=`` ``n_genes``,`\
`  ncol ``=`` ``n_samples``,`\
`  dimnames ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(`\
`    `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"gene"``, `[`seq_len`](https://rdrr.io/r/base/seq.html)`(``n_genes``)``)``,`\
`    `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"sample"``, `[`seq_len`](https://rdrr.io/r/base/seq.html)`(``n_samples``)``)`\
`  ``)`\
`)`\
` `\
`col_data`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`\
`  condition ``=`` `[`factor`](https://rdrr.io/r/base/factor.html)`(`[`rep`](https://rdrr.io/r/base/rep.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"control"``, ``"treated"``)``, each ``=`` ``n_samples`` ``/`` ``2L``)``)``,`\
`  row.names ``=`` `[`colnames`](https://rdrr.io/r/base/colnames.html)`(``counts``)`\
`)`\
\
`dds`` ``<-`` ``DESeqDataSetFromMatrix``(`\
`  countData ``=`` ``counts``,`\
`  colData ``=`` ``col_data``,`\
`  design ``=`` ``~`` ``condition`\
`)`\
\
`dds`` ``<-`` ``DESeq``(``dds``)`\
`res`` ``<-`` ``results``(``dds``)`

Here `DESeq()` runs sequentially, but we can easily make it run in
parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
\
`dds`` ``<-`` ``DESeq``(``dds``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`res`` ``<-`` ``results``(``dds``)`

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

The following **DESeq2** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- `DESeq()`
- `lfcShrink()`
- `results()`
