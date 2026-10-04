# Parallelize 'crossmap' functions

![The 'crossmap' image](../reference/figures/crossmap-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`crossmap`](https://pkg.rossellhayes.com/crossmap/)`)`\
\
`xs`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``1``:``5``, ``1``:``5``)`\
`ys`` ``<-`` `[`xmap`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)`(``xs``, ``~`` ``.y`` ``*`` ``.x``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

The **[crossmap](https://cran.r-project.org/package=crossmap)** package
adds to the **[purrr](https://cran.r-project.org/package=purrr)**-set of
functions. For example,
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
can apply a function to every combination of elements in a list, e.g.

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`crossmap`](https://pkg.rossellhayes.com/crossmap/)`)`\
\
`# Multiply the 15 combinations of values in 1:3 and -2:2`\
`xs`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``1``:``3``, ``-``2``:``2``)`\
`ys`` ``<-`` `[`xmap`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)`(``xs``, ``function``(``x``, ``y``)`` ``x`` ``*`` ``y``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

Here
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
evaluates sequentially over each combination of (.y, .x) elements. The
**crossmap** package provides its own future-counterpart functions,
e.g. there is a
[`future_xmap()`](https://pkg.rossellhayes.com/crossmap/reference/future_xmap.html)
that mimics
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html).
The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function transpiles
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
into
[`future_xmap()`](https://pkg.rossellhayes.com/crossmap/reference/future_xmap.html),
meaning you can do:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
\
`# Multiply the 15 combinations of values in 1:3 and -2:2`\
`xs`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``1``:``3``, ``-``2``:``2``)`\
`ys`` ``<-`` `[`xmap`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)`(``xs``, ``function``(``x``, ``y``)`` ``x`` ``*`` ``y``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

to process this
[`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
call concurrently, which allows you to execute it on a set of parallel
workers, e.g.

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`

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
function supports parallelization of the following **crossmap**
functions:

- [`imap_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`map_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`map2_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`pmap_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html),
  [`xmap_vec()`](https://pkg.rossellhayes.com/crossmap/reference/map_vec.html)
- [`xmap()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
- [`xmap_chr()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_dbl()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_int()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_lgl()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
- [`xmap_dfc()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html),
  [`xmap_dfr()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
- [`xmap_mat()`](https://pkg.rossellhayes.com/crossmap/reference/xmap_mat.html),
  [`xmap_arr()`](https://pkg.rossellhayes.com/crossmap/reference/xmap_mat.html)
- [`xwalk()`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)
