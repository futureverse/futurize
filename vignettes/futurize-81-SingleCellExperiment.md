<!--
%\VignetteIndexEntry{Parallelize 'SingleCellExperiment' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{SingleCellExperiment}
%\VignetteKeyword{scuttle}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/SingleCellExperiment-logo.webp" alt="The 'SingleCellExperiment' logo">
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
library(SingleCellExperiment)
library(scuttle)

result <- applySCE(sce, perFeatureQCMetrics) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
the **[SingleCellExperiment]** functions.

The **[SingleCellExperiment]** Bioconductor package defines the
`SingleCellExperiment` class for storing single-cell genomics data,
including alternative experiments (e.g. spike-in transcripts, antibody
tags). The `applySCE()` function applies a given function to the main
experiment and each alternative experiment, passing additional
arguments such as `BPPARAM` via `...` to enable parallelization of
the applied function.


## Example: Computing per-feature QC metrics in parallel

The `applySCE()` function applies a function across the main
experiment and its alternative experiments:

```r
library(SingleCellExperiment)
library(scuttle)

# Simulate data
sce <- mockSCE()

result <- applySCE(sce, perFeatureQCMetrics)
```

Here `applySCE()` runs `perFeatureQCMetrics()` from the **[scuttle]**
package sequentially on each experiment, but we can easily make it run
in parallel by piping to `futurize()`:

```r
library(futurize)

result <- applySCE(sce, perFeatureQCMetrics) |> futurize()
```

It is actually not `SingleCellExperiment::applySCE()` that
orchestrates the parallelization, but `scuttle::perFeatureQCMetrics()`,
which hands of the parallelization to **[BiocParallel]** which in turn
hands it of to futureverse.

The above will distribute the work across the available parallel
workers, given that we have set up parallel workers, e.g.

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

The following **SingleCellExperiment** functions are supported by `futurize()`:

* `applySCE()`


[BiocParallel]: https://bioconductor.org/packages/BiocParallel/
[SingleCellExperiment]: https://bioconductor.org/packages/SingleCellExperiment/
[scuttle]: https://bioconductor.org/packages/scuttle/
[other parallel backends]: https://www.futureverse.org/backends.html
