#' @tags pkg-seriation
if (requireNamespace("seriation") && requireNamespace("doFuture")) {
library(futurize)
library(seriation)
fcns <- tryCatch({
  futurize::futurize_supported_functions("seriation")
}, error = identity)
print(fcns)
stopifnot(is.character(fcns), length(fcns) > 0L)
options(future.rng.onMisuse = "error")

plan(multisession)

data(SupremeCourt)
d_supreme <- as.dist(SupremeCourt)

message("*** seriate_rep()")

RNGkind("L'Ecuyer-CMRG")
set.seed(42)
o_truth <- seriate_rep(d_supreme, "QAP_LS", rep = 5L)
print(o_truth)
set.seed(42)
o <- seriate_rep(d_supreme, "QAP_LS", rep = 5L) |> futurize_and_verify()
print(o)

## seriate_rep() does not allow for RNG reproducibility
o[[1]] <- o_truth[[1]]
stopifnot(all.equal(o, o_truth, tolerance = 0.01))

message("*** seriate_best()")

RNGkind("L'Ecuyer-CMRG")
set.seed(42)
methods <- c("spectral", "QAP_LS")
o_truth <- seriate_best(d_supreme, methods = methods, criterion = "AR_events", rep = 2L, verbose = FALSE)
print(o_truth)
set.seed(42)
o <- seriate_best(d_supreme, methods = methods, criterion = "AR_events", rep = 2L, verbose = FALSE) |> futurize_and_verify()
print(o)
attr(o, "time") <- attr(o_truth, "time")
stopifnot(all.equal(o, o_truth))

plan(sequential)
} ## if (requireNamespace("seriation"))
