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

b <- bam(y ~ s(x0, bs = bs) + s(x1, bs = bs) + s(x2, bs = bs, k = k) + s(x3, bs = bs), data = dat) |> futurize()
print(b)

stopifnot(all.equal(summary(b), summary(b_truth)))

## predict.bam() via stats::predict() S3 generic dispatch
stopifnot(inherits(b_truth, "bam"))

newdat <- dat[1:100, ]
p_truth <- predict(b_truth, newdata = newdat)

## mgcv exports predict.bam(), so we can call it explictly
p0 <- predict.bam(b_truth, newdata = newdat) |> futurize()
stopifnot(all.equal(p0, p_truth))

## futurize() when dispatching to S3 method predict() for 'bam'
p <- predict(b_truth, newdata = newdat) |> futurize()
stopifnot(all.equal(p, p_truth))


plan(sequential)
} ## if (requireNamespace("mgcv"))
