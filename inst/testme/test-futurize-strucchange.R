if (requireNamespace("strucchange")) {
library(futurize)
library(strucchange)
options(future.rng.onMisuse = "error")

plan(multisession)

data("Nile")

bp_truth <- breakpoints(Nile ~ 1)
print(bp_truth)

bp <- breakpoints(Nile ~ 1) |> futurize()
print(bp)

common <- setdiff(names(bp), c("RSS", "extract.breaks", "extend.RSS.table", "nobs", "call", "datatsp"))
stopifnot(all.equal(bp[common], bp_truth[common]))

plan(sequential)
} ## if (requireNamespace("strucchange"))
