if (requireNamespace("boot") && getRversion() >= "4.4.0") {
library(futurize)
library(boot)
options(future.rng.onMisuse = "error")

all_equal <- function(a, b, ...) {
  a$call <- b$call <- NULL
  all.equal(a, b, ...)
}

plan(multisession)

## Adopted from example("boot", package = "boot")
ratio <- function(d, w) {
  sum(d$x * w)/sum(d$u * w)
}

set.seed(42)
b_truth <- boot(city, ratio, R = 999, stype = "w")
print(b_truth)

set.seed(42)
counters <- plan("backend")[["counters"]]
b <- boot(city, ratio, R = 999, stype = "w") |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(b)

stopifnot(all_equal(b, b_truth))

plan(sequential)
} ## if (requireNamespace("boot"))
