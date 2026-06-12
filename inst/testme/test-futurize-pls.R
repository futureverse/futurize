#' @tags pkg-pls
if (requireNamespace("pls") && getRversion() >= "4.4.0") {
library(futurize)
library(pls)
options(future.rng.onMisuse = "error")

all_equal <- function(a, b, ...) {
  a$call <- b$call <- NULL
  a$fit.time <- b$fit.time <- NULL
  all.equal(a, b, ...)
}

plan(multisession, workers = 2L)

#------------------------------------------------------------------
# mvr()
#------------------------------------------------------------------
message("mvr() ...")
## Adopted from example("mvr", package = "pls")
data(yarn, package = "pls")
set.seed(42)
m_truth <- mvr(density ~ NIR, ncomp = 10, data = yarn, validation = "CV")
print(m_truth)

set.seed(42)
m <- mvr(density ~ NIR, ncomp = 10, data = yarn, validation = "CV") |> futurize_and_verify()
print(m)

stopifnot(all_equal(m, m_truth))

message("mvr() ... done")

#------------------------------------------------------------------
# plsr()
#------------------------------------------------------------------
message("plsr() ...")
set.seed(42)
m_truth <- plsr(density ~ NIR, ncomp = 10, data = yarn, validation = "CV")

set.seed(42)
m <- plsr(density ~ NIR, ncomp = 10, data = yarn, validation = "CV") |> futurize_and_verify()
stopifnot(all_equal(m, m_truth))
message("plsr() ... done")

#------------------------------------------------------------------
# pcr()
#------------------------------------------------------------------
message("pcr() ...")
set.seed(42)
m_truth <- pcr(density ~ NIR, ncomp = 10, data = yarn, validation = "CV")

set.seed(42)
m <- pcr(density ~ NIR, ncomp = 10, data = yarn, validation = "CV") |> futurize_and_verify()
stopifnot(all_equal(m, m_truth))
message("pcr() ... done")

#------------------------------------------------------------------
# crossval()
#------------------------------------------------------------------
message("crossval() ...")
m1 <- plsr(density ~ NIR, ncomp = 10, data = yarn)
set.seed(42)
m_truth <- crossval(m1, segments = 10)

set.seed(42)
m <- crossval(m1, segments = 10) |> futurize_and_verify()
stopifnot(all_equal(m, m_truth))
message("crossval() ... done")

plan(sequential)
}
