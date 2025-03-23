# futurize: Parallelize Common Apply Function


```r
library(futurize)

xs <- 1:10
y <- lapply(xs, sqrt) |> futurize()

xs <- 1:10
y <- map(xs, sqrt) |> futurize()

xs <- 1:10
y <- foreach(x = xs) %dopar% { sqrt(x) } |> futurize()
```
