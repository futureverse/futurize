# Parallelize 'lme4' functions

![The 'lme4' image](../reference/figures/cran-lme4-logo.webp)+ ![The
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
[`library`](https://rdrr.io/r/base/library.html)`(`[`lme4`](https://github.com/lme4/lme4/)`)`\
\
`gm`` ``<-`` `[`glmer`](https://rdrr.io/pkg/lme4/man/glmer.html)`(`[`cbind`](https://rdrr.io/r/base/cbind.html)`(``incidence``, ``size`` ``-`` ``incidence``)`` ``~`` ``period`` ``+`` ``(``1`` ``|`` ``herd``)``,`\
`             data ``=`` ``cbpp``, family ``=`` ``binomial``)`\
`gm_all`` ``<-`` `[`allFit`](https://rdrr.io/pkg/lme4/man/allFit.html)`(``gm``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Introduction

This vignette demonstrates how to use this approach to parallelize
**[lme4](https://cran.r-project.org/package=lme4)** functions such as
[`allFit()`](https://rdrr.io/pkg/lme4/man/allFit.html) and
[`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html).

The **[lme4](https://cran.r-project.org/package=lme4)** package fits
linear and generalized linear mixed-effects models. Its
[`allFit()`](https://rdrr.io/pkg/lme4/man/allFit.html) function fits
models using all available optimizers to check for convergence issues,
and [`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html) performs
parametric bootstrap inference. Both are excellent candidates for
parallelization.

### Example: Fitting with multiple optimizers

The [`allFit()`](https://rdrr.io/pkg/lme4/man/allFit.html) function fits
a model with each available optimizer, which can be done in parallel:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`lme4`](https://github.com/lme4/lme4/)`)`\
\
`## Fit a generalized linear mixed model`\
`gm`` ``<-`` `[`glmer`](https://rdrr.io/pkg/lme4/man/glmer.html)`(`[`cbind`](https://rdrr.io/r/base/cbind.html)`(``incidence``, ``size`` ``-`` ``incidence``)`` ``~`` ``period`` ``+`` ``(``1`` ``|`` ``herd``)``,`\
`            data ``=`` ``cbpp``, family ``=`` ``binomial``)`\
\
`## Try all available optimizers`\
`gm_all`` ``<-`` `[`allFit`](https://rdrr.io/pkg/lme4/man/allFit.html)`(``gm``)`

Here [`allFit()`](https://rdrr.io/pkg/lme4/man/allFit.html) evaluates
sequentially, but we can easily make it evaluate in parallel by piping
to
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`lme4`](https://github.com/lme4/lme4/)`)`\
\
`gm`` ``<-`` `[`glmer`](https://rdrr.io/pkg/lme4/man/glmer.html)`(`[`cbind`](https://rdrr.io/r/base/cbind.html)`(``incidence``, ``size`` ``-`` ``incidence``)`` ``~`` ``period`` ``+`` ``(``1`` ``|`` ``herd``)``,`\
`            data ``=`` ``cbpp``, family ``=`` ``binomial``)`\
`gm_all`` ``<-`` `[`allFit`](https://rdrr.io/pkg/lme4/man/allFit.html)`(``gm``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

This will distribute the optimizer fits across the available parallel
workers, given that we have set up parallel workers, e.g.

\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`

Unlike other parallel backends in R,
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
relays standard output, messages, and warnings produced by the parallel
workers back to your main R session. For instance, when running the
above, you will see the progress output from each optimizer as it
completes:

    > gm_all <- allFit(gm) |> futurize()
    bobyqa : [OK]
    Nelder_Mead : [OK]
    nlminbwrap : [OK]
    nmkbw : [OK]
    optimx.L-BFGS-B : [OK]
    nloptwrap.NLOPT_LN_NELDERMEAD : [OK]
    nloptwrap.NLOPT_LN_BOBYQA : [OK]

This output originates from the parallel workers and is relayed to your
R session, so you get the same informative feedback as when running
sequentially.

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

### Example: Parametric bootstrap

The [`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html) function
performs parametric bootstrap inference on fitted models:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`lme4`](https://github.com/lme4/lme4/)`)`\
\
`## Fit a linear mixed model`\
`fm`` ``<-`` `[`lmer`](https://rdrr.io/pkg/lme4/man/lmer.html)`(``Reaction`` ``~`` ``Days`` ``+`` ``(``Days`` ``|`` ``Subject``)``, data ``=`` ``sleepstudy``)`\
\
`## Bootstrap the fixed-effect coefficients`\
`boot_coef`` ``<-`` ``function``(``model``)`` `[`fixef`](https://rdrr.io/pkg/nlme/man/fixed.effects.html)`(``model``)`\
`b`` ``<-`` `[`bootMer`](https://rdrr.io/pkg/lme4/man/bootMer.html)`(``fm``, ``boot_coef``, nsim ``=`` ``100``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Supported Functions

The following **lme4** functions are supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md):

- [`allFit()`](https://rdrr.io/pkg/lme4/man/allFit.html)
- [`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html)
- [`influence()`](https://rdrr.io/r/stats/lm.influence.html) for
  ‘merMod’
- [`profile()`](https://rdrr.io/r/stats/profile.html) for ‘merMod’

## Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize
[`bootMer()`](https://rdrr.io/pkg/lme4/man/bootMer.html) using the
**parallel** package directly, without **futurize**:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`lme4`](https://github.com/lme4/lme4/)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
\
`## Fit a linear mixed model`\
`fm`` ``<-`` `[`lmer`](https://rdrr.io/pkg/lme4/man/lmer.html)`(``Reaction`` ``~`` ``Days`` ``+`` ``(``Days`` ``|`` ``Subject``)``, data ``=`` ``sleepstudy``)`\
\
`## Set up a PSOCK cluster`\
`ncpus`` ``<-`` ``4L`\
`cl`` ``<-`` `[`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``ncpus``)`\
\
`## Bootstrap the fixed-effect coefficients`\
`boot_coef`` ``<-`` ``function``(``model``)`` `[`fixef`](https://rdrr.io/pkg/nlme/man/fixed.effects.html)`(``model``)`\
`b`` ``<-`` `[`bootMer`](https://rdrr.io/pkg/lme4/man/bootMer.html)`(``fm``, ``boot_coef``, nsim ``=`` ``100``,`\
`             parallel ``=`` ``"snow"``, ncpus ``=`` ``ncpus``, cl ``=`` ``cl``)`\
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
