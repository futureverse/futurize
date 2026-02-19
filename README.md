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


## Supported calls

### Supported map-reduce packages

The **futurize** package supports transpilation of functions from multiple packages. The tables below summarize the supported map-reduce (Table 1) and domain-specific (Table 2) functions, respectively.  To programmatically see which packages are currently supported, use:

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
| **[crossmap]**     | `xmap()` and variants, `xwalk()`, `map_vec()`, `map2_vec()`, `pmap_vec()`, `imap_vec()`        | (itself)           |
| **[foreach]**      | `%do%`, e.g. `foreach() %do% { }`, `times() %do% { }`                                          | **[doFuture]**     | 
| **[plyr]**         | `aaply()` and variants, `ddply()` and variants, `llply()` and variants, `mlply()` and variants | **[doFuture]**     | 
| **[pbapply]**      | `pblapply()`, `pbsapply()` and variants, `pbby()`, `pbreplicate()` and `pbwalk()`              | (itself)           | 
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


### Supported domain-specific packages

You can also futurize calls from a growing set of domain-specific
packages that have optional built-in support for parallelization.


| Package           | Functions                                                                 | Requires           |
|-------------------|---------------------------------------------------------------------------|--------------------|
| **[boot]**        | `boot()`, `censboot()`, `tsboot()`                                        | **[future]**       |
| **[caret]**       | `bag()`, `gafs()`, `nearZeroVar()`, `rfe()`, `safs()`, `sbf()`, `train()` | **[doFuture]**     |
| **[fwb]**         | `fwb()`, `vcovFWB()`                                                      | (itself)           |
| **[glmnet]**      | `cv.glmnet()`                                                             | **[doFuture]**     |
| **[lme4]**        | `allFit()`, `bootMer()`                                                   | **[future]**       |
| **[mgcv]**        | `bam()`, `predict.bam()`                                                  | **[future]**       |
| **[partykit]**    | `cforest()`, `ctree_control()`, `mob_control()`, `varimp.cforest()`       | **[future.apply]** |
| **[strucchange]** | `breakpoints()`                                                           | **[doFuture]**     |
| **[tm]**          | `TermDocumentMatrix()`, `tm_index()`, `tm_map()`                          | **[future]**       |

_Table 2: Domain-specific functions currently supported by `futurize()` for parallel transpilation._

Here are some examples:

```r
ctrl <- caret::trainControl(method = "cv", number = 10)
model <- caret::train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()

ratio <- function(d, w) sum(d$x * w)/sum(d$u * w)
b <- boot::boot(boot::city, ratio, R = 999) |> futurize()

f <- fwb::fwb(boot::city, ratio, R = 999) |> futurize()

cv <- glmnet::cv.glmnet(x, y) |> futurize()

m <- lme4::allFit(models) |> futurize()

b <- mgcv::bam(y ~ s(x0, bs = bs) + s(x1, bs = bs), data = dat) |> futurize()

cf <- partykit::cforest(dist ~ speed, data = cars) |> futurize()

bp <- strucchange::breakpoints(Nile ~ 1) |> futurize()
  
m <- tm::tm_map(crude, content_transformer(tolower)) |> futurize()
```



[futureverse]: https://www.futureverse.org
[future]: https://future.futureverse.org
[future.apply]: https://future.apply.futureverse.org
[furrr]: https://furrr.futureverse.org
[doFuture]: https://doFuture.futureverse.org
[purrr]: https://cran.r-project.org/package=purrr
[crossmap]: https://cran.r-project.org/package=crossmap
[foreach]: https://cran.r-project.org/package=foreach
[pbapply]: https://cran.r-project.org/package=pbapply
[plyr]: https://cran.r-project.org/package=plyr
[boot]: https://cran.r-project.org/package=boot
[fwb]: https://ngreifer.github.io/fwb/
[mgcv]: https://cran.r-project.org/package=mgcv
[caret]: https://cran.r-project.org/package=caret
[glmnet]: https://cran.r-project.org/package=glmnet
[lme4]: https://cran.r-project.org/package=lme4
[partykit]: https://cran.r-project.org/package=partykit
[strucchange]: https://cran.r-project.org/package=strucchange
[tm]: https://cran.r-project.org/package=tm
[fwb]: https://ngreifer.github.io/fwb/
[BiocParallel]: https://bioconductor.org/packages/BiocParallel/
[supported future backends]: https://www.futureverse.org/backends.html
