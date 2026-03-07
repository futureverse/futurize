if (requireNamespace("partykit") && requireNamespace("future.apply")) {
library(futurize)
library(partykit)
options(future.rng.onMisuse = "error")

plan(multisession)

RNGkind("L'Ecuyer-CMRG")
set.seed(42)
cf_truth <- partykit::cforest(dist ~ speed, data = cars)
print(summary(cf_truth))

set.seed(42)
cf_future.apply <- partykit::cforest(dist ~ speed, data = cars, applyfun = function(...) {
  future.apply::future_lapply(..., future.seed = TRUE)
})
print(summary(cf_future.apply))

set.seed(42)
cf <- partykit::cforest(dist ~ speed, data = cars) |> futurize::futurize()
print(summary(cf))

stopifnot(
  all.equal(summary(cf), summary(cf_truth)),
  all.equal(summary(cf), summary(cf_future.apply))
)

## Prediction
nd_truth <- data.frame(speed = 4:25)
nd_truth$mean  <- predict(cf_truth, newdata = nd_truth, type = "response")

nd_future.apply <- data.frame(speed = 4:25)
nd_future.apply$mean  <- predict(cf_future.apply, newdata = nd_future.apply, type = "response")

nd <- data.frame(speed = 4:25)
nd$mean  <- predict(cf, newdata = nd, type = "response")

stopifnot(
  all.equal(nd, nd_truth),
  all.equal(nd, nd_future.apply)
)


plan(sequential)
} ## if (requireNamespace("partykit"))
