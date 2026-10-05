#' @tags pkg-mgcv
if (requireNamespace("mgcv") && getRversion() >= "4.4.0") {
library(futurize)
library(mgcv)
options(future.rng.onMisuse = "error")

plan(multisession)

dat <- gamSim(1, n = 500L, dist = "normal", scale = 20)
bs <- "cr"
k <- 12

b_truth <- bam(y ~ s(x0, bs = bs) + s(x1, bs = bs) + s(x2, bs = bs, k = k) + s(x3, bs = bs), data = dat)
print(b_truth)

b <- bam(y ~ s(x0, bs = bs) + s(x1, bs = bs) + s(x2, bs = bs, k = k) + s(x3, bs = bs), data = dat) |> futurize_and_verify()
print(b)

stopifnot(all.equal(summary(b), summary(b_truth)))

## predict.bam() via stats::predict() S3 generic dispatch
stopifnot(inherits(b_truth, "bam"))

## predict() for 'bam' forces sequential processing if number of rows
## is strictly less than 100 * number of parallel workers
nrows <- 100 * nbrOfWorkers()
newdat <- dat[1:nrows, ]
p_truth <- predict(b_truth, newdata = newdat)

p <- predict(b_truth, newdata = newdat) |> futurize_and_verify()
## NOTE: mgcv::predict.bam() returns an array when run sequentially,
## but a named numeric vector when run in parallel via parLapply
stopifnot(all.equal(as.numeric(p), as.numeric(p_truth)))

p2 <- stats::predict(b_truth, newdata = newdat) |> futurize_and_verify()
stopifnot(all.equal(as.numeric(p2), as.numeric(p_truth)))

## The S3 dispatch argument should produce an error if not an object.
n_fits <- 0L
fit_model <- function() {
  n_fits <<- n_fits + 1L
  b_truth
}
res <- tryCatch({
  predict(fit_model(), newdata = newdat) |> futurize()
}, error = identity)
print(res)
stopifnot(
  inherits(res, "error"),
  grepl("not a variable", conditionMessage(res)),
  n_fits == 0L
)

plan(sequential)
} ## if (requireNamespace("mgcv"))
