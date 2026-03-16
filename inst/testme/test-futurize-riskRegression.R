if (requireNamespace("riskRegression") && requireNamespace("survival") && requireNamespace("doFuture")) {
library(futurize)
library(riskRegression)
library(survival)
options(future.rng.onMisuse = "error")

plan(multisession)

## -------------------------------------------------------------------
## Score() - bootstrap cross-validation
## -------------------------------------------------------------------
set.seed(42)
d <- sampleData(200, outcome = "competing.risks")
fit <- CSC(Hist(time, event) ~ X1 + X2 + X7 + X8, data = d)

set.seed(42)
sc_truth <- Score(list("CSC" = fit), data = d,
                  formula = Hist(time, event) ~ 1,
                  times = 5, B = 10, split.method = "bootcv",
                  seed = 42)
print(sc_truth)

set.seed(42)
counters <- plan("backend")[["counters"]]
sc <- Score(list("CSC" = fit), data = d,
            formula = Hist(time, event) ~ 1,
            times = 5, B = 10, split.method = "bootcv",
            seed = 42) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created (Score): %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(sc)

plan(sequential)
} ## if (requireNamespace("riskRegression"))
