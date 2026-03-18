if (requireNamespace("strucchange") && requireNamespace("doFuture")) {
library(futurize)
library(strucchange)
options(future.rng.onMisuse = "error")

plan(multisession)

data("Nile")

bp_truth <- breakpoints(Nile ~ 1)
print(bp_truth)

counters <- plan("backend")[["counters"]]
bp <- breakpoints(Nile ~ 1) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(bp)

common <- setdiff(names(bp), c("RSS", "extract.breaks", "extend.RSS.table", "nobs", "call", "datatsp"))
stopifnot(all.equal(bp[common], bp_truth[common]))

plan(sequential)
} ## if (requireNamespace("strucchange"))
