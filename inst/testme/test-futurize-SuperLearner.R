#' @tags pkg-SuperLearner
if (requireNamespace("SuperLearner") && getRversion() >= "4.4.0") {
library(futurize)
library(SuperLearner)
options(future.rng.onMisuse = "error")

plan(multisession)

#------------------------------------------------------------------
# CV.SuperLearner()
#------------------------------------------------------------------
message("CV.SuperLearner() ...")

set.seed(42)
n <- 100
p <- 5
X <- as.data.frame(matrix(rnorm(n * p), n, p))
Y <- X[, 1] + X[, 2] + rnorm(n)
SL.library <- c("SL.glm", "SL.mean")

set.seed(1)
res_truth <- CV.SuperLearner(Y = Y, X = X, V = 2, SL.library = SL.library, method = "method.NNLS")

set.seed(1)
res <- CV.SuperLearner(Y = Y, X = X, V = 2, SL.library = SL.library, method = "method.NNLS") |> futurize_and_verify()

stopifnot(
  inherits(res, "CV.SuperLearner"),
  identical(names(res), names(res_truth)),
  identical(dim(res$coef), dim(res_truth$coef)),
  identical(colnames(res$coef), colnames(res_truth$coef))
)

message("CV.SuperLearner() ... done")

plan(sequential)
}
