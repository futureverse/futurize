# Parallelize 'DESeq2' functions

![The 'futurize' hexlogo](../reference/figures/futurize-logo.png)= ![The
'future' logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(DESeq2)

dds <- DESeqDataSetFromMatrix(countData, colData, design = ~ condition)
dds <- DESeq(dds) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[DESeq2](https://bioconductor.org/packages/DESeq2/)**
[`DESeq()`](https://rdrr.io/pkg/DESeq2/man/DESeq.html) function.

The **[DESeq2](https://bioconductor.org/packages/DESeq2/)** Bioconductor
package provides methods to test for differential expression in RNA-seq
data. The main function
[`DESeq()`](https://rdrr.io/pkg/DESeq2/man/DESeq.html) runs a pipeline
of gene-wise dispersion estimation, fitting, and statistical testing,
which can be parallelized across genes.

### Example: Running DESeq in parallel

The [`DESeq()`](https://rdrr.io/pkg/DESeq2/man/DESeq.html) function
performs the full differential expression analysis:

``` r

library(DESeq2)

# Simulate data
n_genes <- 100L
n_samples <- 8L
counts <- matrix(
  as.integer(runif(n_genes * n_samples, min = 0, max = 1000)),
  nrow = n_genes,
  ncol = n_samples,
  dimnames = list(
    paste0("gene", seq_len(n_genes)),
    paste0("sample", seq_len(n_samples))
  )
)
 
col_data <- data.frame(
  condition = factor(rep(c("control", "treated"), each = n_samples / 2L)),
  row.names = colnames(counts)
)

dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = col_data,
  design = ~ condition
)

dds <- DESeq(dds)
res <- results(dds)
```

Here [`DESeq()`](https://rdrr.io/pkg/DESeq2/man/DESeq.html) runs
sequentially, but we can easily make it run in parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)

dds <- DESeq(dds) |> futurize()
res <- results(dds)
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

The following **DESeq2** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`DESeq()`](https://rdrr.io/pkg/DESeq2/man/DESeq.html)
- [`lfcShrink()`](https://rdrr.io/pkg/DESeq2/man/lfcShrink.html)
- [`results()`](https://rdrr.io/pkg/DESeq2/man/results.html)
