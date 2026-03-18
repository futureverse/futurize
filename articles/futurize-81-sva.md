# Parallelize 'sva' functions

![The 'sva' logo](../reference/figures/sva-logo.webp)+ ![The 'futurize'
hexlogo](../reference/figures/futurize-logo.webp)= ![The 'future'
logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(sva)

adjusted <- ComBat(dat = dat, batch = batch) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize the
**[sva](https://bioconductor.org/packages/sva/)** functions.

The **[sva](https://bioconductor.org/packages/sva/)** Bioconductor
package provides functions for removing batch effects and other unwanted
variation in high-throughput experiments. The
[`ComBat()`](https://rdrr.io/pkg/sva/man/ComBat.html) function is a
widely used method for batch effect correction using an empirical Bayes
framework. It supports parallelization via BiocParallel’s BPPARAM
argument.

### Example: Running ComBat() in parallel

The [`ComBat()`](https://rdrr.io/pkg/sva/man/ComBat.html) function
adjusts for known batch effects in microarray or RNA-seq data:

``` r

library(sva)

# Create example data with batch effect
set.seed(42)
n_genes <- 200L
n_samples <- 40L
dat <- matrix(rnorm(n_genes * n_samples), nrow = n_genes, ncol = n_samples)
rownames(dat) <- paste0("gene", seq_len(n_genes))
colnames(dat) <- paste0("sample", seq_len(n_samples))

batch <- rep(c(1, 2), each = n_samples / 2L)
dat[, batch == 2] <- dat[, batch == 2] + 2

adjusted <- ComBat(dat = dat, batch = batch)
```

Here [`ComBat()`](https://rdrr.io/pkg/sva/man/ComBat.html) runs
sequentially, but we can easily make it run in parallel by piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)

adjusted <- ComBat(dat = dat, batch = batch) |> futurize()
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

### Using ComBat() with a model matrix

You can also include a model matrix for biological covariates of
interest, which will be protected during batch correction:

``` r

mod <- model.matrix(~ group)
adjusted <- ComBat(dat = dat, batch = batch, mod = mod) |> futurize()
```

## Supported Functions

The following **sva** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`ComBat()`](https://rdrr.io/pkg/sva/man/ComBat.html)
- [`read.degradation.matrix()`](https://rdrr.io/pkg/sva/man/read.degradation.matrix.html)
