#' @tags pkg-gamlss
if (requireNamespace("gamlss") && getRversion() >= "4.4.0") {
library(futurize)
library(gamlss)
options(future.rng.onMisuse = "ignore")

plan(multisession)

## -------------------------------------------------------------------
## gamlssCV() - k-fold cross-validation
## -------------------------------------------------------------------
## Adopted from help("gamlssCV", package = "gamlss")
data(abdom, package = "gamlss.data")

set.seed(42)
cv_truth <- gamlssCV(y ~ pb(x), data = abdom, K.fold = 5)
cat(sprintf("CV truth: %s\n", paste(cv_truth, collapse = ", ")))

set.seed(42)
counters <- plan("backend")[["counters"]]
cv <- gamlssCV(y ~ pb(x), data = abdom, K.fold = 5) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created (gamlssCV): %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
cat(sprintf("CV futurized: %s\n", paste(cv, collapse = ", ")))

stopifnot(all.equal(cv, cv_truth))

## -------------------------------------------------------------------
## drop1All() - drop terms from model
## -------------------------------------------------------------------
set.seed(42)
m <- gamlss(y ~ pb(x) + x, data = abdom)

drop_truth <- drop1All(m, trace = FALSE)
print(drop_truth)

counters <- plan("backend")[["counters"]]
drop_res <- drop1All(m, trace = FALSE) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created (drop1All): %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(drop_res)

plan(sequential)
} ## if (requireNamespace("gamlss"))
