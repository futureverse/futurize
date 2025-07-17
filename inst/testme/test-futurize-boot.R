if (requireNamespace("boot") && requireNamespace("future.ideas")) {
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
b <- boot(city, ratio, R = 999, stype = "w") |> futurize()
print(b)

stopifnot(all_equal(b, b_truth))

plan(sequential)
} ## if (requireNamespace("boot"))
