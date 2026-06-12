#' @tags pkg-partykit
if (requireNamespace("partykit") && requireNamespace("future.apply")) {
library(futurize)
library(partykit)
options(future.rng.onMisuse = "error")

plan(multisession)

RNGkind("L'Ecuyer-CMRG")
set.seed(42)
cf_truth <- partykit::cforest(dist ~ speed, data = cars, ntree = 10L)
print(summary(cf_truth))

set.seed(42)
cf <- partykit::cforest(dist ~ speed, data = cars, ntree = 10L) |> futurize_and_verify()
print(summary(cf))

stopifnot(
  all.equal(summary(cf), summary(cf_truth))
)

## Prediction
nd_truth <- data.frame(speed = 4:25)
nd_truth$mean  <- predict(cf_truth, newdata = nd_truth, type = "response")

nd <- data.frame(speed = 4:25)
nd$mean  <- predict(cf, newdata = nd, type = "response")

stopifnot(
  all.equal(nd, nd_truth)
)

plan(sequential)
} ## if (requireNamespace("partykit"))
