<!--
%\VignetteIndexEntry{Parallelize 'Rsolnp' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{Rsolnp}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-Rsolnp-logo.svg" alt="The CRAN 'Rsolnp' package">
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
library(Rsolnp)

res <- gosolnp(
  fun = gofn,
  LB = c(-10, -10),
  UB = c(10, 10),
  n.restarts = 5,
  n.sim = 20000
) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
**[Rsolnp]** functions such as `gosolnp()`.

The **[Rsolnp]** package provides general nonlinear optimization using
the augmented Lagrange multiplier method. The `gosolnp()` function
performs global optimization by randomly generating starting parameters
and running the optimizer from each, making it an excellent candidate
for parallelization. The `startpars()` function similarly evaluates
many random starting points in parallel.


## Example: Global optimization with random starting parameters

The `gosolnp()` function performs global optimization by running the
solver from multiple random starting points. For example:

```r
library(Rsolnp)

gofn <- function(pars, ...) {
  x <- pars[1]
  y <- pars[2]
  (x - 2)^2 + (y - 3)^2
}

res <- gosolnp(
  fun = gofn,
  LB = c(-10, -10),
  UB = c(10, 10),
  n.restarts = 5,
  n.sim = 20000
)
```

Here `gosolnp()` evaluates sequentially. To run in parallel,
pipe to `futurize()`:

```r
library(futurize)
library(Rsolnp)

res <- gosolnp(
  fun = gofn,
  LB = c(-10, -10),
  UB = c(10, 10),
  n.restarts = 5,
  n.sim = 20000
) |> futurize()
```

This will distribute the optimization restarts across the available
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

The following **Rsolnp** functions are supported by `futurize()`:

* `gosolnp()`
* `startpars()`


[Rsolnp]: https://cran.r-project.org/package=Rsolnp
[other parallel backends]: https://www.futureverse.org/backends.html
