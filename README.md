<div id="badges"><!-- pkgdown markup -->
<a href="https://CRAN.R-project.org/web/checks/check_results_futurize.html"><img border="0" src="https://www.r-pkg.org/badges/version/futurize" alt="CRAN check status"/></a> <a href="https://github.com/futureverse/futurize/actions?query=workflow%3AR-CMD-check"><img border="0" src="https://github.com/futureverse/futurize/actions/workflows/R-CMD-check.yaml/badge.svg?branch=develop" alt="R CMD check status"/></a>     <a href="https://app.codecov.io/gh/futureverse/futurize"><img border="0" src="https://codecov.io/gh/futureverse/futurize/branch/develop/graph/badge.svg" alt="Coverage Status"/></a> 
</div>

# futurize: Parallelize Common Functions via One Magic Function <img border="0" src="man/figures/futurize-logo.png" style="width: 120px; margin: 2ex;" alt="The 'futurize' hexlogo" align="right"/>

## TL;DR 

The **futurize** package makes it extremely simple to parallelize your
existing map-reduce calls, but also a growing set of domain-specific
calls.  All you need to know is that there is a single function called
`futurize()` that will take care of everything, e.g.

```r
y <- lapply(x, fcn) |> futurize()
y <- map(x, fcn) |> futurize()
b <- boot(city, ratio, R = 999) |> futurize()
```

The `futurize()` function parallelizes via **[futureverse]**, meaning
your code can take advantage of any **[supported future backends]**,
whether it be parallelization on your local computer, across multiple
computers, in the cloud, or on a high-performance compute (HPC) cluster.
The **futurize** package has only one hard dependency - the
**[future]** package. All other dependencies are optional "buy-in"
dependencies as shown in the below tables.

In addition to getting access to all future-based parallel backends,
by using `futurize()` you also get access to all the benefits that
comes with **futureverse**. Notably, if the function you parallelize
output messages and warnings, they will be relayed from the parallel
worker to your main R session, just as you get when running
sequentially. This is particularly useful when troubleshooting or
debugging.


## Supported map-reduce packages

The **futurize** package supports transpilation of functions from
multiple packages. The tables below summarize the supported map-reduce
(Table 1) and domain-specific (Tables 2 and 3) functions,
respectively.  To programmatically see which packages are currently
supported, use:

```r
futurize_supported_packages()
```
To see which functions are supported for a specific package, use:

```r
futurize_supported_functions("caret")
```

| Package            | Functions                                                                                                          | Requires                 |
|--------------------|--------------------------------------------------------------------------------------------------------------------|--------------------------|
| **base**           | `lapply()`, `sapply()`, `tapply()`, `vapply()`, `mapply()`, `.mapply()`, `Map()`, `eapply()`, `apply()`, `by()`, `replicate()`, `Filter()` | **[future.apply]** |
| **stats**          | `kernapply()`                                                                                  | **[future.apply]** |
| **[purrr]**        | `map()` and variants, `map2()` and variants, `pmap()` and variants, `imap()` and variants, `modify()`, `modify_if()`, `modify_at()`, `map_if()`, `map_at()`, `invoke_map()` | **[furrr]** |
| **[crossmap]**     | `xmap()` and variants, `xwalk()`, `map_vec()`, `map2_vec()`, `pmap_vec()`, `imap_vec()`        | -                  |
| **[foreach]**      | `%do%`, e.g. `foreach() %do% { }`, `times() %do% { }`                                          | **[doFuture]**     | 
| **[plyr]**         | `aaply()` and variants, `ddply()` and variants, `llply()` and variants, `mlply()` and variants | **[doFuture]**     | 
| **[pbapply]**      | `pblapply()`, `pbsapply()` and variants, `pbby()`, `pbreplicate()` and `pbwalk()`              | **[future.apply]** |
| **[BiocParallel]** | `bplapply()`, `bpmapply()`, `bpvec()`, `bpiterate()`, `bpaggregate()`                          | **[doFuture]**     | 

