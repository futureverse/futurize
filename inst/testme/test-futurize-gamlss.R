#' @tags skip_on_cran  ## to limit total check time
#' @tags pkg-gamlss
if (requireNamespace("gamlss") && requireNamespace("gamlss.data") && getRversion() >= "4.4.0") {
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
cv <- gamlssCV(y ~ pb(x), data = abdom, K.fold = 5) |> futurize_and_verify()
cat(sprintf("CV futurized: %s\n", paste(cv, collapse = ", ")))

stopifnot(all.equal(cv, cv_truth))

## -------------------------------------------------------------------
## drop1All() - drop terms from model
## -------------------------------------------------------------------
set.seed(42)
m <- gamlss(y ~ pb(x) + x, data = abdom)

drop_truth <- drop1All(m, trace = FALSE)
print(drop_truth)

drop_res <- drop1All(m, trace = FALSE) |> futurize_and_verify()
print(drop_res)

plan(sequential)
} ## if (requireNamespace("gamlss"))
