<!--
%\VignetteIndexEntry{Parallelize 'Rsamtools' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{Rsamtools}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/Rsamtools-logo.webp" alt="The 'Rsamtools' logo">
<span>+</span>
<img src="../man/figures/futurize-logo.webp" alt="The 'futurize' hexlogo">
<span>=</span>
<img src="../man/figures/future-logo.webp" alt="The 'future' logo">
</div>

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!


# TL;DR

```r
library(futurize)
plan(multisession)
library(Rsamtools)

bv <- BamViews(bam_files)
counts <- countBam(bv) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
the **[Rsamtools]** functions.

The **[Rsamtools]** Bioconductor package provides an interface to
BAM (Binary Alignment Map) files and other high-throughput sequencing
data formats. Functions like `countBam()` and `scanBam()` can process
multiple BAM files in parallel when called with a `BamViews` object,
which distributes work across BAM files using `bplapply()`.


## Example: Counting reads across multiple BAM files in parallel

The `countBam()` function counts the number of records in BAM files.
When called with a `BamViews` object containing multiple BAM files,
the counting can be parallelized:

```r
library(Rsamtools)

bam_files <- c("sample1.bam", "sample2.bam", "sample3.bam")
bv <- BamViews(bam_files)

counts <- countBam(bv)
```

Here `countBam()` processes BAM files sequentially, but we can easily
make it process them in parallel by piping to `futurize()`:

```r
library(futurize)

counts <- countBam(bv) |> futurize()
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

The following **Rsamtools** functions are supported by `futurize()`:

* `countBam()`
* `scanBam()`


[Rsamtools]: https://bioconductor.org/packages/Rsamtools/
[other parallel backends]: https://www.futureverse.org/backends.html
