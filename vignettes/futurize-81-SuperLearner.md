<!--
%\VignetteIndexEntry{Parallelize 'SuperLearner' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{SuperLearner}
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
library(SuperLearner)

res <- CV.SuperLearner(Y = Y, X = X, SL.library = SL.library) |> futurize()
```

# Introduction

This vignette demonstrates how to use this approach to parallelize
**[SuperLearner]** functions such as `CV.SuperLearner()`.

The **[SuperLearner]** package provides a framework for ensemble
machine learning in R. The algorithm utilizes V-fold cross-validation
to combine multiple prediction algorithms into a single ensemble
predictor. Since cross-validation involves training many models
independently, it is a perfect candidate for parallelization.

## Example: Cross-Validated Super Learner

The `CV.SuperLearner()` function evaluates the cross-validated risk of
the Super Learner ensemble.  For example:

```r
library(SuperLearner)

n <- 100
p <- 5
X <- as.data.frame(matrix(rnorm(n * p), n, p))
Y <- X[, 1] + X[, 2] + rnorm(n)
SL.library <- c("SL.glm", "SL.mean")

res <- CV.SuperLearner(Y = Y, X = X, V = 10, SL.library = SL.library)
```

Here `CV.SuperLearner()` evaluates sequentially. To run in parallel,
pipe to `futurize()`:
    
```r
library(futurize)
library(SuperLearner)

res <- CV.SuperLearner(Y = Y, X = X, V = 10, SL.library = SL.library) |> futurize()
```

This will distribute the cross-validation fold evaluations across the
available parallel workers, given that we have set up parallel
workers, e.g.

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and works on all operating systems. There are [other parallel
backends] to choose from, including alternatives to parallelize
locally as well as distributed across remote machines, e.g.

```r
plan(future.mirai::mirai_multisession)
```

and

```r
plan(future.batchtools::batchtools_slurm)
```

# Supported Functions

The following **SuperLearner** functions are supported by `futurize()`:

* `CV.SuperLearner()` with `seed = TRUE` as the default

[SuperLearner]: https://cran.r-project.org/package=SuperLearner
[other parallel backends]: https://www.futureverse.org/backends.html
