# Parallelize 'purrr' functions

![The 'purrr' logo](../reference/figures/purrr-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`purrr`](https://purrr.tidyverse.org/)`)`\
\
`slow_fcn`` ``<-`` ``function``(``x``)`` ``{`\
`  `[`message`](https://rdrr.io/r/base/message.html)`(``"x = "``, ``x``)`\
`  `[`Sys.sleep`](https://rdrr.io/r/base/Sys.sleep.html)`(``0.1``)``  ``# emulate work`\
`  ``x``^``2`\
`}`\
\
`xs`` ``<-`` ``1``:``10`\
`ys`` ``<-`` ``xs`` ``|>`` `[`map`](https://purrr.tidyverse.org/reference/map.html)`(``slow_fcn``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[purrr](https://cran.r-project.org/package=purrr)** functions such as
[`map()`](https://purrr.tidyverse.org/reference/map.html),
[`map_dbl()`](https://purrr.tidyverse.org/reference/map.html), and
[`walk()`](https://purrr.tidyverse.org/reference/map.html).

The **purrr** [`map()`](https://purrr.tidyverse.org/reference/map.html)
function is commonly used to apply a function to the elements of a
vector or a list. For example,

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`purrr`](https://purrr.tidyverse.org/)`)`\
`xs`` ``<-`` ``1``:``1000`\
`ys`` ``<-`` `[`map`](https://purrr.tidyverse.org/reference/map.html)`(``xs``, ``slow_fcn``)`

or equivalently using pipe syntax

\
`xs`` ``<-`` ``1``:``1000`\
`ys`` ``<-`` ``xs`` ``|>`` `[`map`](https://purrr.tidyverse.org/reference/map.html)`(``slow_fcn``)`

Here [`map()`](https://purrr.tidyverse.org/reference/map.html) evaluates
sequentially, but we can easily make it evaluate in parallel, by using:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`purrr`](https://purrr.tidyverse.org/)`)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`` ``## parallelize on local machine`\
\
`xs`` ``<-`` ``1``:``1000`\
`ys`` ``<-`` ``xs`` ``|>`` `[`map`](https://purrr.tidyverse.org/reference/map.html)`(``slow_fcn``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
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

Another example is:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`purrr`](https://purrr.tidyverse.org/)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``future.mirai``::`[`mirai_multisession`](https://future.mirai.futureverse.org/reference/mirai_multisession.html)`)`\
\
`ys`` ``<-`` ``1``:``10`` ``|>`\
`        `[`map`](https://purrr.tidyverse.org/reference/map.html)`(``rnorm``, n ``=`` ``10``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``seed ``=`` ``TRUE``)`` ``|>`\
`        `[`map_dbl`](https://purrr.tidyverse.org/reference/map.html)`(``mean``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Supported Functions

The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function supports parallelization of the following **purrr** functions:

- [`map()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_chr()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_dbl()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_int()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_lgl()`](https://purrr.tidyverse.org/reference/map.html),
  [`map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`map_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`walk()`](https://purrr.tidyverse.org/reference/map.html)
- [`map2()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_chr()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_dbl()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_int()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_lgl()`](https://purrr.tidyverse.org/reference/map2.html),
  [`map2_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`map2_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`walk2()`](https://purrr.tidyverse.org/reference/map2.html)
- [`pmap()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_chr()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_dbl()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_int()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_lgl()`](https://purrr.tidyverse.org/reference/pmap.html),
  [`pmap_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`pmap_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`pwalk()`](https://purrr.tidyverse.org/reference/pmap.html)
- [`imap()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_chr()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_dbl()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_int()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_lgl()`](https://purrr.tidyverse.org/reference/imap.html),
  [`imap_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`imap_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html),
  [`iwalk()`](https://purrr.tidyverse.org/reference/imap.html)
- [`modify()`](https://purrr.tidyverse.org/reference/modify.html),
  [`modify_if()`](https://purrr.tidyverse.org/reference/modify.html),
  [`modify_at()`](https://purrr.tidyverse.org/reference/modify.html)
- [`map_if()`](https://purrr.tidyverse.org/reference/map_if.html),
  [`map_at()`](https://purrr.tidyverse.org/reference/map_if.html)

## Progress Reporting via progressify

For progress reporting, please see the
**[progressify](https://progressify.futureverse.org/)** package. It is
specially designed to work with the Futureverse ecosystem and provide
progress updates from parallelized computations in a near-live fashion.
See the
[`vignette("futurize-11-apply", package = "futurize")`](https://futurize.futureverse.org/articles/futurize-11-apply.md)
for more details and an example.
