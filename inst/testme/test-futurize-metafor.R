if (requireNamespace("metafor") && getRversion() >= "4.4.0") {
library(futurize)
library(metafor)

plan(multisession)

## -------------------------------------------------------------------
## profile() - profile likelihood plots for rma objects
## -------------------------------------------------------------------
## Example from help("rma", package = "metafor")
dat <- escalc(measure = "RR", ai = tpos, bi = tneg,
              ci = cpos, di = cneg, data = dat.bcg)
fit <- rma(yi, vi, data = dat)

counters <- plan("backend")[["counters"]]
prof <- profile(fit) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created (profile): %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(prof)

plan(sequential)
} ## if (requireNamespace("metafor"))
