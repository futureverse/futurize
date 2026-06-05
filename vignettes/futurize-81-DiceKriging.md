<!--
%\VignetteIndexEntry{Parallelize 'DiceKriging' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{DiceKriging}
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
library(DiceKriging)

design <- expand.grid(x1 = seq(0, 1, length = 15), x2 = seq(0, 1, length = 15))
y <- apply(design, 1, function(x) x[1]^2 + x[2]^2)
m <- km(~., design = design, response = data.frame(y = y),
        multistart = 20) |> futurize()
```


# Introduction

This vignette demonstrates how to use **futurize** to parallelize
**[DiceKriging]** functions, specifically `km()`.
When fitting a kriging model via `km()`, the parameters of the
covariance function are estimated by maximum likelihood or
cross-validation. The optimization can be started from multiple
points (to avoid local optima), which can be done in parallel.


## Example: kriging model with multi-start optimization

Fitting a kriging model with a single starting point:

```r
library(DiceKriging)

design <- expand.grid(x1 = seq(0, 1, length = 15), x2 = seq(0, 1, length = 15))
y <- apply(design, MARGIN = 1, FUN = function(x) x[1]^2 + x[2]^2)
m <- km(~., design = design, response = data.frame(y = y))
```

To run multiple optimizer starts in parallel, set `multistart > 1`
and pipe to `futurize()`:

```r
library(futurize)
library(DiceKriging)

design <- expand.grid(x1 = seq(0, 1, length = 15), x2 = seq(0, 1, length = 15))
y <- apply(design, MARGIN = 1, FUN = function(x) x[1]^2 + x[2]^2)
m <- km(~., design = design, response = data.frame(y = y),
        multistart = 20) |> futurize()
```

This distributes the multi-start runs across the available parallel
workers, given that we have set up a parallel plan, e.g.

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

The following **DiceKriging** function is supported by `futurize()`:

* `km()`


[DiceKriging]: https://cran.r-project.org/package=DiceKriging
[other parallel backends]: https://www.futureverse.org/backends.html
