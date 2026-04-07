# Parallelize 'plyr' functions

![The 'plyr' image](../reference/figures/cran-plyr-logo.webp)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.webp)= ![The
'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(plyr)
library(futurize)
plan(multisession)

slow_fcn <- function(x) {
  message("x = ", x)
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:10
ys <- llply(xs, slow_fcn) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[plyr](https://cran.r-project.org/package=plyr)** functions such as
[`llply()`](https://rdrr.io/pkg/plyr/man/llply.html),
[`maply()`](https://rdrr.io/pkg/plyr/man/maply.html), and
[`ddply()`](https://rdrr.io/pkg/plyr/man/ddply.html).

The **plyr** [`llply()`](https://rdrr.io/pkg/plyr/man/llply.html)
function is commonly used to apply a function to the elements of a list
and return a list. For example,

``` r

library(plyr)
xs <- 1:1000
ys <- llply(xs, slow_fcn)
```

Here [`llply()`](https://rdrr.io/pkg/plyr/man/llply.html) evaluates
sequentially, but we can easily make it evaluate in parallel, by using:

``` r

library(plyr)

library(futurize)
plan(multisession) ## parallelize on local machine

xs <- 1:1000
ys <- xs |> llply(slow_fcn) |> futurize()
#> x = 1
#> x = 2
#> x = 3
#> ...
#> x = 10
```

Note how messages produced on parallel workers are relayed as-is back to
the main R session as they complete. Not only messages, but also
warnings and other types of conditions are relayed back as-is. Likewise,
standard output produced by [`cat()`](https://rdrr.io/r/base/cat.html),
[`print()`](https://rdrr.io/r/base/print.html),
[`str()`](https://rdrr.io/r/utils/str.html), and so on is relayed in the
same way. This is a unique feature of Futureverse - other parallel
frameworks in R, such as **parallel**, **foreach** with **doParallel**,
and **BiocParallel**, silently drop standard output, messages, and
warnings produced on workers. With **futurize**, your code behaves the
same whether it runs sequentially or in parallel: nothing is lost in
translation.

The built-in `multisession` backend parallelizes on your local computer
and it works on all operating systems. There are [other parallel
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

Another example is:

``` r

library(plyr)
library(futurize)
plan(future.mirai::mirai_multisession)

ys <- llply(baseball, summary) |> futurize()
```

## Supported Functions

The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function supports parallelization of the following **plyr** functions:

- [`a_ply()`](https://rdrr.io/pkg/plyr/man/a_ply.html),
  [`aaply()`](https://rdrr.io/pkg/plyr/man/aaply.html),
  [`adply()`](https://rdrr.io/pkg/plyr/man/adply.html),
  [`alply()`](https://rdrr.io/pkg/plyr/man/alply.html)
- [`d_ply()`](https://rdrr.io/pkg/plyr/man/d_ply.html),
  [`daply()`](https://rdrr.io/pkg/plyr/man/daply.html),
  [`ddply()`](https://rdrr.io/pkg/plyr/man/ddply.html),
  [`dlply()`](https://rdrr.io/pkg/plyr/man/dlply.html)
- [`l_ply()`](https://rdrr.io/pkg/plyr/man/l_ply.html),
  [`laply()`](https://rdrr.io/pkg/plyr/man/laply.html),
  [`ldply()`](https://rdrr.io/pkg/plyr/man/ldply.html),
  [`llply()`](https://rdrr.io/pkg/plyr/man/llply.html)
- [`m_ply()`](https://rdrr.io/pkg/plyr/man/m_ply.html),
  [`maply()`](https://rdrr.io/pkg/plyr/man/maply.html),
  [`mdply()`](https://rdrr.io/pkg/plyr/man/mdply.html),
  [`mlply()`](https://rdrr.io/pkg/plyr/man/mlply.html)

## Progress Reporting via progressr

For progress reporting, please see the
**[progressr](https://progressr.futureverse.org/)** package. It is
specially designed to work with the Futureverse ecosystem and provide
progress updates from parallelized computations in a near-live fashion.
See the
[`vignette("futurize-11-apply", package = "futurize")`](https://futurize.futureverse.org/articles/futurize-11-apply.md)
for more details and an example.
