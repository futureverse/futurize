if (requireNamespace("TSP")) {
library(futurize)
library(TSP)
options(future.rng.onMisuse = "error")

plan(multisession)

data("USCA50")
methods <- c("identity", "random", "nearest_insertion", "cheapest_insertion", "farthest_insertion", "arbitrary_insertion", "nn", "repetitive_nn", "two_opt", "sa")

## calculate tours
tours <- lapply(methods, FUN = function(m) solve_TSP(USCA50, method = m))
names(tours) <- methods

RNGkind("L'Ecuyer-CMRG")

set.seed(42)
y_truth <- solve_TSP(USCA50, method = "nn", rep = 10L)
print(y_truth)

set.seed(42)
y <- solve_TSP(USCA50, method = "nn", rep = 10L) |> futurize()
print(y)

set.seed(42)
y2 <- solve_TSP(USCA50, method = "nn", rep = 10L) |> futurize()
print(y2)
stopifnot(all.equal(y2, y))

plan(sequential)

set.seed(42)
y3 <- solve_TSP(USCA50, method = "nn", rep = 10L) |> futurize()
print(y3)
stopifnot(all.equal(y3, y))

} ## if (requireNamespace("TSP"))
