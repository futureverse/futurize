# Parallelize 'GenomicAlignments' functions

![The 'GenomicAlignments'
logo](../reference/figures/bioconductor-GenomicAlignments-logo.webp)+
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
[`library`](https://rdrr.io/r/base/library.html)`(``GenomicAlignments``)`\
\
`se`` ``<-`` ``summarizeOverlaps``(``features``, ``bam_files``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[GenomicAlignments](https://bioconductor.org/packages/GenomicAlignments/)**
functions.

The
**[GenomicAlignments](https://bioconductor.org/packages/GenomicAlignments/)**
Bioconductor package provides efficient representation and manipulation
of short genomic alignments. The `summarizeOverlaps()` function counts
the number of reads that map to each feature (e.g. gene or exon) from
one or more BAM files. When called with a `BamFileList`, the work is
distributed across BAM files using `bplapply()`, which can be
parallelized.

### Example: Running summarizeOverlaps() in parallel

The `summarizeOverlaps()` function counts reads overlapping genomic
features across multiple BAM files:

\
[`library`](https://rdrr.io/r/base/library.html)`(``GenomicAlignments``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``Rsamtools``)`\
\
`bam_files`` ``<-`` ``BamFileList``(`[`c`](https://rdrr.io/r/base/c.html)`(``"sample1.bam"``, ``"sample2.bam"``, ``"sample3.bam"``)``)`\
`features`` ``<-`` ``GRanges``(``"chr1"``,`\
`  ``IRanges``(``start ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``1``, ``1000``, ``2000``)``, end ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``500``, ``1500``, ``2500``)``)`\
`)`\
\
`se`` ``<-`` ``summarizeOverlaps``(``features``, ``bam_files``)`

Here `summarizeOverlaps()` processes BAM files sequentially, but we can
easily make it process them in parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
\
`se`` ``<-`` ``summarizeOverlaps``(``features``, ``bam_files``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the BAM file processing across the available
parallel workers, given that we have set up parallel workers, e.g.

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

The following **GenomicAlignments** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- `summarizeOverlaps()`