_Table 1: Map-reduce functions currently supported by `futurize()` for parallel transpilation._

Here are some examples:

```r
library(futurize)
plan(multisession)

xs <- 1:10
ys <- lapply(xs, sqrt) |> futurize()

xs <- 1:10
ys <- purrr::map(xs, sqrt) |> futurize()

xs <- 1:10
ys <- crossmap::xmap_dbl(xs, ~ .y * .x) |> futurize()

library(foreach)
xs <- 1:10
ys <- foreach(x = xs) %do% { sqrt(x) } |> futurize()

xs <- 1:10
ys <- plyr::llply(xs, sqrt) |> futurize()

xs <- 1:10
ys <- pbapply::pblapply(xs, sqrt) |> futurize()

xs <- 1:10
ys <- BiocParallel::bplapply(xs, sqrt) |> futurize()
```

and

```r
ys <- replicate(3, rnorm(1)) |> futurize()

y <- by(warpbreaks, warpbreaks[,"tension"],
        function(x) lm(breaks ~ wool, data = x)) |> futurize()

xs <- EuStockMarkets[, 1:2]
k <- kernel("daniell", 50)
xs_smooth <- stats::kernapply(xs, k = k) |> futurize()
```


## Supported domain-specific packages

You can also futurize calls from a growing set of domain-specific CRAN
and Bioconductor packages that have optional built-in support for
parallelization.

### CRAN packages with support for futurize

| Package                    | Functions                                                                    | Requires           |
|----------------------------|------------------------------------------------------------------------------|--------------------|
| **[boot]**                 | `boot()`, `censboot()`, `tsboot()`                                           | -                  |
| **[caret]**                | `bag()`, `gafs()`, `nearZeroVar()`, `rfe()`, `safs()`, `sbf()`, `train()`    | **[doFuture]**     |
| **[fgsea]**                | `fgsea()`, `fgseaMultilevel()`, `fgseaSimple()`, `fgseaLabel()`, `geseca()`, `gesecaSimple()`, `collapsePathwaysGeseca()` | **[doFuture]**     |
| **[fwb]**                  | `fwb()`, `vcovFWB()`                                                         | -                  |
| **[gamlss]**               | `add1All()`, `add1TGD()`, `drop1All()`, `drop1TGD()`, `gamlssCV()`           | -                  |
| **[glmmTMB]**              | `profile()` for 'glmmTMB'                                                    | -                  |
| **[glmnet]**               | `cv.glmnet()`                                                                | **[doFuture]**     |
| **[kernelshap]**           | `kernelshap()`, `permshap()`                                                 | **[doFuture]**     |
| **[lme4]**                 | `allFit()`, `bootMer()`, `influence()` and `profile()` for 'merMod'          | -                  |
| **[metafor]**              | `profile()`, `rstudent()`, `cooks.distance()`, `dfbetas()` for 'rma' objects | -                  |
| **[mgcv]**                 | `bam()`, `predict()` for 'bam'                                               | -                  |
| **[partykit]**             | `cforest()`, `ctree_control()`, `mob_control()`, `varimp()` for 'cforest'    | **[future.apply]** |
| **[riskRegression]**       | `Score()` for 'list'                                                         | **[doFuture]**     |
| **[Rsolnp]**               | `gosolnp()`, `startpars()`                                                   | -                  |
| **[seriation]**            | `seriate_best()`, `seriate_rep()`                                            | **[doFuture]**     |
| **[shapr]**                | `explain()`, `explain_forecast()`                                            | -                  |
| **[SimDesign]**            | `runSimulation()`, `runArraySimulation()`                                    | -                  |
| **[strucchange]**          | `breakpoints()` for 'formula'                                                | **[doFuture]**     |
| **[tm]**                   | `TermDocumentMatrix()`, `tm_index()`, `tm_map()`                             | -                  |
| **[TSP]**                  | `solve_RSP()`                                                                | **[doFuture]**     |
| **[vegan]**                | `adonis()`, `adonis2()`, `anova()` for 'cca', `anosim()`, `cascadeKM()`, `estaccumR()`, `mantel()`, `mantel.partial()`, `metaMDSiter()`, `mrpp()`, `oecosimu()`, `ordiareatest()`, `permutest()` for 'betadisper', and 'cca'  | -                  |

