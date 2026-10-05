#' @tags skip_on_cran  ## (20s) to limit total check time
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
sc <- Score(list("CSC" = fit), data = d,
            formula = Hist(time, event) ~ 1,
            times = 5, B = 10, split.method = "bootcv",
            seed = 42) |> futurize_and_verify()
print(sc)

## The S3 dispatch argument list(...) must not comprise function calls,
## because they would be evaluated twice
n_fits <- 0L
fit_model <- function() {
  n_fits <<- n_fits + 1L
  fit
}
res <- tryCatch({
  Score(list("CSC" = fit_model()), data = d,
        formula = Hist(time, event) ~ 1,
        times = 5, B = 10, split.method = "bootcv",
        seed = 42) |> futurize()
}, error = identity)
print(res)
stopifnot(
  inherits(res, "error"),
  grepl("not a variable", conditionMessage(res)),
  n_fits == 0L
)

plan(sequential)
} ## if (requireNamespace("riskRegression"))
