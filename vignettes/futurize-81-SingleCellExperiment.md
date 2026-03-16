<!--
%\VignetteIndexEntry{Parallelize 'SingleCellExperiment' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{SingleCellExperiment}
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
library(SingleCellExperiment)
library(scuttle)

result <- applySCE(sce, perCellQCMetrics) |> futurize()
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


## Example: Computing per-cell QC metrics in parallel

The `applySCE()` function applies a function across the main
experiment and its alternative experiments:

```r
library(SingleCellExperiment)
library(scuttle)

# Simulate data
set.seed(42)
n_genes <- 200L
n_cells <- 100L
counts <- matrix(
  rpois(n_genes * n_cells, lambda = 10),
  nrow = n_genes,
  ncol = n_cells,
  dimnames = list(
    paste0("gene", seq_len(n_genes)),
    paste0("cell", seq_len(n_cells))
  )
)

sce <- SingleCellExperiment(
  assays = list(counts = counts)
)

# Add an alternative experiment (e.g. spike-ins)
spike_counts <- matrix(
  rpois(10L * n_cells, lambda = 5),
  nrow = 10L,
  ncol = n_cells
)
rownames(spike_counts) <- paste0("spike", seq_len(10L))
colnames(spike_counts) <- paste0("cell", seq_len(n_cells))

altExp(sce, "spikes") <- SingleCellExperiment(
  assays = list(counts = spike_counts)
)

result <- applySCE(sce, perCellQCMetrics)
```

Here `applySCE()` runs `perCellQCMetrics()` sequentially on each
experiment, but we can easily make it run in parallel by piping to
`futurize()`:

```r
library(futurize)

result <- applySCE(sce, perCellQCMetrics) |> futurize()
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

The following **SingleCellExperiment** functions are supported by `futurize()`:

* `applySCE()`


[SingleCellExperiment]: https://bioconductor.org/packages/SingleCellExperiment/
[other parallel backends]: https://www.futureverse.org/backends.html