_Table 2: CRAN packages with domain-specific functions currently
supported by `futurize()` for parallel transpilation._

Here are some examples:

```r
ratio <- function(d, w) sum(d$x * w)/sum(d$u * w)
b <- boot::boot(boot::city, ratio, R = 999) |> futurize()

ctrl <- caret::trainControl(method = "cv", number = 10)
model <- caret::train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()

f <- fwb::fwb(boot::city, ratio, R = 999) |> futurize()

cv <- gamlss::gamlssCV(y ~ pb(x), data = abdom, K.fold = 10) |> futurize()

cv <- glmnet::cv.glmnet(x, y) |> futurize()

ks <- kernelshap::kernelshap(model, X = x_explain, bg_X = bg_X) |> futurize()

m <- lme4::allFit(models) |> futurize()

fit <- metafor::rma(yi, vi)
pr <- profile(fit) |> futurize()

b <- mgcv::bam(y ~ s(x0, bs = bs) + s(x1, bs = bs), data = dat) |> futurize()

cf <- partykit::cforest(dist ~ speed, data = cars) |> futurize()

sc <- riskRegression::Score(list("CSC" = fit), data = d,
  formula = Hist(time, event) ~ 1, times = 5, B = 100,
  split.method = "bootcv") |> futurize()

result <- shapr::explain(model, x_explain, x_train, approach = "empirical", phi0 = phi0) |> futurize()

res <- Rsolnp::gosolnp(fun = gofn, LB = c(-10, -10), UB = c(10, 10), n.restarts = 5) |> futurize()

o <- seriation::seriate_best(d_supreme) |> futurize()

res <- SimDesign::runSimulation(Design, replications = 1000,
  generate = Generate, analyse = Analyse, summarise = Summarise) |> futurize()

bp <- strucchange::breakpoints(Nile ~ 1) |> futurize()
  
m <- tm::tm_map(crude, content_transformer(tolower)) |> futurize()

tour <- TSP::solve_TSP(USCA50, method = "nn", rep = 10) |> futurize()

md <- vegan::mrpp(dune, Management) |> futurize()
```


### Bioconductor packages with support for futurize

| Package                    | Functions                                                                 | Requires           |
|----------------------------|---------------------------------------------------------------------------|--------------------|
| **[DESeq2]**               | `DESeq()`, `lfcShrink()`, `results()`                                     | **[doFuture]**     |
| **[fgsea]**                | `fgsea()`, `fgseaMultilevel()`, `fgseaSimple()`, `fgseaLabel()`, `geseca()`, `gesecaSimple()`, `collapsePathwaysGeseca()` | **[doFuture]**     |
| **[GenomicAlignments]**    | `summarizeOverlaps()`                                                     | **[doFuture]**     |
| **[GSVA]**                 | `gsva()`, `gsvaRanks()`, `gsvaScores()`, `spatCor()`                      | **[doFuture]**     |
| **[Rsamtools]**            | `countBam()`, `scanBam()`                                                 | **[doFuture]**     |
| **[scater]**               | `calculatePCA()`, `calculateTSNE()`, `calculateUMAP()`, `runPCA()`, `runTSNE()`, `runUMAP()`, `runColDataPCA()`, `nexprs()`, `getVarianceExplained()`, `plotRLE()` | **[doFuture]** |
| **[scuttle]**              | `calculateAverage()`, `logNormCounts()`, `normalizeCounts()`, `perCellQCMetrics()`, `perFeatureQCMetrics()`, `addPerCellQCMetrics()`, `addPerFeatureQCMetrics()`, `addPerCellQC()`, `addPerFeatureQC()`, `numDetectedAcrossCells()`, `numDetectedAcrossFeatures()`, `sumCountsAcrossCells()`, `sumCountsAcrossFeatures()`, `summarizeAssayByGroup()`, `aggregateAcrossCells()`, `aggregateAcrossFeatures()`, `librarySizeFactors()`, `computeLibraryFactors()`, `geometricSizeFactors()`, `computeGeometricFactors()`, `medianSizeFactors()`, `computeMedianFactors()`, `pooledSizeFactors()`, `computePooledFactors()`, `fitLinearModel()` | **[doFuture]** |
| **[SingleCellExperiment]** | `applySCE()`                                                              | **[doFuture]**     |
| **[sva]**                  | `ComBat()`, `read.degradation.matrix()`                                   | **[doFuture]**     |

