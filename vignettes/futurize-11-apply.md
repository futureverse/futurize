<!--
%\VignetteIndexEntry{Parallelize base-R apply functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/r-base-logo.svg" alt="The base-R logo">
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

slow_fcn <- function(x) {
  Sys.sleep(0.1)  # emulate work
  x^2
}

xs <- 1:1000
ys <- lapply(xs, slow_fcn) |> futurize()
```


# Introduction

This vignette demonstrates how to use this approach to parallelize
functions such as `lapply()`, `tapply()`, `apply()`, and `replicate()`
in the **base** package, and `kernapply()` in the **stats**
package. For example, consider the base R `lapply()` function, which
is commonly used to apply a function to the elements of a vector or a
list, as in:

```r
xs <- 1:1000
ys <- lapply(xs, slow_fcn)
```

Here `lapply()` evaluates sequentially, but we can easily make it
evaluate in parallel, by using:

```r
library(futurize)
ys <- lapply(xs, slow_fcn) |> futurize()
```

This will distribute the calculations across the available parallel
workers, given that we have set parallel workers, e.g.

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and it works on all operating systems. There are [other
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


## Kernel smoothing

```r
library(futurize)
plan(multisession)

library(stats)

xs <- datasets::EuStockMarkets
k50 <- kernel("daniell", 50)
xs_smooth <- kernapply(xs, k = k50) |> futurize()
```



# Supported Functions

The `futurize()` function supports parallelization of the common base
R functions. The following  **base** package functions are supported:

 * `lapply()`, `vapply()`, `sapply()`, `tapply()`
 * `mapply()`, `.mapply()`, `Map()`
 * `eapply()`
 * `apply()`
 * `replicate()` with `seed = TRUE` as the default
 * `by()`
 * `Filter()`

The `rapply()` function is not supported by `futurize()`.

The following **stats** package function is also supported:

 * `kernapply()`


# Known issues

The **[BiocGenerics]** package defines generic functions `lapply()`,
`sapply()`, `mapply()`, and `tapply()`. These S4 generic functions
overrides the non-generic, counterpart functions in the **base**
package, which are only used as a fallback if there is no matching
method. For example, in a vanilla R session we have that both of the
following calls are identical:

```r
y_0 <- lapply(1:3, sqrt)
y_1 <- base::lapply(1:3, sqrt)
```

However, if we attach the **BiocGenerics** package, we have that the
following two calls are identical:

```r
library(BiocGenerics)
y_2 <- lapply(1:3, sqrt)
y_3 <- BiocGenerics::lapply(1:3, sqrt)
```

The reason is that `lapply()` here is no longer `base::lapply()`, but
the one defined by **BiocGenerics**, which masks the one on
**base**. We can see this with:

```r
find("lapply")
#> [1] "package:BiocGenerics" "package:base" 
```

This matters in the context of **futurize**. In a vanilla R session,

```r
y <- lapply(1:3, sqrt) |> futurize()
```

is identical to

```r
y <- base::lapply(1:3, sqrt) |> futurize()
```

However, with **BiocGenerics** attached, it is instead identical to:

```r
y <- BiocGenerics::lapply(1:3, sqrt) |> futurize()
```

which results in:

```
Error in transpilers_for_package(type = type, package = ns_name, action = "make",  : 
  There are no factory functions for creating 'futurize::add-on' transpilers for package 'BiocGenerics'
```

The solution is to specify that it is the **base** version we wish to futurize, i.e.

```r
y <- base::lapply(1:3, sqrt) |> futurize()
```


[other parallel backends]: https://www.futureverse.org/backends.html
[BiocGenerics]: https://www.bioconductor.org/packages/BiocGenerics/
