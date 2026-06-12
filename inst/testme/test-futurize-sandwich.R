#' @tags pkg-sandwich
if (requireNamespace("sandwich") && requireNamespace("future.apply")) {
library(futurize)
library(sandwich)
options(future.rng.onMisuse = "error")

plan(multisession, workers = 2L)

RNGkind("L'Ecuyer-CMRG")

fm <- lm(dist ~ speed, data = cars)

## Truth (sequential lapply)
## Since the non-parallel version uses a different set of RNG seeds
## than the parallel versions, we will not get numerically identical
## results
#set.seed(42)
#vcov_truth <- sandwich::vcovBS(fm, R = 5L)

## futurize()
set.seed(42)
vcov <- sandwich::vcovBS(fm, R = 5L) |> futurize()

stopifnot(
  is.matrix(vcov),
  all(dim(vcov) == c(2, 2))
)

## vcovJK()
set.seed(42)
vcov_jk <- sandwich::vcovJK(fm) |> futurize()
stopifnot(
  is.matrix(vcov_jk),
  all(dim(vcov_jk) == c(2, 2))
)

plan(sequential)
}
