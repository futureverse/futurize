# Parallelize 'pls' functions

+ ![The 'futurize' hexlogo](../reference/figures/futurize-logo.webp)=
![The 'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`pls`](https://github.com/khliland/pls)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``yarn``)`\
`m`` ``<-`` `[`plsr`](https://khliland.github.io/pls/reference/mvr.html)`(``density`` ``~`` ``NIR``, ncomp ``=`` ``10``, data ``=`` ``yarn``, validation ``=`` ``"CV"``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[pls](https://cran.r-project.org/package=pls)** functions such as
[`mvr()`](https://khliland.github.io/pls/reference/mvr.html),
[`plsr()`](https://khliland.github.io/pls/reference/mvr.html),
[`pcr()`](https://khliland.github.io/pls/reference/mvr.html), and
[`crossval()`](https://khliland.github.io/pls/reference/crossval.html).

The **[pls](https://cran.r-project.org/package=pls)** package provides
Partial Least Squares Regression (PLSR) and Principal Component
Regression (PCR) methods. These methods often use cross-validation (CV)
to determine the number of components to use, which can be
computationally intensive and is an ideal candidate for parallelization.

### Example: PLS Regression with Cross-Validation

The [`plsr()`](https://khliland.github.io/pls/reference/mvr.html)
function is used to perform PLS regression. When `validation = "CV"` is
specified, it performs cross-validation.

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`pls`](https://github.com/khliland/pls)`)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``yarn``)`\
\
`## Sequential evaluation`\
`m`` ``<-`` `[`plsr`](https://khliland.github.io/pls/reference/mvr.html)`(``density`` ``~`` ``NIR``, ncomp ``=`` ``10``, data ``=`` ``yarn``, validation ``=`` ``"CV"``)`

To make it evaluate in parallel, simply pipe the call to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`pls`](https://github.com/khliland/pls)`)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``yarn``)`\
\
`## Parallel evaluation`\
`m`` ``<-`` `[`plsr`](https://khliland.github.io/pls/reference/mvr.html)`(``density`` ``~`` ``NIR``, ncomp ``=`` ``10``, data ``=`` ``yarn``, validation ``=`` ``"CV"``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will automatically use the parallel backend set by
[`plan()`](https://future.futureverse.org/reference/plan.html), e.g.

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`

### Example: Stand-alone Cross-Validation

The
[`crossval()`](https://khliland.github.io/pls/reference/crossval.html)
function can be used to perform cross-validation on an already fitted
model:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`pls`](https://github.com/khliland/pls)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``yarn``)`\
`m1`` ``<-`` `[`plsr`](https://khliland.github.io/pls/reference/mvr.html)`(``density`` ``~`` ``NIR``, ncomp ``=`` ``10``, data ``=`` ``yarn``)`\
\
`## Parallel cross-validation`\
`m_cv`` ``<-`` `[`crossval`](https://khliland.github.io/pls/reference/crossval.html)`(``m1``, segments ``=`` ``10``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Supported Functions

The following **pls** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`mvr()`](https://khliland.github.io/pls/reference/mvr.html)
- [`plsr()`](https://khliland.github.io/pls/reference/mvr.html)
- [`pcr()`](https://khliland.github.io/pls/reference/mvr.html)
- [`cppls()`](https://khliland.github.io/pls/reference/mvr.html)
- [`crossval()`](https://khliland.github.io/pls/reference/crossval.html)
  with `seed = TRUE` as the default

## Without futurize: Manual ‘pls.options’ setup

For comparison, here is what it takes to parallelize `pls` functions
using the **parallel** package directly, without **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`pls`](https://github.com/khliland/pls)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
\
`## Set up a cluster`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
\
`## Configure pls to use the cluster`\
`old_opts`` ``<-`` `[`pls.options`](https://khliland.github.io/pls/reference/pls.options.html)`(``parallel ``=`` ``cl``)`\
\
`## Run regression with cross-validation`\
[`data`](https://rdrr.io/r/utils/data.html)`(``yarn``)`\
`m`` ``<-`` `[`plsr`](https://khliland.github.io/pls/reference/mvr.html)`(``density`` ``~`` ``NIR``, ncomp ``=`` ``10``, data ``=`` ``yarn``, validation ``=`` ``"CV"``)`\
\
`## Restore original options and stop the cluster`\
[`pls.options`](https://khliland.github.io/pls/reference/pls.options.html)`(``old_opts``)`\
[`stopCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``cl``)`

This requires you to manually manage the cluster lifecycle and the
global
[`pls.options()`](https://khliland.github.io/pls/reference/pls.options.html).
With **futurize**, the cluster setup and option management are handled
automatically and localized to the function call.
