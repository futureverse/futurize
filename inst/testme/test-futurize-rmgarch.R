if (requireNamespace("rmgarch") && requireNamespace("rugarch") && getRversion() >= "4.4.0") {
library(futurize)
library(rmgarch)
library(rugarch)

plan(multisession)

## -------------------------------------------------------------------
## dccfit() - DCC-GARCH model fitting
## -------------------------------------------------------------------
## Use a small simulated dataset for speed
set.seed(42)
n <- 300L
dat <- matrix(rnorm(n * 2L), ncol = 2L)
colnames(dat) <- c("x1", "x2")

## Create univariate GARCH(1,1) specs
uspec <- ugarchspec(
  mean.model = list(armaOrder = c(0, 0)),
  variance.model = list(garchOrder = c(1, 1))
)
mspec <- multispec(replicate(2, uspec))

## DCC(1,1) specification
spec <- dccspec(uspec = mspec, dccOrder = c(1, 1),
                distribution = "mvnorm")

## Truth (sequential)
set.seed(42)
fit_truth <- dccfit(spec, data = dat)
cat(sprintf("DCC fit (truth): %s\n", class(fit_truth)))

## Futurized
set.seed(42)
counters <- plan("backend")[["counters"]]
fit <- dccfit(spec, data = dat) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created (dccfit): %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
cat(sprintf("DCC fit (futurized): %s\n", class(fit)))

## Compare fitted coefficients
stopifnot(all.equal(coef(fit), coef(fit_truth)))

plan(sequential)
} ## if (requireNamespace("rmgarch"))
