# futurize: Parallelize Common Functions via One Magic Function ![The 'futurize' hexlogo](reference/figures/futurize-logo.png)

## TL;DR

The **futurize** package makes it extremely simple to parallelize your
existing map-reduce calls, but also a growing set of domain-specific
calls. All you need to know is that there is a single function called
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
that will take care of everything, e.g.

``` r

y <- lapply(x, fcn) |> futurize()
y <- map(x, fcn) |> futurize()
b <- boot(city, ratio, R = 999) |> futurize()
```

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
you also get access to all the benefits that comes with **futureverse**.
Notably, if the function you parallelize output messages and warnings,
they will be relayed from the parallel worker to your main R session,
just as you get when running sequentially. This is particularly useful
when troubleshooting or debugging.

## Supported calls

### Supported map-reduce packages

The **futurize** package supports transpilation of functions from
multiple packages. The tables below summarize the supported map-reduce
(Table 1) and domain-specific (Table 2) functions, respectively. To
programmatically see which packages are currently supported, use:

``` r

futurize_supported_packages()
```

To see which functions are supported for a specific package, use:

``` r

futurize_supported_functions("caret")
```

| Package | Functions | Requires |
|----|----|----|
| **base** | [`lapply()`](https://rdrr.io/r/base/lapply.html), [`sapply()`](https://rdrr.io/r/base/lapply.html), [`tapply()`](https://rdrr.io/r/base/tapply.html), [`vapply()`](https://rdrr.io/r/base/lapply.html), [`mapply()`](https://rdrr.io/r/base/mapply.html), [`.mapply()`](https://rdrr.io/r/base/mapply.html), [`Map()`](https://rdrr.io/r/base/funprog.html), [`eapply()`](https://rdrr.io/r/base/eapply.html), [`apply()`](https://rdrr.io/r/base/apply.html), [`by()`](https://rdrr.io/r/base/by.html), [`replicate()`](https://rdrr.io/r/base/lapply.html), [`Filter()`](https://rdrr.io/r/base/funprog.html) | **[future.apply](https://future.apply.futureverse.org)** |
| **stats** | [`kernapply()`](https://rdrr.io/r/stats/kernapply.html) | **[future.apply](https://future.apply.futureverse.org)** |
| **[purrr](https://cran.r-project.org/package=purrr)** | `map()` and variants, `map2()` and variants, `pmap()` and variants, `imap()` and variants, `modify()`, `modify_if()`, `modify_at()`, `map_if()`, `map_at()`, `invoke_map()` | **[furrr](https://furrr.futureverse.org)** |
| **[crossmap](https://cran.r-project.org/package=crossmap)** | `xmap()` and variants, `xwalk()`, `map_vec()`, `map2_vec()`, `pmap_vec()`, `imap_vec()` | \- |
| **[foreach](https://cran.r-project.org/package=foreach)** | `%do%`, e.g. `foreach() %do% { }`, `times() %do% { }` | **[doFuture](https://doFuture.futureverse.org)** |
| **[plyr](https://cran.r-project.org/package=plyr)** | `aaply()` and variants, `ddply()` and variants, `llply()` and variants, `mlply()` and variants | **[doFuture](https://doFuture.futureverse.org)** |
| **[pbapply](https://cran.r-project.org/package=pbapply)** | `pblapply()`, `pbsapply()` and variants, `pbby()`, `pbreplicate()` and `pbwalk()` | **[future.apply](https://future.apply.futureverse.org)** |
| **[BiocParallel](https://bioconductor.org/packages/BiocParallel/)** | `bplapply()`, `bpmapply()`, `bpvec()`, `bpiterate()`, `bpaggregate()` | **[doFuture](https://doFuture.futureverse.org)** |

*Table 1: Map-reduce functions currently supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
for parallel transpilation.*

Here are some examples:

``` r

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

``` r

ys <- replicate(3, rnorm(1)) |> futurize()

y <- by(warpbreaks, warpbreaks[,"tension"],
        function(x) lm(breaks ~ wool, data = x)) |> futurize()

xs <- EuStockMarkets[, 1:2]
k <- kernel("daniell", 50)
xs_smooth <- stats::kernapply(xs, k = k) |> futurize()
```

### Supported domain-specific packages

You can also futurize calls from a growing set of domain-specific
packages that have optional built-in support for parallelization.

| Package | Functions | Requires |
|----|----|----|
| **[boot](https://cran.r-project.org/package=boot)** | `boot()`, `censboot()`, `tsboot()` | \- |
| **[caret](https://cran.r-project.org/package=caret)** | `bag()`, `gafs()`, `nearZeroVar()`, `rfe()`, `safs()`, `sbf()`, `train()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[DESeq2](https://bioconductor.org/packages/DESeq2/)** | `DESeq()`, `lfcShrink()`, `results()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[fwb](https://ngreifer.github.io/fwb/)** | `fwb()`, `vcovFWB()` | \- |
| **[glmnet](https://cran.r-project.org/package=glmnet)** | `cv.glmnet()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[glmmTMB](https://cran.r-project.org/package=glmmTMB)** | `"confint()` and [`profile()`](https://rdrr.io/r/stats/profile.html) for ‘glmmTMB’ | \- |
| **[lme4](https://cran.r-project.org/package=lme4)** | `allFit()`, `bootMer()`, [`influence()`](https://rdrr.io/r/stats/lm.influence.html) and [`profile()`](https://rdrr.io/r/stats/profile.html) for ‘merMod’ | \- |
| **[mgcv](https://cran.r-project.org/package=mgcv)** | `bam()`, [`predict()`](https://rdrr.io/r/stats/predict.html) for ‘bam’ | \- |
| **[mice](https://cran.r-project.org/package=mice)** | `mice()` | \- |
| **[partykit](https://cran.r-project.org/package=partykit)** | `cforest()`, `ctree_control()`, `mob_control()`, `varimp()` for ‘cforest’ | **[future.apply](https://future.apply.futureverse.org)** |
| **[scater](https://bioconductor.org/packages/scater/)** | `calculatePCA()`, `calculateTSNE()`, `calculateUMAP()`, `runPCA()`, `runTSNE()`, `runUMAP()`, `runColDataPCA()`, `nexprs()`, `getVarianceExplained()`, `plotRLE()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[seriation](https://cran.r-project.org/package=seriation)** | `seriate_best()`, `seriate_rep()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[strucchange](https://cran.r-project.org/package=strucchange)** | `breakpoints()` for ‘formula’ | **[doFuture](https://doFuture.futureverse.org)** |
| **[tm](https://cran.r-project.org/package=tm)** | `TermDocumentMatrix()`, `tm_index()`, `tm_map()` | \- |
| **[TSP](https://cran.r-project.org/package=TSP)** | `solve_RSP()` | **[doFuture](https://doFuture.futureverse.org)** |
| **[vegan](https://cran.r-project.org/package=vegan)** | `adonis()`, `adonis2()`, `anosim()`, `cascadeKM()`, `estaccumR()`, `mantel()`, `mantel.partial()`, `metaMDSiter()`, `mrpp()`, `oecosimu()`, `ordiareatest()`, `permutest()` for ‘betadisper’, and ‘cca’, `simper()` | \- |

*Table 2: Domain-specific functions currently supported by
[`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
for parallel transpilation.*

Here are some examples:

``` r

ctrl <- caret::trainControl(method = "cv", number = 10)
model <- caret::train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()

ratio <- function(d, w) sum(d$x * w)/sum(d$u * w)
b <- boot::boot(boot::city, ratio, R = 999) |> futurize()

f <- fwb::fwb(boot::city, ratio, R = 999) |> futurize()

dds <- DESeq2::DESeq(dds) |> futurize()

sce <- scater::runPCA(sce) |> futurize()

cv <- glmnet::cv.glmnet(x, y) |> futurize()

m <- lme4::allFit(models) |> futurize()

imp <- mice::mice(nhanes, m = 5) |> futurize()

b <- mgcv::bam(y ~ s(x0, bs = bs) + s(x1, bs = bs), data = dat) |> futurize()

cf <- partykit::cforest(dist ~ speed, data = cars) |> futurize()

o <- seriation::seriate_best(d_supreme) |> futurize()

bp <- strucchange::breakpoints(Nile ~ 1) |> futurize()
  
m <- tm::tm_map(crude, content_transformer(tolower)) |> futurize()

tour <- TSP::solve_TSP(USCA50, method = "nn", rep = 10) |> futurize()

md <- vegan::mrpp(dune, Management) |> futurize()
```