_Table 3: Bioconductor packages with domain-specific functions
currently supported by `futurize()` for parallel transpilation._


Here are some examples:

```r
dds <- DESeq2::DESeq(dds) |> futurize()

res <- fgsea::fgsea(pathways, stats) |> futurize()

se <- GenomicAlignments::summarizeOverlaps(features, bam_files) |> futurize()

es <- GSVA::gsva(GSVA::gsvaParam(expr, geneSets)) |> futurize()

counts <- Rsamtools::countBam(bamViews) |> futurize()

sce <- scater::runPCA(sce) |> futurize()

sce <- scuttle::logNormCounts(sce) |> futurize()

result <- SingleCellExperiment::applySCE(sce, scuttle::perCellQCMetrics) |> futurize()
  
adjusted <- sva::ComBat(dat = dat, batch = batch) |> futurize()
```



[futureverse]: https://www.futureverse.org
[future]: https://future.futureverse.org
[future.apply]: https://future.apply.futureverse.org
[furrr]: https://furrr.futureverse.org
[doFuture]: https://doFuture.futureverse.org
[TSP]: https://cran.r-project.org/package=TSP
[boot]: https://cran.r-project.org/package=boot
[caret]: https://cran.r-project.org/package=caret
[crossmap]: https://cran.r-project.org/package=crossmap
[DESeq2]: https://bioconductor.org/packages/DESeq2/
[fgsea]: https://bioconductor.org/packages/fgsea/
[foreach]: https://cran.r-project.org/package=foreach
[fwb]: https://ngreifer.github.io/fwb/
[gamlss]: https://cran.r-project.org/package=gamlss
[glmmTMB]: https://cran.r-project.org/package=glmmTMB
[glmnet]: https://cran.r-project.org/package=glmnet
[GenomicAlignments]: https://bioconductor.org/packages/GenomicAlignments/
[GSVA]: https://bioconductor.org/packages/GSVA/
[kernelshap]: https://cran.r-project.org/package=kernelshap
[lme4]: https://cran.r-project.org/package=lme4
[metafor]: https://cran.r-project.org/package=metafor
[mgcv]: https://cran.r-project.org/package=mgcv
[partykit]: https://cran.r-project.org/package=partykit
[pbapply]: https://cran.r-project.org/package=pbapply
[plyr]: https://cran.r-project.org/package=plyr
[purrr]: https://cran.r-project.org/package=purrr
[riskRegression]: https://cran.r-project.org/package=riskRegression
[Rsamtools]: https://bioconductor.org/packages/Rsamtools/
[Rsolnp]: https://cran.r-project.org/package=Rsolnp
[scater]: https://bioconductor.org/packages/scater/
[scuttle]: https://bioconductor.org/packages/scuttle/
[SingleCellExperiment]: https://bioconductor.org/packages/SingleCellExperiment/
[seriation]: https://cran.r-project.org/package=seriation
[shapr]: https://cran.r-project.org/package=shapr
[SimDesign]: https://cran.r-project.org/package=SimDesign
[strucchange]: https://cran.r-project.org/package=strucchange
[sva]: https://bioconductor.org/packages/sva/
[tm]: https://cran.r-project.org/package=tm
[vegan]: https://cran.r-project.org/package=vegan
[BiocParallel]: https://bioconductor.org/packages/BiocParallel/
[supported future backends]: https://www.futureverse.org/backends.html
