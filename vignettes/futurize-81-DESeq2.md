<!--
%\VignetteIndexEntry{Parallelize 'DESeq2' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{DESeq2}
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
library(DESeq2)

dds <- DESeqDataSetFromMatrix(countData, colData, design = ~ condition)
dds <- DESeq(dds) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
the **[DESeq2]** `DESeq()` function.

The **[DESeq2]** Bioconductor package provides methods to test for
differential expression in RNA-seq data. The main function `DESeq()`
runs a pipeline of gene-wise dispersion estimation, fitting, and
statistical testing, which can be parallelized across genes.


## Example: Running DESeq in parallel

The `DESeq()` function performs the full differential expression
analysis:

```r
library(DESeq2)

dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = col_data,
  design = ~ condition
)
dds <- DESeq(dds)
res <- results(dds)
```

Here `DESeq()` runs sequentially, but we can easily make it run in
parallel by piping to `futurize()`:

```r
library(futurize)

dds <- DESeq(dds) |> futurize()
res <- results(dds)
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

The following **DESeq2** functions are supported by `futurize()`:

* `DESeq()`
* `lfcShrink()`
* `results()`


[DESeq2]: https://bioconductor.org/packages/DESeq2/
[other parallel backends]: https://www.futureverse.org/backends.html
