# Parallelize 'rmgarch' functions

![The CRAN 'rmgarch'
package](../reference/figures/cran-rmgarch-logo.svg)+ ![The 'futurize'
hexlogo](../reference/figures/futurize-logo.png)= ![The 'future'
logo](../reference/figures/future-logo.png)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

``` r

library(futurize)
plan(multisession)
library(rmgarch)

fit <- dccfit(spec, data = returns) |> futurize()
```

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[rmgarch](https://cran.r-project.org/package=rmgarch)** functions such
as [`dccfit()`](https://rdrr.io/pkg/rmgarch/man/dccfit-methods.html),
[`dccforecast()`](https://rdrr.io/pkg/rmgarch/man/dccforecast-methods.html),
and
[`gogarchfit()`](https://rdrr.io/pkg/rmgarch/man/gogarchfit-methods.html).

The **[rmgarch](https://cran.r-project.org/package=rmgarch)** package
provides multivariate GARCH models including Dynamic Conditional
Correlation (DCC), Copula-GARCH, and GO-GARCH models. These models
involve fitting multiple univariate GARCH models as a first step, which
can be parallelized across series. The package accepts a `cluster`
argument for parallel evaluation via the **parallel** package.

By piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md),
you can leverage any future-based parallel backend for these
computations.

### Example: Fitting a DCC-GARCH model

The [`dccfit()`](https://rdrr.io/pkg/rmgarch/man/dccfit-methods.html)
function fits a Dynamic Conditional Correlation multivariate GARCH
model. Fitting the univariate GARCH models for each series can be
parallelized:

``` r

library(rmgarch)
library(rugarch)

set.seed(42)
n <- 300L
dat <- matrix(rnorm(n * 2L), ncol = 2L)
colnames(dat) <- c("x1", "x2")

## Create univariate GARCH(1,1) specs
uspec <- ugarchspec(
  mean.model = list(armaOrder = c(0, 0)),
  variance.model = list(garchOrder = c(1, 1))
)
mspec <- multispec(replicate(2, uspec))

## DCC(1,1) specification
spec <- dccspec(uspec = mspec, dccOrder = c(1, 1),
                distribution = "mvnorm")

## Sequential fit
fit <- dccfit(spec, data = dat)
```

Here [`dccfit()`](https://rdrr.io/pkg/rmgarch/man/dccfit-methods.html)
fits each univariate model sequentially. To run in parallel, pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

``` r

library(futurize)

fit <- dccfit(spec, data = dat) |> futurize()
```

This will distribute the univariate GARCH fits across the available
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

The following **rmgarch** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`betacokurt()`](https://rdrr.io/pkg/rmgarch/man/goGARCHfit-class.html)
- [`betacoskew()`](https://rdrr.io/pkg/rmgarch/man/goGARCHfit-class.html)
- [`cgarchfilter()`](https://rdrr.io/pkg/rmgarch/man/cgarchfilter-methods.html)
- [`cgarchfit()`](https://rdrr.io/pkg/rmgarch/man/cgarchfit-methods.html)
- [`cgarchsim()`](https://rdrr.io/pkg/rmgarch/man/cgarchsim-methods.html)
- [`convolution()`](https://rdrr.io/pkg/rmgarch/man/goGARCHfit-class.html)
- [`dccfilter()`](https://rdrr.io/pkg/rmgarch/man/dccfilter-methods.html)
- [`dccfit()`](https://rdrr.io/pkg/rmgarch/man/dccfit-methods.html)
- [`dccforecast()`](https://rdrr.io/pkg/rmgarch/man/dccforecast-methods.html)
- [`dccroll()`](https://rdrr.io/pkg/rmgarch/man/dccroll-methods.html)
- [`dccsim()`](https://rdrr.io/pkg/rmgarch/man/dccsim-methods.html)
- [`DCCtest()`](https://rdrr.io/pkg/rmgarch/man/DCCtest.html)
- [`fmoments()`](https://rdrr.io/pkg/rmgarch/man/fmoments-methods.html)
- [`fscenario()`](https://rdrr.io/pkg/rmgarch/man/fscenario-methods.html)
- [`gogarchfilter()`](https://rdrr.io/pkg/rmgarch/man/gogarchfilter-methods.html)
- [`gogarchfit()`](https://rdrr.io/pkg/rmgarch/man/gogarchfit-methods.html)
- [`gogarchforecast()`](https://rdrr.io/pkg/rmgarch/man/gogarchforecast-methods.html)
- [`gogarchroll()`](https://rdrr.io/pkg/rmgarch/man/gogarchroll-methods.html)
- [`gogarchsim()`](https://rdrr.io/pkg/rmgarch/man/gogarchsim-methods.html)
