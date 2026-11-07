# Parallelize 'boot' functions

![The 'boot' image](../reference/figures/cran-boot-logo.webp)+ ![The
'futurize' hexlogo](../reference/figures/futurize-logo.webp)= ![The
'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``boot``)`\
\
`ratio`` ``<-`` ``function``(``pop``, ``w``)`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``w`` ``*`` ``pop``$``x``)`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``w`` ``*`` ``pop``$``u``)`\
`b`` ``<-`` `[`boot`](https://rdrr.io/pkg/boot/man/boot.html)`(``bigcity``, statistic ``=`` ``ratio``, R ``=`` ``999``, stype ``=`` ``"w"``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[boot](https://cran.r-project.org/package=boot)** functions such as
[`boot()`](https://rdrr.io/pkg/boot/man/boot.html),
[`censboot()`](https://rdrr.io/pkg/boot/man/censboot.html), and
[`tsboot()`](https://rdrr.io/pkg/boot/man/tsboot.html).

The **[boot](https://cran.r-project.org/package=boot)** package is one
of the “recommended” R packages, meaning it is officially endorsed by
the R Core Team, well maintained, and installed by default with R. The
package generates bootstrap samples and provides statistical methods
around them. Given the resampling nature of bootstrapping, the
algorithms are excellent candidates for parallelization.

### Example: Bootstrap sampling

The core function [`boot()`](https://rdrr.io/pkg/boot/man/boot.html)
produces bootstrap samples of a statistic applied to data. For example,
consider the `bigcity` dataset, which contains populations of 49 large
U.S. cities in 1920 (`u`) and 1930 (`x`):

\
[`library`](https://rdrr.io/r/base/library.html)`(``boot``)`\
\
`## Draw 999 bootstrap samples of the population data. For each`\
`## sample, calculate the ratio of mean-1930 over mean-1920 populations`\
`ratio`` ``<-`` ``function``(``pop``, ``w``)`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``w`` ``*`` ``pop``$``x``)`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``w`` ``*`` ``pop``$``u``)`\
`b`` ``<-`` `[`boot`](https://rdrr.io/pkg/boot/man/boot.html)`(``bigcity``, statistic ``=`` ``ratio``, R ``=`` ``999``, stype ``=`` ``"w"``)`

Here [`boot()`](https://rdrr.io/pkg/boot/man/boot.html) evaluates
sequentially, but we can easily make it evaluate in parallel by piping
to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``boot``)`\
\
`ratio`` ``<-`` ``function``(``pop``, ``w``)`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``w`` ``*`` ``pop``$``x``)`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``w`` ``*`` ``pop``$``u``)`\
`b`` ``<-`` `[`boot`](https://rdrr.io/pkg/boot/man/boot.html)`(``bigcity``, statistic ``=`` ``ratio``, R ``=`` ``999``, stype ``=`` ``"w"``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the 999 bootstrap samples across the available
parallel workers, given that we have set up parallel workers, e.g.

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`

The built-in `multisession` backend parallelizes on your local computer
and works on all operating systems. There are [other parallel
backends](https://www.futureverse.org/backends.html) to choose from,
including alternatives to parallelize locally as well as distributed
across remote machines, e.g.

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``future.mirai``::`[`mirai_multisession`](https://future.mirai.futureverse.org/reference/mirai_multisession.html)`)`

and

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``future.batchtools``::`[`batchtools_slurm`](https://future.batchtools.futureverse.org/reference/batchtools_slurm.html)`)`

### Example: Time series bootstrap

The [`tsboot()`](https://rdrr.io/pkg/boot/man/tsboot.html) function
generates bootstrap samples from time series data. For example, here we
fit autoregressive models to bootstrap replicates of the `lynx` time
series:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``boot``)`\
\
`## Fit AR models to bootstrap replicates of the lynx time series`\
`lynx_fun`` ``<-`` ``function``(``tsb``)`` ``{`\
`    ``ar_fit`` ``<-`` `[`ar`](https://rdrr.io/r/stats/ar.html)`(``tsb``, order.max ``=`` ``25``)`\
`    `[`c`](https://rdrr.io/r/base/c.html)`(``ar_fit``$``order``, `[`mean`](https://rdrr.io/r/base/mean.html)`(``tsb``)``, ``tsb``)`\
`}`\
\
`lynx_boot`` ``<-`` `[`tsboot`](https://rdrr.io/pkg/boot/man/tsboot.html)`(`[`log`](https://rdrr.io/r/base/Log.html)`(``lynx``)``, ``lynx_fun``, R ``=`` ``999``, l ``=`` ``20``, sim ``=`` ``"geom"``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

### Example: Bootstrap for censored data

The [`censboot()`](https://rdrr.io/pkg/boot/man/censboot.html) function
is used for bootstrap sampling of censored data, which is common in
survival analysis. For example, using the `aml` data from the
**[boot](https://cran.r-project.org/package=boot)** package:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``boot``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`survival`](https://github.com/therneau/survival)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``aml``, package ``=`` ``"boot"``)`\
\
`aml_fun`` ``<-`` ``function``(``data``)`` ``{`\
`    ``surv`` ``<-`` `[`survfit`](https://rdrr.io/pkg/survival/man/survfit.html)`(`[`Surv`](https://rdrr.io/pkg/survival/man/Surv.html)`(``time``, ``cens``)`` ``~`` ``group``, data ``=`` ``data``)`\
`    ``out`` ``<-`` ``NULL`\
`    ``st`` ``<-`` ``1`\
`    ``for`` ``(``s`` ``in`` `[`seq_along`](https://rdrr.io/r/base/seq.html)`(``surv``$``strata``)``)`` ``{`\
`        ``inds`` ``<-`` ``st``:``(``st`` ``+`` ``surv``$``strata``[``s``]`` ``-`` ``1``)`\
`        ``md`` ``<-`` `[`min`](https://rdrr.io/r/base/Extremes.html)`(``surv``$``time``[``inds``[``1``-``surv``$``surv``[``inds``]`` ``>=`` ``0.5``]``]``)`\
`        ``st`` ``<-`` ``st`` ``+`` ``surv``$``strata``[``s``]`\
`        ``out`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``out``, ``md``)`\
`    ``}`\
`    ``out`\
`}`\
\
`aml_boot`` ``<-`` `[`censboot`](https://rdrr.io/pkg/boot/man/censboot.html)`(``aml``, ``aml_fun``, R ``=`` ``999``, strata ``=`` ``aml``$``group``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Supported Functions

The following **boot** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`boot()`](https://rdrr.io/pkg/boot/man/boot.html)
- [`censboot()`](https://rdrr.io/pkg/boot/man/censboot.html)
- [`tsboot()`](https://rdrr.io/pkg/boot/man/tsboot.html)

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`boot()`](https://rdrr.io/pkg/boot/man/boot.html) using the
**parallel** package directly, without **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(``boot``)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
\
`ratio`` ``<-`` ``function``(``pop``, ``w``)`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``w`` ``*`` ``pop``$``x``)`` ``/`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``w`` ``*`` ``pop``$``u``)`\
\
`## Set up a PSOCK cluster`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
\
`## Run bootstrapping in parallel`\
`b`` ``<-`` `[`boot`](https://rdrr.io/pkg/boot/man/boot.html)`(``bigcity``, statistic ``=`` ``ratio``, R ``=`` ``999``, stype ``=`` ``"w"``,`\
`          parallel ``=`` ``"snow"``, ncpus ``=`` ``ncpus``, cl ``=`` ``cl``)`\
\
`## Tear down the cluster`\
[`stopCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``cl``)`

This requires you to manually create and manage the cluster lifecycle.
If you forget to call
[`stopCluster()`](https://rdrr.io/r/parallel/makeCluster.html), or if
your code errors out before reaching it, you leak background R
processes. You also have to decide upfront how many CPUs to use and what
cluster type to use. Switching to another parallel backend, e.g. a Slurm
cluster, would require a completely different setup. With **futurize**,
all of this is handled for you - just pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
and control the backend with
[`plan()`](https://future.futureverse.org/reference/plan.html).
