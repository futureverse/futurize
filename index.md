# futurize: Parallelize Common Functions via One Magic Function ![The 'futurize' hexlogo](reference/figures/futurize-logo.png)

## TL;DR

The **futurize** package makes it extremely simple to parallelize your
existing map-reduce calls, but also a growing set of domain-specific
calls. All you need to know is that there is a single function called
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
that will take care of everything, e.g.

\
`y`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``x``, ``fcn``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`y`` ``<-`` ``map``(``x``, ``fcn``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`b`` ``<-`` ``boot``(``city``, ``ratio``, R ``=`` ``999``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

The
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
function parallelizes via
**[futureverse](https://www.futureverse.org)**, meaning your code can
take advantage of any **[supported future
backends](https://www.futureverse.org/backends.html)**, whether it be
parallelization on your local computer, across multiple computers, in
the cloud, or on a high-performance compute (HPC) cluster. The
**futurize** package has only one hard dependency - the
**[future](https://future.futureverse.org)** package. All other
dependencies are optional “buy-in” dependencies as shown in the below
tables.

In addition to getting access to all future-based parallel backends, by
using
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
you also get access to all the benefits that come with **futureverse**,
including **structured concurrency**. For example, it ensures that
remaining parallel tasks are cancelled if there is an error or an
interrupt. Also, if the function you parallelize outputs messages and
warnings, they will be relayed from the parallel worker to your main R
session, just as you get when running sequentially. This is particularly
useful when troubleshooting or debugging.

Using **futurize** comes with a zero risk buy-in. If there is ever a
parallel universe where
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
suddenly stops working, setting `futurize <- identical` avoids rewrites
while make all code to run sequentially.

## Supported map-reduce packages

The **futurize** package supports transpilation of functions from
multiple packages. The tables below summarize the supported map-reduce
(Table 1) and domain-specific (Tables 2 and 3) functions, respectively.
To programmatically see which packages are currently supported, use:

\
[`futurize_supported_packages`](https://futurize.futureverse.org/reference/futurize_supported_packages.md)`(``)`

To see which functions are supported for a specific package, use:

\
[`futurize_supported_functions`](https://futurize.futureverse.org/reference/futurize_supported_packages.md)`(``"caret"``)`

| Package | Functions | Requires |
|----|----|----|
| **base** | [`lapply()`](https://rdrr.io/r/base/lapply.html), [`sapply()`](https://rdrr.io/r/base/lapply.html), [`tapply()`](https://rdrr.io/r/base/tapply.html), [`vapply()`](https://rdrr.io/r/base/lapply.html), [`mapply()`](https://rdrr.io/r/base/mapply.html), [`.mapply()`](https://rdrr.io/r/base/mapply.html), [`Map()`](https://rdrr.io/r/base/funprog.html), [`eapply()`](https://rdrr.io/r/base/eapply.html), [`apply()`](https://rdrr.io/r/base/apply.html), [`by()`](https://rdrr.io/r/base/by.html), [`replicate()`](https://rdrr.io/r/base/lapply.html), [`Filter()`](https://rdrr.io/r/base/funprog.html) | **[future.apply](https://future.apply.futureverse.org)** |
| **stats** | [`kernapply()`](https://rdrr.io/r/stats/kernapply.html) | **[future.apply](https://future.apply.futureverse.org)** |
| **[purrr](https://cran.r-project.org/package=purrr)** | `map()` and variants, `map2()` and variants, `pmap()` and variants, `imap()` and variants, `modify()`, `modify_if()`, `modify_at()`, `map_if()`, `map_at()` | **[furrr](https://furrr.futureverse.org)** |
| **[crossmap](https://cran.r-project.org/package=crossmap)** | `xmap()` and variants, `xwalk()`, `map_vec()`, `map2_vec()`, `pmap_vec()`, `imap_vec()` | \- |
| **[foreach](https://cran.r-project.org/package=foreach)** | `%do%`, e.g. `foreach() %do% { }`, `times() %do% { }` | **[doFuture](https://doFuture.futureverse.org)** |
| **[plyr](https://cran.r-project.org/package=plyr)** | `aaply()` and variants, `ddply()` and variants, `llply()` and variants, `mlply()` and variants | **[doFuture](https://doFuture.futureverse.org)** |
| **[pbapply](https://cran.r-project.org/package=pbapply)** | `pblapply()`, `pbsapply()` and variants, `pbby()`, `pbreplicate()` and `pbwalk()` | **[future.apply](https://future.apply.futureverse.org)** |
| **[BiocParallel](https://bioconductor.org/packages/BiocParallel/)** | `bplapply()`, `bpmapply()`, `bpvec()`, `bpiterate()`, `bpaggregate()` | **[doFuture](https://doFuture.futureverse.org)** |

*Table 1: Map-reduce functions currently supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
for parallel transpilation.*

Here are some examples:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``multisession``)`\
\
`xs`` ``<-`` ``1``:``10`\
`ys`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``xs``, ``sqrt``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`xs`` ``<-`` ``1``:``10`\
`ys`` ``<-`` ``purrr``::`[`map`](https://purrr.tidyverse.org/reference/map.html)`(``xs``, ``sqrt``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`xs`` ``<-`` ``1``:``10`\
`ys`` ``<-`` ``crossmap``::`[`xmap_dbl`](https://pkg.rossellhayes.com/crossmap/reference/xmap.html)`(``xs``, ``~`` ``.y`` ``*`` ``.x``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
[`library`](https://rdrr.io/r/base/library.html)`(`[`foreach`](https://github.com/RevolutionAnalytics/foreach)`)`\
`xs`` ``<-`` ``1``:``10`\
`ys`` ``<-`` `[`foreach`](https://rdrr.io/pkg/foreach/man/foreach.html)`(``x ``=`` ``xs``)`` `[`%do%`](https://rdrr.io/pkg/foreach/man/foreach.html)` ``{`` `[`sqrt`](https://rdrr.io/r/base/MathFun.html)`(``x``)`` ``}`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`xs`` ``<-`` ``1``:``10`\
`ys`` ``<-`` ``plyr``::`[`llply`](https://rdrr.io/pkg/plyr/man/llply.html)`(``xs``, ``sqrt``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`xs`` ``<-`` ``1``:``10`\
`ys`` ``<-`` ``pbapply``::`[`pblapply`](https://peter.solymos.org/pbapply/reference/pbapply.html)`(``xs``, ``sqrt``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`xs`` ``<-`` ``1``:``10`\
`ys`` ``<-`` ``BiocParallel``::``bplapply``(``xs``, ``sqrt``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

and

\
`ys`` ``<-`` `[`replicate`](https://rdrr.io/r/base/lapply.html)`(``3``, `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``1``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`y`` ``<-`` `[`by`](https://rdrr.io/r/base/by.html)`(``warpbreaks``, ``warpbreaks``[``,``"tension"``]``,`\
`        ``function``(``x``)`` `[`lm`](https://rdrr.io/r/stats/lm.html)`(``breaks`` ``~`` ``wool``, data ``=`` ``x``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`xs`` ``<-`` ``EuStockMarkets``[``, ``1``:``2``]`\
`k`` ``<-`` `[`kernel`](https://rdrr.io/r/stats/kernel.html)`(``"daniell"``, ``50``)`\
`xs_smooth`` ``<-`` ``stats``::`[`kernapply`](https://rdrr.io/r/stats/kernapply.html)`(``xs``, k ``=`` ``k``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

## Supported domain-specific packages

You can also futurize calls from a growing set of domain-specific CRAN
and Bioconductor packages that have optional built-in support for
parallelization.

### CRAN packages with support for futurize

| Package | Functions | Requires |
|----|----|----|
| **[boot](https://cran.r-project.org/package=boot)** | `boot()`, `censboot()`, `tsboot()` | \- |
| **[caret](https://cran.r-project.org/package=caret)** | `bag()`, `gafs()`, `nearZeroVar()`, `rfe()`, `safs()`, `sbf()`, `train()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[DiceKriging](https://cran.r-project.org/package=DiceKriging)** | `km()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[ez](https://cran.r-project.org/package=ez)** | `ezBoot()`, `ezPerm()`, `ezPlot2()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[fwb](https://ngreifer.github.io/fwb/)** | `fwb()`, `vcovFWB()` | \- |
| **[gamlss](https://cran.r-project.org/package=gamlss)** | `add1All()`, `add1TGD()`, `drop1All()`, `drop1TGD()`, `gamlssCV()` | \- |
| **[glmmTMB](https://cran.r-project.org/package=glmmTMB)** | [`profile()`](https://rdrr.io/r/stats/profile.html) for ‘glmmTMB’ | \- |
| **[glmnet](https://cran.r-project.org/package=glmnet)** | `cv.glmnet()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[kernelshap](https://cran.r-project.org/package=kernelshap)** | `kernelshap()`, `permshap()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[lme4](https://cran.r-project.org/package=lme4)** | `allFit()`, `bootMer()`, [`influence()`](https://rdrr.io/r/stats/lm.influence.html) and [`profile()`](https://rdrr.io/r/stats/profile.html) for ‘merMod’ | \- |
| **[metafor](https://cran.r-project.org/package=metafor)** | [`profile()`](https://rdrr.io/r/stats/profile.html), [`rstudent()`](https://rdrr.io/r/stats/influence.measures.html), [`cooks.distance()`](https://rdrr.io/r/stats/influence.measures.html), [`dfbetas()`](https://rdrr.io/r/stats/influence.measures.html) for ‘rma’ | \- |
| **[mgcv](https://cran.r-project.org/package=mgcv)** | `bam()`, [`predict()`](https://rdrr.io/r/stats/predict.html) for ‘bam’ | \- |
| **[modelsummary](https://cran.r-project.org/package=modelsummary)** | `modelsummary()`, `msummary()`, `modelplot()` | **[future.apply](https://future.apply.futureverse.org)** |
| **[parameters](https://cran.r-project.org/package=parameters)** | `bootstrap_model()`, `bootstrap_parameters()` | \- |
| **[partykit](https://cran.r-project.org/package=partykit)** | `cforest()`, `ctree_control()`, `mob_control()`, `varimp()` for ‘cforest’ | **[future.apply](https://future.apply.futureverse.org)** |
| **[pls](https://cran.r-project.org/package=pls)** | `mvr()`, `plsr()`, `pcr()`, `cppls()`, `crossval()` | \- |
| **[pvclust](https://cran.r-project.org/package=pvclust)** | `pvclust()` | \- |
| **[riskRegression](https://cran.r-project.org/package=riskRegression)** | `Score()` for ‘list’ | **[doFuture](https://doFuture.futureverse.org)** |
| **[rugarch](https://cran.r-project.org/package=rugarch)** | `arfimacv()`, `arfimadistribution()`, `arfimaroll()`, `autoarfima()`, `multifilter()`, `multifit()`, `multiforecast()`, `ugarchboot()`, `ugarchdistribution()`, `ugarchroll()` | \- |
| **[sandwich](https://cran.r-project.org/package=sandwich)** | `vcovBS()`, `vcovJK()` | **[future.apply](https://future.apply.futureverse.org)** |
| **[seriation](https://cran.r-project.org/package=seriation)** | `seriate_best()`, `seriate_rep()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[shapr](https://cran.r-project.org/package=shapr)** | `explain()`, `explain_forecast()` | \- |
| **[Sim.DiffProc](https://cran.r-project.org/package=Sim.DiffProc)** | `MCM.sde()` | \- |
| **[SimDesign](https://cran.r-project.org/package=SimDesign)** | `runSimulation()`, `runArraySimulation()` | \- |
| **[stars](https://cran.r-project.org/package=stars)** | `st_apply()` | **[future.apply](https://future.apply.futureverse.org)** |
| **[strucchange](https://cran.r-project.org/package=strucchange)** | `breakpoints()` for ‘formula’ | **[doFuture](https://doFuture.futureverse.org)** |
| **[SuperLearner](https://cran.r-project.org/package=SuperLearner)** | `CV.SuperLearner()` | \- |
| **[tm](https://cran.r-project.org/package=tm)** | `TermDocumentMatrix()`, `tm_index()`, `tm_map()` | \- |
| **[TSP](https://cran.r-project.org/package=TSP)** | `solve_TSP()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[vegan](https://cran.r-project.org/package=vegan)** | `adonis()`, `adonis2()`, [`anova()`](https://rdrr.io/r/stats/anova.html) for ‘cca’, `anosim()`, `cascadeKM()`, `estaccumR()`, `mantel()`, `mantel.partial()`, `metaMDSiter()`, `mrpp()`, `oecosimu()`, `ordiareatest()`, `permutest()` for ‘betadisper’, and ‘cca’ | \- |

*Table 2: CRAN packages with domain-specific functions currently
supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
for parallel transpilation.*

Here are some examples:

\
`ratio`` ``<-`` ``function``(``d``, ``w``)`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``d``$``x`` ``*`` ``w``)``/`[`sum`](https://rdrr.io/r/base/sum.html)`(``d``$``u`` ``*`` ``w``)`\
`b`` ``<-`` ``boot``::`[`boot`](https://rdrr.io/pkg/boot/man/boot.html)`(``boot``::`[`city`](https://rdrr.io/pkg/boot/man/bigcity.html)`, ``ratio``, R ``=`` ``999``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`ctrl`` ``<-`` ``caret``::`[`trainControl`](https://rdrr.io/pkg/caret/man/trainControl.html)`(``method ``=`` ``"cv"``, number ``=`` ``10``)`\
`model`` ``<-`` ``caret``::`[`train`](https://rdrr.io/pkg/caret/man/train.html)`(``Species`` ``~`` ``.``, data ``=`` ``iris``, method ``=`` ``"rf"``, trControl ``=`` ``ctrl``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`rt`` ``<-`` ``ez``::`[`ezBoot`](https://rdrr.io/pkg/ez/man/ezBoot.html)`(``data ``=`` ``ANT``, dv ``=`` ``rt``, wid ``=`` ``subnum``, within ``=`` ``.``(``cue``, ``flank``)``, between ``=`` ``group``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`f`` ``<-`` ``fwb``::`[`fwb`](https://ngreifer.github.io/fwb/reference/fwb.html)`(``boot``::`[`city`](https://rdrr.io/pkg/boot/man/bigcity.html)`, ``ratio``, R ``=`` ``999``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`m`` ``<-`` ``DiceKriging``::`[`km`](https://rdrr.io/pkg/DiceKriging/man/km.html)`(``~``.``, design ``=`` ``design``, response ``=`` ``response``, multistart ``=`` ``8L``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`cv`` ``<-`` ``gamlss``::`[`gamlssCV`](https://rdrr.io/pkg/gamlss/man/gamlssVGD.html)`(``y`` ``~`` ``pb``(``x``)``, data ``=`` ``abdom``, K.fold ``=`` ``10``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`cv`` ``<-`` ``glmnet``::`[`cv.glmnet`](https://glmnet.stanford.edu/reference/cv.glmnet.html)`(``x``, ``y``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`ks`` ``<-`` ``kernelshap``::`[`kernelshap`](https://rdrr.io/pkg/kernelshap/man/kernelshap.html)`(``model``, X ``=`` ``x_explain``, bg_X ``=`` ``bg_X``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`m`` ``<-`` ``lme4``::`[`allFit`](https://rdrr.io/pkg/lme4/man/allFit.html)`(``models``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`fit`` ``<-`` ``metafor``::`[`rma`](https://wviechtb.github.io/metafor/reference/rma.uni.html)`(``yi``, ``vi``)`\
`pr`` ``<-`` `[`profile`](https://rdrr.io/r/stats/profile.html)`(``fit``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`b`` ``<-`` ``mgcv``::`[`bam`](https://rdrr.io/pkg/mgcv/man/bam.html)`(``y`` ``~`` ``s``(``x0``, bs ``=`` ``bs``)`` ``+`` ``s``(``x1``, bs ``=`` ``bs``)``, data ``=`` ``dat``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`fit`` ``<-`` ``parameters``::`[`bootstrap_model`](https://easystats.github.io/parameters/reference/bootstrap_model.html)`(``model``, iterations ``=`` ``1000``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`cf`` ``<-`` ``partykit``::`[`cforest`](https://rdrr.io/pkg/partykit/man/cforest.html)`(``dist`` ``~`` ``speed``, data ``=`` ``cars``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`m`` ``<-`` ``pls``::`[`plsr`](https://khliland.github.io/pls/reference/mvr.html)`(``density`` ``~`` ``NIR``, ncomp ``=`` ``10``, data ``=`` ``yarn``, validation ``=`` ``"CV"``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`fit`` ``<-`` ``pvclust``::`[`pvclust`](https://rdrr.io/pkg/pvclust/man/pvclust.html)`(``mtcars``, nboot ``=`` ``1000``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`v`` ``<-`` ``sandwich``::`[`vcovBS`](https://rdrr.io/pkg/sandwich/man/vcovBS.html)`(``fm``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`sc`` ``<-`` ``riskRegression``::`[`Score`](https://rdrr.io/pkg/riskRegression/man/Score.html)`(`[`list`](https://rdrr.io/r/base/list.html)`(``"CSC"`` ``=`` ``fit``)``, data ``=`` ``d``,`\
`  formula ``=`` ``Hist``(``time``, ``event``)`` ``~`` ``1``, times ``=`` ``5``, B ``=`` ``100``,`\
`  split.method ``=`` ``"bootcv"``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`roll`` ``<-`` ``rugarch``::`[`ugarchroll`](https://rdrr.io/pkg/rugarch/man/ugarchroll-methods.html)`(``spec``, ``sp500ret``, n.start ``=`` ``1000``, `\
`  refit.window ``=`` ``"moving"``, refit.every ``=`` ``100``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`result`` ``<-`` ``shapr``::`[`explain`](https://norskregnesentral.github.io/shapr/reference/explain.html)`(``model``, ``x_explain``, ``x_train``, approach ``=`` ``"empirical"``, phi0 ``=`` ``phi0``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
\
`o`` ``<-`` ``seriation``::`[`seriate_best`](https://rdrr.io/pkg/seriation/man/seriate_best.html)`(``d_supreme``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`res`` ``<-`` ``Sim.DiffProc``::`[`MCM.sde`](https://rdrr.io/pkg/Sim.DiffProc/man/MCM.sde.html)`(``model``, statistic ``=`` ``stat``, R ``=`` ``100``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`res`` ``<-`` ``SimDesign``::`[`runSimulation`](http://philchalmers.github.io/SimDesign/reference/runSimulation.md)`(``Design``, replications ``=`` ``1000``,`\
`  generate ``=`` ``Generate``, analyse ``=`` ``Analyse``, summarise ``=`` ``Summarise``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`s`` ``<-`` ``stars``::`[`st_as_stars`](https://r-spatial.github.io/stars/reference/st_as_stars.html)`(`[`matrix`](https://rdrr.io/r/base/matrix.html)`(``1``:``20``, nrow ``=`` ``5``, ncol ``=`` ``4``)``)`\
`res`` ``<-`` ``stars``::`[`st_apply`](https://r-spatial.github.io/stars/reference/st_apply.html)`(``s``, MARGIN ``=`` ``1``, FUN ``=`` ``mean``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`bp`` ``<-`` ``strucchange``::`[`breakpoints`](https://rdrr.io/pkg/strucchange/man/breakpoints.html)`(``Nile`` ``~`` ``1``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`res`` ``<-`` ``SuperLearner``::`[`CV.SuperLearner`](https://rdrr.io/pkg/SuperLearner/man/CV.SuperLearner.html)`(``Y``, ``X``, SL.library ``=`` ``SL.library``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`m`` ``<-`` ``tm``::`[`tm_map`](https://rdrr.io/pkg/tm/man/tm_map.html)`(``crude``, ``content_transformer``(``tolower``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`tour`` ``<-`` ``TSP``::`[`solve_TSP`](https://rdrr.io/pkg/TSP/man/solve_TSP.html)`(``USCA50``, method ``=`` ``"nn"``, rep ``=`` ``10``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`md`` ``<-`` ``vegan``::`[`mrpp`](https://vegandevs.github.io/vegan/reference/mrpp.html)`(``dune``, ``Management``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`

### Bioconductor packages with support for futurize

| Package | Functions | Requires |
|----|----|----|
| **[DESeq2](https://bioconductor.org/packages/DESeq2/)** | `DESeq()`, `lfcShrink()`, `results()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[fgsea](https://bioconductor.org/packages/fgsea/)** | `fgsea()`, `fgseaMultilevel()`, `fgseaSimple()`, `fgseaLabel()`, `geseca()`, `gesecaSimple()`, `collapsePathwaysGeseca()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[GenomicAlignments](https://bioconductor.org/packages/GenomicAlignments/)** | `summarizeOverlaps()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[GSVA](https://bioconductor.org/packages/GSVA/)** | `gsva()`, `gsvaRanks()`, `gsvaScores()`, `spatCor()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[Rsamtools](https://bioconductor.org/packages/Rsamtools/)** | `countBam()`, `scanBam()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[scater](https://bioconductor.org/packages/scater/)** | `calculatePCA()`, `calculateTSNE()`, `calculateUMAP()`, `runPCA()`, `runTSNE()`, `runUMAP()`, `runColDataPCA()`, `nexprs()`, `getVarianceExplained()`, `plotRLE()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[scuttle](https://bioconductor.org/packages/scuttle/)** | `calculateAverage()`, `logNormCounts()`, `normalizeCounts()`, `perCellQCMetrics()`, `perFeatureQCMetrics()`, `addPerCellQCMetrics()`, `addPerFeatureQCMetrics()`, `addPerCellQC()`, `addPerFeatureQC()`, `numDetectedAcrossCells()`, `numDetectedAcrossFeatures()`, `sumCountsAcrossCells()`, `sumCountsAcrossFeatures()`, `summarizeAssayByGroup()`, `aggregateAcrossCells()`, `aggregateAcrossFeatures()`, `librarySizeFactors()`, `computeLibraryFactors()`, `geometricSizeFactors()`, `computeGeometricFactors()`, `medianSizeFactors()`, `computeMedianFactors()`, `pooledSizeFactors()`, `computePooledFactors()`, `fitLinearModel()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[SingleCellExperiment](https://bioconductor.org/packages/SingleCellExperiment/)** | `applySCE()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[sva](https://bioconductor.org/packages/sva/)** | `ComBat()`, `read.degradation.matrix()` | **[doFuture](https://doFuture.futureverse.org)** |

*Table 3: Bioconductor packages with domain-specific functions currently
supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
for parallel transpilation.*

Here are some examples:

\
`dds`` ``<-`` ``DESeq2``::``DESeq``(``dds``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`res`` ``<-`` ``fgsea``::``fgsea``(``pathways``, ``stats``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`se`` ``<-`` ``GenomicAlignments``::``summarizeOverlaps``(``features``, ``bam_files``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`es`` ``<-`` ``GSVA``::``gsva``(``GSVA``::``gsvaParam``(``expr``, ``geneSets``)``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`counts`` ``<-`` ``Rsamtools``::``countBam``(``bamViews``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`sce`` ``<-`` ``scater``::``runPCA``(``sce``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`qc`` ``<-`` ``scuttle``::``perFeatureQCMetrics``(``sce``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
\
`result`` ``<-`` ``SingleCellExperiment``::``applySCE``(``sce``, ``scuttle``::``perFeatureQCMetrics``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`\
`  `\
`adjusted`` ``<-`` ``sva``::``ComBat``(``dat ``=`` ``dat``, batch ``=`` ``batch``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.md)`(``)`
