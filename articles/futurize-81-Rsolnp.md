# Parallelize 'Rsolnp' functions

![The CRAN 'Rsolnp' package](../reference/figures/cran-Rsolnp-logo.svg)+
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
library(Rsolnp)

res <- gosolnp(
  fun = gofn,
  LB = c(-10, -10),
  UB = c(10, 10),
  n.restarts = 5,
  n.sim = 20000
) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[Rsolnp](https://cran.r-project.org/package=Rsolnp)** functions such
as [`gosolnp()`](https://rdrr.io/pkg/Rsolnp/man/gosolnp.html).

The **[Rsolnp](https://cran.r-project.org/package=Rsolnp)** package
provides general nonlinear optimization using the augmented Lagrange
multiplier method. The
[`gosolnp()`](https://rdrr.io/pkg/Rsolnp/man/gosolnp.html) function
performs global optimization by randomly generating starting parameters
and running the optimizer from each, making it an excellent candidate
for parallelization. The
[`startpars()`](https://rdrr.io/pkg/Rsolnp/man/startpars.html) function
similarly evaluates many random starting points in parallel.

### Example: Global optimization with random starting parameters

The [`gosolnp()`](https://rdrr.io/pkg/Rsolnp/man/gosolnp.html) function
performs global optimization by running the solver from multiple random
starting points. For example:

``` r

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

Here [`gosolnp()`](https://rdrr.io/pkg/Rsolnp/man/gosolnp.html)
evaluates sequentially. To run in parallel, pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

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

The following **Rsolnp** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`gosolnp()`](https://rdrr.io/pkg/Rsolnp/man/gosolnp.html)
- [`startpars()`](https://rdrr.io/pkg/Rsolnp/man/startpars.html)
