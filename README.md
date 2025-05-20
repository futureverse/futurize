# futurize: Parallelize Common Apply Functions via One Magic Function

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
y <- foreach(x = xs) %do% { sqrt(x) } |> futurize()

xs <- 1:10
y <- plyr::llply(xs, sqrt) |> futurize()

xs <- 1:10
y <- BiocParallel::bplapply(xs, sqrt) |> futurize()
```


You can also futurize calls to several packages that have optional
built-in support for parallelization, e.g.

```r
cv <- glmnet::cv.glmnet(x, y) |> futurize(seed = TRUE)

b <- boot(city, ratio, R = 999) |> futurize()
```
