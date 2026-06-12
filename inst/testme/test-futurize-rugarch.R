#' @tags pkg-rugarch
if (requireNamespace("rugarch") && getRversion() >= "4.4.0") {
library(futurize)
library(rugarch)
options(future.rng.onMisuse = "error")

plan(multisession)

#------------------------------------------------------------------
# ugarchroll()
#------------------------------------------------------------------
message("ugarchroll() ...")

data(sp500ret, package = "rugarch")
spec <- ugarchspec()

## Small example to keep it fast
sp500ret_small <- sp500ret[1:100, , drop = FALSE]
n_start <- 50

set.seed(42)
roll_truth <- ugarchroll(spec, sp500ret_small, n.start = n_start, refit.window = "moving", refit.every = 25)
print(roll_truth)

set.seed(42)
roll <- ugarchroll(spec, sp500ret_small, n.start = n_start, refit.window = "moving", refit.every = 25) |> futurize_and_verify()
print(roll)

## rugarch objects might have some environment or pointer differences, 
## but let's see if all.equal works.
roll@model$elapsed <- NULL
roll_truth@model$elapsed <- NULL
roll@model$con_Args$cluster <- NULL
roll_truth@model$con_Args$cluster <- NULL
stopifnot(all.equal(roll, roll_truth))

message("ugarchroll() ... done")

plan(sequential)
}
