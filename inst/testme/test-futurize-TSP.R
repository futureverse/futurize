if (requireNamespace("TSP") && requireNamespace("doFuture")) {
library(futurize)
library(TSP)
options(future.rng.onMisuse = "error")

plan(multisession)

data("USCA50")

RNGkind("L'Ecuyer-CMRG")

set.seed(42)
y_truth <- solve_TSP(USCA50, method = "nn", rep = 10L)
print(y_truth)

set.seed(42)
counters <- plan("backend")[["counters"]]
y <- solve_TSP(USCA50, method = "nn", rep = 10L) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(y)

set.seed(42)
counters <- plan("backend")[["counters"]]
y2 <- solve_TSP(USCA50, method = "nn", rep = 10L) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(y2)
stopifnot(all.equal(y2, y))

plan(sequential)

set.seed(42)
y3 <- solve_TSP(USCA50, method = "nn", rep = 10L) |> futurize()
print(y3)
stopifnot(all.equal(y3, y))

} ## if (requireNamespace("TSP"))
