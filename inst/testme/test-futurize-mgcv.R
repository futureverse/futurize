#' @tags pkg-mgcv
if (requireNamespace("mgcv") && getRversion() >= "4.4.0") {
library(futurize)
library(mgcv)
options(future.rng.onMisuse = "error")

plan(multisession)

dat <- gamSim(1, n = 25000, dist = "normal", scale = 20)
bs <- "cr"
k <- 12

b_truth <- bam(y ~ s(x0, bs = bs) + s(x1, bs = bs) + s(x2, bs = bs, k = k) + s(x3, bs = bs), data = dat)
print(b_truth)

counters <- plan("backend")[["counters"]]
b <- bam(y ~ s(x0, bs = bs) + s(x1, bs = bs) + s(x2, bs = bs, k = k) + s(x3, bs = bs), data = dat) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(b)

stopifnot(all.equal(summary(b), summary(b_truth)))

## predict.bam() via stats::predict() S3 generic dispatch
stopifnot(inherits(b_truth, "bam"))

## predict() for 'bam' forces sequential processing if number of rows
## is strictly less than 100 * number of parallel workers
nrows <- 100 * nbrOfWorkers()
newdat <- dat[1:nrows, ]
p_truth <- predict(b_truth, newdata = newdat)

counters <- plan("backend")[["counters"]]
p <- predict(b_truth, newdata = newdat) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
## NOTE: mgcv::predict.bam() returns an array when run sequentially,
## but a named numeric vector when run in parallel via parLapply
stopifnot(all.equal(as.numeric(p), as.numeric(p_truth)))

counters <- plan("backend")[["counters"]]
p2 <- stats::predict(b_truth, newdata = newdat) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(all.equal(as.numeric(p2), as.numeric(p_truth)))


plan(sequential)
} ## if (requireNamespace("mgcv"))
