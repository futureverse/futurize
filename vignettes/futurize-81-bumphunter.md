<!--
%\VignetteIndexEntry{Parallelize 'bumphunter' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Bioconductor}
%\VignetteKeyword{bumphunter}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
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
library(bumphunter)

bumps <- bumphunter(mat, design, chr = chr, pos = pos, cutoff = 0.5, B = 100) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
the **[bumphunter]** functions.

The **[bumphunter]** Bioconductor package provides tools for finding
"bumps", that is, genomic regions where a covariate of interest is
associated with the measured signal, e.g. differentially methylated
regions (DMRs) in DNA methylation data. The statistical significance
of the bumps is assessed using permutations or bootstrap resampling,
which can be computationally expensive. Internally, **bumphunter**
parallelizes via `foreach()` using whatever foreach backend is
registered.


## Example: Finding bumps in parallel

The `bumphunter()` function identifies candidate regions and assesses
their significance by comparing them to a null distribution generated
by `B` permutations:

```r
library(bumphunter)

# Create example data with a bump on chr1
pos <- list(
  pos1 = seq(from =    1L, to = 1000L, by = 35L),
  pos2 = seq(from = 2001L, to = 3000L, by = 35L),
  pos3 = seq(from =    1L, to = 1000L, by = 50L)
)
chr <- rep(paste0("chr", c(1, 1, 2)), times = lengths(pos))
pos <- unlist(pos, use.names = FALSE)
set.seed(42)
mat <- matrix(rnorm(length(pos) * 10L), nrow = length(pos), ncol = 10L)
mat[1:10, 6:10] <- mat[1:10, 6:10] + 2
design <- cbind(1, rep(0:1, each = 5L))

bumps <- bumphunter(mat, design, chr = chr, pos = pos, cutoff = 0.5, B = 100)
```

Here `bumphunter()` runs sequentially, but we can easily make it run
in parallel by piping to `futurize()`:

```r
library(futurize)

bumps <- bumphunter(mat, design, chr = chr, pos = pos, cutoff = 0.5, B = 100) |> futurize()
```

This will distribute the permutations across the available parallel
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


## Smoothing

When using `smooth = TRUE`, the smoothing of the estimates is also
parallelized:

```r
bumps <- bumphunter(mat, design, chr = chr, pos = pos, cutoff = 0.5, B = 100,
                    smooth = TRUE) |> futurize()
```


## Parallel random number generation

The **bumphunter** package uses **[doRNG]** to generate
statistically sound random numbers in parallel. Because of this, you
do not have to specify `futurize(rng = TRUE)`. The results are
reproducible given `set.seed()`, regardless of the number of parallel
workers, and they are identical to those of a sequential run.


# Supported Functions

The following **bumphunter** functions are supported by `futurize()`:

* `bumphunter()`
* `bumphunterEngine()`
* `smoother()`


[bumphunter]: https://bioconductor.org/packages/bumphunter/
[doRNG]: https://cran.r-project.org/package=doRNG
[other parallel backends]: https://www.futureverse.org/backends.html
