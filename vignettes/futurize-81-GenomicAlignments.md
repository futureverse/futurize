<!--
%\VignetteIndexEntry{Parallelize 'GenomicAlignments' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{GenomicAlignments}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/bioconductor-GenomicAlignments-logo.svg" alt="The 'GenomicAlignments' logo">
<span>+</span>
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
library(GenomicAlignments)

se <- summarizeOverlaps(features, bam_files) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
the **[GenomicAlignments]** functions.

The **[GenomicAlignments]** Bioconductor package provides efficient
representation and manipulation of short genomic alignments. The
`summarizeOverlaps()` function counts the number of reads that map to
each feature (e.g. gene or exon) from one or more BAM files. When
called with a `BamFileList`, the work is distributed across BAM files
using `bplapply()`, which can be parallelized.


## Example: Running summarizeOverlaps() in parallel

The `summarizeOverlaps()` function counts reads overlapping genomic
features across multiple BAM files:

```r
library(GenomicAlignments)
library(Rsamtools)

bam_files <- BamFileList(c("sample1.bam", "sample2.bam", "sample3.bam"))
features <- GRanges("chr1",
  IRanges(start = c(1, 1000, 2000), end = c(500, 1500, 2500))
)

se <- summarizeOverlaps(features, bam_files)
```

Here `summarizeOverlaps()` processes BAM files sequentially, but we
can easily make it process them in parallel by piping to `futurize()`:

```r
library(futurize)

se <- summarizeOverlaps(features, bam_files) |> futurize()
```

This will distribute the BAM file processing across the available
parallel workers, given that we have set up parallel workers, e.g.

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

The following **GenomicAlignments** functions are supported by `futurize()`:

* `summarizeOverlaps()`


[GenomicAlignments]: https://bioconductor.org/packages/GenomicAlignments/
[other parallel backends]: https://www.futureverse.org/backends.html
