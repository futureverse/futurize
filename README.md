# futurize: Parallelize Common Apply Functions via One Magic Function

The **futurize** package makes it extremely simple to parallelize your
existing apply-like, map-reduce calls. All you need to know is that
there is a single function called `futurize()` that will take care of
everything. Here are some examples how you could use it:

```r
library(futurize)
plan(multisession)

xs <- 1:10
y <- lapply(xs, sqrt) |> futurize()

xs <- 1:10
y <- map(xs, sqrt) |> futurize()

xs <- 1:10
y <- foreach(x = xs) %do% { sqrt(x) } |> futurize()
```
