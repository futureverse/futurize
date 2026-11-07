# Parallelize 'ez' functions

![The 'futurize' hexlogo](../reference/figures/futurize-logo.webp)=
![The 'future' logo](../reference/figures/future-logo.webp)

The **futurize** package allows you to easily turn sequential code into
parallel code by piping the sequential code to the
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function. Easy!

## TL;DR

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ez`](https://github.com/bucky2177/ez)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``ANT``)`\
`rt`` ``<-`` `[`ezBoot`](https://rdrr.io/pkg/ez/man/ezBoot.html)`(`\
`  data ``=`` ``ANT``,`\
`  dv ``=`` ``rt``,`\
`  wid ``=`` ``subnum``,`\
`  within ``=`` `[`.`](https://rdrr.io/pkg/plyr/man/quoted.html)`(``cue``, ``flank``)``,`\
`  between ``=`` ``group``,`\
`  iterations ``=`` ``1e3`\
`)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[ez](https://cran.r-project.org/package=ez)** functions such as
[`ezBoot()`](https://rdrr.io/pkg/ez/man/ezBoot.html),
[`ezPerm()`](https://rdrr.io/pkg/ez/man/ezPerm.html), and
[`ezPlot2()`](https://rdrr.io/pkg/ez/man/ezPlot2.html). The functions
[`ezBoot()`](https://rdrr.io/pkg/ez/man/ezBoot.html),
[`ezPerm()`](https://rdrr.io/pkg/ez/man/ezPerm.html), and
[`ezPlot2()`](https://rdrr.io/pkg/ez/man/ezPlot2.html) support parallel
evaluation via the `parallel` argument. By piping to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md),
you can leverage any future-based parallel backend for these
computations.

### Example: Bootstrap resampling

The [`ezBoot()`](https://rdrr.io/pkg/ez/man/ezBoot.html) function
computes bootstrap resampled predictions for each cell in an
experimental design. We can parallelize this as:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ez`](https://github.com/bucky2177/ez)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``ANT``)`\
`rt`` ``<-`` `[`ezBoot`](https://rdrr.io/pkg/ez/man/ezBoot.html)`(`\
`  data ``=`` ``ANT``,`\
`  dv ``=`` ``rt``,`\
`  wid ``=`` ``subnum``,`\
`  within ``=`` `[`.`](https://rdrr.io/pkg/plyr/man/quoted.html)`(``cue``, ``flank``)``,`\
`  between ``=`` ``group``,`\
`  iterations ``=`` ``1e3`\
`)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the bootstrap iterations across the available
parallel workers.

### Example: Permutation testing

The [`ezPerm()`](https://rdrr.io/pkg/ez/man/ezPerm.html) function
performs a non-parametric factorial permutation test, and can be
parallelized as:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ez`](https://github.com/bucky2177/ez)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`plyr`](http://had.co.nz/plyr)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``ANT``)`\
`cell_stats`` ``<-`` `[`ddply`](https://rdrr.io/pkg/plyr/man/ddply.html)`(`\
`  .data ``=`` ``ANT``,`\
`  .variables ``=`` `[`.`](https://rdrr.io/pkg/plyr/man/quoted.html)`(``subnum``, ``group``, ``cue``, ``flank``)``,`\
`  .fun ``=`` ``function``(``x``)`` ``{`\
`    `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``mrt ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``x``$``rt``[``x``$``error`` ``==`` ``0``]``)``)`\
`  ``}`\
`)`\
`gmrt`` ``<-`` `[`ddply`](https://rdrr.io/pkg/plyr/man/ddply.html)`(`\
`  .data ``=`` ``cell_stats``,`\
`  .variables ``=`` `[`.`](https://rdrr.io/pkg/plyr/man/quoted.html)`(``subnum``, ``group``)``,`\
`  .fun ``=`` ``function``(``x``)`` ``{`\
`    `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``mrt ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``x``$``mrt``)``)`\
`  ``}`\
`)`\
\
`mean_rt_perm`` ``<-`` `[`ezPerm`](https://rdrr.io/pkg/ez/man/ezPerm.html)`(`\
`  data ``=`` ``gmrt``,`\
`  dv ``=`` ``mrt``,`\
`  wid ``=`` ``subnum``,`\
`  between ``=`` ``group``,`\
`  perms ``=`` ``1e3`\
`)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Supported Functions

The following **ez** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`ezBoot()`](https://rdrr.io/pkg/ez/man/ezBoot.html) with
  `seed = TRUE` as the default
- [`ezPerm()`](https://rdrr.io/pkg/ez/man/ezPerm.html) with
  `seed = TRUE` as the default
- [`ezPlot2()`](https://rdrr.io/pkg/ez/man/ezPlot2.html)
