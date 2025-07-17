if (requireNamespace("glmnet")) {
library(futurize)
library(glmnet)
options(future.rng.onMisuse = "error")

all_equal <- function(a, b, ...) {
  a$call <- NULL
  b$call <- NULL
  a$glmnet.fit$call <- NULL
  b$glmnet.fit$call <- NULL
  all.equal(a, b, ...)
}

plan(multisession)

## Adopted from example("cv.glmnet", package = "glmnet")
n <- 1000L
p <- 100L
nzc <- trunc(p / 10)
x <- matrix(rnorm(n * p), n, p)
beta <- rnorm(nzc)
fx <- x[, seq(nzc)] %*% beta
eps <- rnorm(n) * 5
y <- drop(fx + eps)

set.seed(1011)
cv_truth <- cv.glmnet(x, y)
print(cv_truth)

set.seed(1011)
cv <- cv.glmnet(x, y) |> futurize()
print(cv)

res <- all_equal(cv, cv_truth)
print(res)
stopifnot(res)

plan(sequential)
} ## if (requireNamespace("glmnet"))
