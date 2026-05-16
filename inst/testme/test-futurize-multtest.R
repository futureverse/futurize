#' @tags pkg-multtest
if (requireNamespace("multtest") && getRversion() >= "4.4.0") {
library(futurize)
library(multtest)
options(future.rng.onMisuse = "error")

plan(multisession)

#------------------------------------------------------------------
# MTP()
#------------------------------------------------------------------
message("MTP() ...")
data(golub, package = "multtest")
X <- golub[1:10, ]
Y <- golub.cl

message("MTP() truth ...")
res_truth <- MTP(X, Y = Y, B = 20, seed = 42)
print(res_truth)

message("MTP() futurize ...")
res <- MTP(X, Y = Y, B = 20, seed = 42) |> futurize_and_verify()
print(res)

stopifnot(inherits(res, "MTP"))
stopifnot(length(res@adjp) == length(res_truth@adjp))
stopifnot(all(res@adjp >= 0 & res@adjp <= 1))

message("MTP() ... done")

#------------------------------------------------------------------
# EBMTP()
#------------------------------------------------------------------
message("EBMTP() ...")

message("EBMTP() truth ...")
res_truth <- EBMTP(X, Y = Y, B = 20, seed = 42)
print(res_truth)

message("EBMTP() futurize ...")
res <- EBMTP(X, Y = Y, B = 20, seed = 42) |> futurize_and_verify()
print(res)

stopifnot(inherits(res, "EBMTP"))
stopifnot(length(res@adjp) == length(res_truth@adjp))
stopifnot(all(res@adjp >= 0 & res@adjp <= 1))

message("EBMTP() ... done")

plan(sequential)
}
