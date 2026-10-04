# Parallelize 'tm' functions

![The 'tm' image](../reference/figures/cran-tm-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`tm`](https://tm.r-forge.r-project.org/)`)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"crude"``)`\
`m`` ``<-`` `[`tm_map`](https://rdrr.io/pkg/tm/man/tm_map.html)`(``crude``, `[`content_transformer`](https://rdrr.io/pkg/tm/man/content_transformer.html)`(``tolower``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[tm](https://cran.r-project.org/package=tm)** functions such as
[`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html).

The **[tm](https://cran.r-project.org/package=tm)** package provides a
variety of text-mining methods. The
[`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html) function applies
transformations to a corpus of text documents, and
[`TermDocumentMatrix()`](https://rdrr.io/pkg/tm/man/matrix.html)
constructs document-term matrices. When working with large corpora,
these operations benefit greatly from parallelization.

### Example: Transforming a text corpus

The [`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html) function
applies a transformation to each document in a corpus:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`tm`](https://tm.r-forge.r-project.org/)`)`\
\
`## Load the crude oil news corpus holding 20 documents`\
[`data`](https://rdrr.io/r/utils/data.html)`(``"crude"``)`\
\
`## Convert all text to lowercase`\
`m`` ``<-`` `[`tm_map`](https://rdrr.io/pkg/tm/man/tm_map.html)`(``crude``, `[`content_transformer`](https://rdrr.io/pkg/tm/man/content_transformer.html)`(``tolower``)``)`

Here [`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html) evaluates
sequentially, but we can easily make it evaluate in parallel by piping
to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`tm`](https://tm.r-forge.r-project.org/)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"crude"``)`\
`m`` ``<-`` `[`tm_map`](https://rdrr.io/pkg/tm/man/tm_map.html)`(``crude``, `[`content_transformer`](https://rdrr.io/pkg/tm/man/content_transformer.html)`(``tolower``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the document transformations across the available
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

## Supported Functions

The following **tm** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html)
- [`tm_index()`](https://rdrr.io/pkg/tm/man/tm_filter.html)
- [`TermDocumentMatrix()`](https://rdrr.io/pkg/tm/man/matrix.html)

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`tm_map()`](https://rdrr.io/pkg/tm/man/tm_map.html) using the
**parallel** package directly, without **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`tm`](https://tm.r-forge.r-project.org/)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
\
[`data`](https://rdrr.io/r/utils/data.html)`(``"crude"``)`\
\
`## Set up a PSOCK cluster`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
\
`## Configure tm to use the cluster`\
`old_engine`` ``<-`` `[`tm_parLapply_engine`](https://rdrr.io/pkg/tm/man/hpc.html)`(``)`\
[`tm_parLapply_engine`](https://rdrr.io/pkg/tm/man/hpc.html)`(``function``(``X``, ``FUN``, ``...``)`` `[`parLapply`](https://rdrr.io/r/parallel/clusterApply.html)`(``cl``, ``X``, ``FUN``, ``...``)``)`\
\
`## Transform the corpus in parallel`\
`m`` ``<-`` `[`tm_map`](https://rdrr.io/pkg/tm/man/tm_map.html)`(``crude``, `[`content_transformer`](https://rdrr.io/pkg/tm/man/content_transformer.html)`(``tolower``)``)`\
\
`## Restore the old engine and tear down the cluster`\
[`tm_parLapply_engine`](https://rdrr.io/pkg/tm/man/hpc.html)`(``old_engine``)`\
[`stopCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``cl``)`

This requires you to manually create a cluster, configure **tm**’s
internal parallel engine, and remember to restore the engine and tear
down the cluster when done. If you forget to call
[`stopCluster()`](https://rdrr.io/r/parallel/makeCluster.html), or if
your code errors out before reaching it, you leak background R
processes. You also have to decide upfront how many CPUs to use, what
cluster type to use. Switching to another parallel backend, e.g. a Slurm
cluster, would require a completely different setup. With **futurize**,
all of this is handled for you - just pipe to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
and control the backend with
[`plan()`](https://future.futureverse.org/reference/plan.html).
