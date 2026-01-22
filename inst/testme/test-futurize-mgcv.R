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

plan(sequential)
} ## if (requireNamespace("mgcv"))
