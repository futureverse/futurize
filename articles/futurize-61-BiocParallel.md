# Parallelize 'BiocParallel' functions

![The Bioconductor 'BiocParallel'
image](../reference/figures/bioconductor-BiocParallel-logo.webp)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.webp)= ![The
'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

You can use **futurize** to make
**[BiocParallel](https://bioconductor.org/packages/BiocParallel/)**
functions parallelize via any of the \[parallel backends\] supported by
Futureverse, e.g.

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``BiocParallel``)`\
\
`slow_fcn`` ``<-`` ``function``(``x``)`` ``{`\
`  `[`message`](https://rdrr.io/r/base/message.html)`(``"x = "``, ``x``)`\
`  `[`Sys.sleep`](https://rdrr.io/r/base/Sys.sleep.html)`(``0.1``)``  ``# emulate work`\
`  ``x``^``2`\
`}`\
\
`xs`` ``<-`` ``1``:``10`\
`ys`` ``<-`` ``bplapply``(``xs``, ``slow_fcn``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
functions such as `bplapply()`, `bpmapply()`, and `bpvec()` in the
**BiocParallel** package. For example, consider the `bplapply()`
function. It works like base-R
[`lapply()`](https://rdrr.io/r/base/lapply.html), but uses the
**BiocParallel** framework to process the tasks concurrently. It is
commonly used something like:

\
[`library`](https://rdrr.io/r/base/library.html)`(``BiocParallel``)`\
`xs`` ``<-`` ``1``:``1000`\
`ys`` ``<-`` ``bplapply``(``xs``, ``slow_fcn``)`

The parallel backend is controlled by the `BiocParallel::register()`,
similar to how we use
[`future::plan()`](https://future.futureverse.org/reference/plan.html)
in Futureverse. We can use the **futurize** package to tell
**BiocParallel** to hand over the orchestration of parallel tasks to
Futureverse. All we need to do is to pass the expression to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
as in:

\
[`library`](https://rdrr.io/r/base/library.html)`(``BiocParallel``)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`` ``## parallelize on local machine`\
\
`xs`` ``<-`` ``1``:``1000`\
`ys`` ``<-`` ``bplapply``(``xs``, ``slow_fcn``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`#> x = 1`\
`#> x = 2`\
`#> x = 3`\
`#> ...`\
`#> x = 10`

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

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``future.mirai``::`[`mirai_multisession`](https://future.mirai.futureverse.org/reference/mirai_multisession.html)`)`

and

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``future.batchtools``::`[`batchtools_slurm`](https://future.batchtools.futureverse.org/reference/batchtools_slurm.html)`)`

## Supported Functions

The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function supports parallelization of all **BiocParallel** functions that
take argument `BPPARAM`. Specifically,

- `bplapply()` and `.bplapply_impl()`
- `bpmapply()` and `.bpmapply_impl()`
- `bpvec()`
- `bpaggregate()`

The following functions are currently not supported:

- `bpiterate()` - technically supported, but because this function does
  not support using `DoparParam()` with it, it effectively does not work
  with
  [`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
- `bpvectorize()`
- `register()`

## Bioconductor packages using BiocParallel

Most Bioconductor packages that support parallelization do so via
**BiocParallel** internally. These packages typically expose a `BPPARAM`
argument in their functions, which controls the parallel backend used.
For example, `DESeq2::DESeq()` has a `BPPARAM` argument that defaults to
`BiocParallel::bpparam()`, which corresponds to the currently registered
**BiocParallel** backend. This means that, in order to parallelize such
a function, one can call `BiocParallel::register()` to set a parallel
backend, and then the function will use it automatically.

However, not all packages default to `bpparam()`. For example,
`sva::ComBat()` defaults to `bpparam("SerialParam")`, which means it
always runs sequentially unless you explicitly pass a parallel `BPPARAM`
argument. Because of this, one cannot count on `bpparam()` being the
default everywhere - some functions require an explicit `BPPARAM` to
parallelize. With **futurize**, this is handled automatically:
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
injects the appropriate `BPPARAM` argument regardless of what the
default is, so that the parallel execution is performed via the
Futureverse, where the parallel backend is controlled by
[`future::plan()`](https://future.futureverse.org/reference/plan.html).

## Progress Reporting via progressify

For progress reporting, please see the
**[progressify](https://progressify.futureverse.org/)** package. It is
specially designed to work with the Futureverse ecosystem and provide
progress updates from parallelized computations in a near-live fashion.
See the
[`vignette("futurize-11-apply", package = "futurize")`](https://futurize.futureverse.org/articles/futurize-11-apply.md)
for more details and an example.
