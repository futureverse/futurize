if (requireNamespace("seriation") && requireNamespace("doFuture")) {
library(futurize)
library(seriation)
options(future.rng.onMisuse = "error")

plan(multisession)

data(SupremeCourt)
d_supreme <- as.dist(SupremeCourt)


message("*** seriate_rep()")

RNGkind("L'Ecuyer-CMRG")
set.seed(42)
o_truth <- seriate_rep(d_supreme, "QAP_LS", rep = 5L)
print(o_truth)
set.seed(42)
counters <- plan("backend")[["counters"]]
o <- seriate_rep(d_supreme, "QAP_LS", rep = 5L) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(o)

## seriate_rep() does not allow for RNG reproducibility
o[[1]] <- o_truth[[1]]
stopifnot(all.equal(o, o_truth, tolerance = 0.01))


message("*** seriate_best()")

RNGkind("L'Ecuyer-CMRG")
set.seed(42)
o_truth <- seriate_best(d_supreme, criterion = "AR_events")
print(o_truth)
set.seed(42)
counters <- plan("backend")[["counters"]]
o <- seriate_best(d_supreme, criterion = "AR_events") |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(o)
attr(o, "time") <- attr(o_truth, "time")
stopifnot(all.equal(o, o_truth))


plan(sequential)
} ## if (requireNamespace("seriation"))
