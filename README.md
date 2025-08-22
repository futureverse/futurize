<div id="badges"><!-- pkgdown markup -->
<a href="https://github.com/futureverse/futurize/actions?query=workflow%3AR-CMD-check"><img border="0" src="https://github.com/futureverse/futurize/actions/workflows/R-CMD-check.yaml/badge.svg?branch=develop" alt="R CMD check status"/></a>
</div>


# futurize: Parallelize Common Functions via One Magic Function <img border="0" src="man/figures/futurize-magic-touch-parallelization-120x138.png" alt="The 'future' hexlogo" align="right"/>

The **futurize** package makes it extremely simple to parallelize your
existing apply-like, map-reduce calls. All you need to know is that
there is a single function called `futurize()` that will take care of
everything. 

It supports base R apply functions, **purrr**, **foreach**, **plyr**,
and **BiocParallel**. Here are some examples how you could use it:

```r
library(futurize)
plan(multisession)

xs <- 1:10
y <- lapply(xs, sqrt) |> futurize()

xs <- 1:10
y <- purrr::map(xs, sqrt) |> futurize()

xs <- 1:10
y <- crossmap::xmap_dbl(xs, ~ .y * .x) |> futurize()

xs <- 1:10
y <- foreach(x = xs) %do% { sqrt(x) } |> futurize()

xs <- 1:10
y <- plyr::llply(xs, sqrt) |> futurize()

xs <- 1:10
y <- BiocParallel::bplapply(xs, sqrt) |> futurize()
```

and

```r
y <- replicate(3, rnorm(1)) |> futurize()

y <- by(warpbreaks, warpbreaks[,"tension"],
        function(x) lm(breaks ~ wool, data = x)) |> futurize()

xs <- EuStockMarkets[, 1:2]
k <- kernel("daniell", 50)
xs_smooth <- stats::kernapply(xs, k = k) |> futurize()
```

You can also futurize calls to several packages (e.g. **boot**,
**caret**, **glmnet**, **lme4**, and **tm**) that have optional
built-in support for parallelization, e.g.

```r
model <- caret::train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()

b <- boot::boot(city, ratio, R = 999) |> futurize()

cv <- glmnet::cv.glmnet(x, y) |> futurize()

m <- lme4::allFit(models) |> futurize()

m <- tm::tm_map(crude, content_transformer(tolower)) |> futurize()
```
