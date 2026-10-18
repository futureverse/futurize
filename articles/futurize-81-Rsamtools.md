# Parallelize 'Rsamtools' functions

![The 'Rsamtools' logo](../reference/figures/Rsamtools-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`Rsamtools`](https://bioconductor.org/packages/Rsamtools)`)`\
\
`bv`` ``<-`` `[`BamViews`](https://rdrr.io/pkg/Rsamtools/man/BamViews-class.html)`(``bam_files``)`\
`counts`` ``<-`` `[`countBam`](https://rdrr.io/pkg/Rsamtools/man/scanBam.html)`(``bv``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[Rsamtools](https://bioconductor.org/packages/Rsamtools/)** functions.

The **[Rsamtools](https://bioconductor.org/packages/Rsamtools/)**
Bioconductor package provides an interface to BAM (Binary Alignment Map)
files and other high-throughput sequencing data formats. Functions like
[`countBam()`](https://rdrr.io/pkg/Rsamtools/man/scanBam.html) and
[`scanBam()`](https://rdrr.io/pkg/Rsamtools/man/scanBam.html) can
process multiple BAM files in parallel when called with a `BamViews`
object, which distributes work across BAM files using
[`bplapply()`](https://rdrr.io/pkg/BiocParallel/man/bplapply.html).

### Example: Counting reads across multiple BAM files in parallel

The [`countBam()`](https://rdrr.io/pkg/Rsamtools/man/scanBam.html)
function counts the number of records in BAM files. When called with a
`BamViews` object containing multiple BAM files, the counting can be
parallelized:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`Rsamtools`](https://bioconductor.org/packages/Rsamtools)`)`\
\
`bam_files`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"sample1.bam"``, ``"sample2.bam"``, ``"sample3.bam"``)`\
`bv`` ``<-`` `[`BamViews`](https://rdrr.io/pkg/Rsamtools/man/BamViews-class.html)`(``bam_files``)`\
\
`counts`` ``<-`` `[`countBam`](https://rdrr.io/pkg/Rsamtools/man/scanBam.html)`(``bv``)`

Here [`countBam()`](https://rdrr.io/pkg/Rsamtools/man/scanBam.html)
processes BAM files sequentially, but we can easily make it process them
in parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
\
`counts`` ``<-`` `[`countBam`](https://rdrr.io/pkg/Rsamtools/man/scanBam.html)`(``bv``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

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

The following **Rsamtools** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`countBam()`](https://rdrr.io/pkg/Rsamtools/man/scanBam.html)
- [`scanBam()`](https://rdrr.io/pkg/Rsamtools/man/scanBam.html)
