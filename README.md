<div id="badges"><!-- pkgdown markup -->
<a href="https://github.com/futureverse/futurize/actions?query=workflow%3AR-CMD-check"><img border="0" src="https://github.com/futureverse/futurize/actions/workflows/R-CMD-check.yaml/badge.svg?branch=develop" alt="R CMD check status"/></a>
</div>


# futurize: Parallelize Common Functions via One Magic Function <img border="0" src="man/figures/futurize-logo.png" style="width: 120px; margin: 2ex;" alt="The 'futurize' hexlogo" align="right"/>

The **futurize** package makes it extremely simple to parallelize your
existing apply-like, map-reduce calls. All you need to know is that
there is a single function called `futurize()` that will take care of
everything. 

It supports base R apply functions, **purrr**, **crossmap**, **plyr**,
**foreach**, and **BiocParallel**. Here are some examples how you
could use it:

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

You can also futurize calls from a growing set of domain-specific
packages (e.g. **boot**, **caret**, **glmnet**, **lme4**, **mgcv**,
and **tm**) that have optional built-in support for parallelization.
Here are some examples:

```r
ctrl <- caret::trainControl(method = "cv", number = 10)
model <- caret::train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()

ratio <- function(d, w) sum(d$x * w)/sum(d$u * w)
b <- boot::boot(boot::city, ratio, R = 999) |> futurize()

cv <- glmnet::cv.glmnet(x, y) |> futurize()

m <- lme4::allFit(models) |> futurize()

b <- mgcv::bam(y ~ s(x0, bs = bs) + s(x1, bs = bs), data = dat) |> futurize()

m <- tm::tm_map(crude, content_transformer(tolower)) |> futurize()
```
