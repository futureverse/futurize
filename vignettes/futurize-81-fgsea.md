<!--
%\VignetteIndexEntry{Parallelize 'fgsea' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{fgsea}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/bioconductor-fgsea-logo.webp" alt="The 'fgsea' logo">
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
library(fgsea)

res <- fgsea(pathways, stats) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
the **[fgsea]** functions.

The **[fgsea]** Bioconductor package implements fast preranked gene
set enrichment analysis (GSEA). The main functions `fgsea()`,
`fgseaMultilevel()`, and `fgseaSimple()` perform permutation-based
enrichment testing, which can be parallelized across gene sets.


## Example: Running fgseaSimple() in parallel

The `fgseaSimple()` function performs permutation-based gene set
enrichment analysis:

```r
library(fgsea)

# Create example data
set.seed(42)
n_genes <- 1000L
stats <- rnorm(n_genes)
names(stats) <- paste0("gene", seq_len(n_genes))

pathways <- list(
  pathway1 = paste0("gene", sample(n_genes, 50L)),
  pathway2 = paste0("gene", sample(n_genes, 100L)),
  pathway3 = paste0("gene", sample(n_genes, 150L))
)

res <- fgseaSimple(pathways, stats, nperm = 10000)
```

Here `fgseaSimple()` runs sequentially, but we can easily make it
run in parallel by piping to `futurize()`:

```r
library(futurize)

res <- fgseaSimple(pathways, stats, nperm = 10000) |> futurize()
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

The following **fgsea** functions are supported by `futurize()`:

* `fgsea()`
* `fgseaMultilevel()`
* `fgseaSimple()`
* `fgseaLabel()`
* `geseca()`
* `gesecaSimple()`
* `collapsePathwaysGeseca()`


[fgsea]: https://bioconductor.org/packages/fgsea/
[other parallel backends]: https://www.futureverse.org/backends.html
