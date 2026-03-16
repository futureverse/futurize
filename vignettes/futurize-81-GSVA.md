<!--
%\VignetteIndexEntry{Parallelize 'GSVA' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{GSVA}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/GSVA-logo.png" alt="The 'GSVA' logo">
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
library(GSVA)

param <- gsvaParam(expr, geneSets)
es <- gsva(param) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
the **[GSVA]** functions.

The **[GSVA]** Bioconductor package implements gene set variation
analysis, a non-parametric, unsupervised method for estimating
variation of gene set enrichment through the samples of an expression
data set. The main function `gsva()` computes enrichment scores for
each gene set and sample, which can be parallelized across gene sets.


## Example: Running gsva() in parallel

The `gsva()` function computes gene set enrichment scores using
different methods depending on the parameter object passed to it:

```r
library(GSVA)

# Create example data
set.seed(42)
n_genes <- 200L
n_samples <- 120L
expr <- matrix(rnorm(n_genes * n_samples), nrow = n_genes, ncol = n_samples)
rownames(expr) <- paste0("gene", seq_len(n_genes))
colnames(expr) <- paste0("sample", seq_len(n_samples))

geneSets <- list(
  geneSet1 = paste0("gene", sample(n_genes, 30L)),
  geneSet2 = paste0("gene", sample(n_genes, 50L)),
  geneSet3 = paste0("gene", sample(n_genes, 40L))
)

param <- gsvaParam(expr, geneSets)
es <- gsva(param)
```

Here `gsva()` runs sequentially, but we can easily make it run in
parallel by piping to `futurize()`:

```r
library(futurize)

es <- gsva(param) |> futurize()
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


## Other enrichment methods

GSVA supports multiple enrichment methods through different parameter
objects. All of them can be parallelized with `futurize()`:

```r
## ssGSEA method
es <- gsva(ssgseaParam(expr, geneSets)) |> futurize()

## PLAGE method
es <- gsva(plageParam(expr, geneSets)) |> futurize()

## Combined z-score method
es <- gsva(zscoreParam(expr, geneSets)) |> futurize()
```


# Supported Functions

The following **GSVA** functions are supported by `futurize()`:

* `gsva()` - requires **GSVA** (>= 2.4.2 or >= 2.5.7)
* `gsvaRanks()`
* `gsvaScores()`
* `spatCor()`


[GSVA]: https://bioconductor.org/packages/GSVA/
[other parallel backends]: https://www.futureverse.org/backends.html
