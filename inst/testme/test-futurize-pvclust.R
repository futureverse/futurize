#' @tags pkg-pvclust
if (requireNamespace("pvclust") && getRversion() >= "4.4.0") {
library(futurize)
library(pvclust)
options(future.rng.onMisuse = "error")

all_equal <- function(a, b, ...) {
  a$call <- b$call <- NULL
  all.equal(a, b, ...)
}

plan(multisession)

#------------------------------------------------------------------
# pvclust()
#------------------------------------------------------------------
message("pvclust() ...")
data(mtcars, package = "datasets")

set.seed(42)
fit_truth <- pvclust(mtcars, nboot = 10L, parallel = FALSE)
print(fit_truth)

set.seed(42)
fit <- pvclust(mtcars, nboot = 10L, parallel = FALSE) |> futurize_and_verify()
print(fit)

stopifnot(inherits(fit, "pvclust"))
stopifnot(length(fit$edges) == length(fit_truth$edges))

message("pvclust() ... done")

plan(sequential)
}
