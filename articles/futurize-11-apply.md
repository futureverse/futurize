# Parallelize base-R apply functions

![The base-R logo](../reference/figures/r-base-logo.svg)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.png)= ![The
'future' logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)

slow_fcn <- function(x) {
  message("x = ", x)
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:10
ys <- lapply(xs, slow_fcn) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
functions such as
[`lapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html),
[`tapply()`](https://rdrr.io/pkg/BiocGenerics/man/tapply.html),
[`apply()`](https://rdrr.io/r/base/apply.html), and
[`replicate()`](https://rdrr.io/r/base/lapply.html) in the **base**
package, and [`kernapply()`](https://rdrr.io/r/stats/kernapply.html) in
the **stats** package. For example, consider the base R
[`lapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html) function,
which is commonly used to apply a function to the elements of a vector
or a list, as in:

``` r

xs <- 1:1000
ys <- lapply(xs, slow_fcn)
```

Here [`lapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html)
evaluates sequentially, but we can easily make it evaluate in parallel,
by using:

``` r

library(futurize)
plan(multisession) ## parallelize on local machine

ys <- lapply(xs, slow_fcn) |> futurize()
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

### Kernel smoothing

``` r

library(futurize)
plan(multisession)

library(stats)

xs <- datasets::EuStockMarkets
k50 <- kernel("daniell", 50)
xs_smooth <- kernapply(xs, k = k50) |> futurize()
```

## Supported Functions

The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function supports parallelization of the common base R functions. The
following **base** package functions are supported:

- [`lapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html),
  [`vapply()`](https://rdrr.io/r/base/lapply.html),
  [`sapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html),
  [`tapply()`](https://rdrr.io/pkg/BiocGenerics/man/tapply.html)
- [`mapply()`](https://rdrr.io/pkg/BiocGenerics/man/mapply.html),
  [`.mapply()`](https://rdrr.io/r/base/mapply.html),
  [`Map()`](https://rdrr.io/pkg/BiocGenerics/man/funprog.html)
- [`eapply()`](https://rdrr.io/r/base/eapply.html)
- [`apply()`](https://rdrr.io/r/base/apply.html)
- [`replicate()`](https://rdrr.io/r/base/lapply.html) with `seed = TRUE`
  as the default
- [`by()`](https://rdrr.io/r/base/by.html)
- [`Filter()`](https://rdrr.io/pkg/BiocGenerics/man/funprog.html)

The [`rapply()`](https://rdrr.io/r/base/rapply.html) function is not
supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md).

The following **stats** package function is also supported:

- [`kernapply()`](https://rdrr.io/r/stats/kernapply.html)

## Progress Reporting via progressr

The **[progressr](https://cran.r-project.org/package=progressr)**
package is specially designed to work with the Futureverse ecosystem.
With **progressr**, progress can be reported from parallelized
computations in a near-live fashion. Progress updates are propagated
from the workers back to the main process, where they are relayed to
provide feedback during long-running computations. This works because
progress is signaled as R conditions that the **future** package and
most future backends relay instantly.

For example:

``` r

library(futurize)
plan(multisession)
library(progressr)
handlers(global = TRUE)

xs <- 1:100
ys <- local({
  p <- progressor(along = xs)
  lapply(xs, function(x) {
    p()
    slow_fcn(x)
  })
}) |> futurize()
```

Note also how
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
unwraps the expression - it descends through
[`local()`](https://rdrr.io/r/base/eval.html) and
[`{ }`](https://rdrr.io/r/base/Paren.html) to identify the
[`lapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html) call to
be futurized. Using the default progress handler, the above output and
progress reporting will appear as:

``` plain
x = 1
x = 2
...
x = 20
  |=====                    |  20%
```

## Known issues

The
**[BiocGenerics](https://www.bioconductor.org/packages/BiocGenerics/)**
package defines generic functions
[`lapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html),
[`sapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html),
[`mapply()`](https://rdrr.io/pkg/BiocGenerics/man/mapply.html), and
[`tapply()`](https://rdrr.io/pkg/BiocGenerics/man/tapply.html). These S4
generic functions override the non-generic, counterpart functions in the
**base** package, which are only used as a fallback if there is no
matching method. For example, in a vanilla R session we have that both
of the following calls are identical:

``` r

y_0 <- lapply(1:3, sqrt)
y_1 <- base::lapply(1:3, sqrt)
```

However, if we attach the **BiocGenerics** package, we have that the
following two calls are identical:

``` r

library(BiocGenerics)
y_2 <- lapply(1:3, sqrt)
y_3 <- BiocGenerics::lapply(1:3, sqrt)
```

The reason is that
[`lapply()`](https://rdrr.io/pkg/BiocGenerics/man/lapply.html) here is
no longer [`base::lapply()`](https://rdrr.io/r/base/lapply.html), but
the one defined by **BiocGenerics**, which masks the one in **base**. We
can see this with:

``` r

find("lapply")
#> [1] "package:BiocGenerics" "package:base" 
```

This matters in the context of **futurize**. In a vanilla R session,

``` r

y <- lapply(1:3, sqrt) |> futurize()
```

is identical to

``` r

y <- base::lapply(1:3, sqrt) |> futurize()
```

However, with **BiocGenerics** attached, it is instead identical to:

``` r

y <- BiocGenerics::lapply(1:3, sqrt) |> futurize()
```

which results in:

    Error in transpilers_for_package(type = type, package = ns_name, action = "make",  : 
      There are no factory functions for creating 'futurize::add-on' transpilers for package 'BiocGenerics'

The solution is to specify that it is the **base** version we wish to
futurize, i.e.

``` r

y <- base::lapply(1:3, sqrt) |> futurize()
```
