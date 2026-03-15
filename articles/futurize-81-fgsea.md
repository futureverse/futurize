# Parallelize 'fgsea' functions

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
library(fgsea)

res <- fgsea(pathways, stats) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[fgsea](https://bioconductor.org/packages/fgsea/)** functions.

The **[fgsea](https://bioconductor.org/packages/fgsea/)** Bioconductor
package implements fast preranked gene set enrichment analysis (GSEA).
The main functions
[`fgsea()`](https://rdrr.io/pkg/fgsea/man/fgsea.html),
[`fgseaMultilevel()`](https://rdrr.io/pkg/fgsea/man/fgseaMultilevel.html),
and [`fgseaSimple()`](https://rdrr.io/pkg/fgsea/man/fgseaSimple.html)
perform permutation-based enrichment testing, which can be parallelized
across gene sets.

### Example: Running fgseaSimple() in parallel

The [`fgseaSimple()`](https://rdrr.io/pkg/fgsea/man/fgseaSimple.html)
function performs permutation-based gene set enrichment analysis:

``` r

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

Here [`fgseaSimple()`](https://rdrr.io/pkg/fgsea/man/fgseaSimple.html)
runs sequentially, but we can easily make it run in parallel by piping
to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)

res <- fgseaSimple(pathways, stats, nperm = 10000) |> futurize()
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

The following **fgsea** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`fgsea()`](https://rdrr.io/pkg/fgsea/man/fgsea.html)
- [`fgseaMultilevel()`](https://rdrr.io/pkg/fgsea/man/fgseaMultilevel.html)
- [`fgseaSimple()`](https://rdrr.io/pkg/fgsea/man/fgseaSimple.html)
- [`fgseaLabel()`](https://rdrr.io/pkg/fgsea/man/fgseaLabel.html)
- [`geseca()`](https://rdrr.io/pkg/fgsea/man/geseca.html)
- [`gesecaSimple()`](https://rdrr.io/pkg/fgsea/man/gesecaSimple.html)
- `collapsePathwaysGeseca()`
