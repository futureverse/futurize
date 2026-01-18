if (requireNamespace("foreach") && requireNamespace("doFuture")) {
library(futurize)
library(foreach)
options(future.rng.onMisuse = "error")

plan(multisession)



message("%do%")
if (! "covr" %in% loadedNamespaces()) {
  ## NOTE: This basic foreach() call produces "Error in frameTypes(env) :
  ## namespace found within global environments" when checked with 'covr'
  y_truth <- foreach(x = 1:3, .combine = c) %do% sqrt(x)
  y_truth_2 <- foreach(x = 1:2) %:% foreach(y = 3L) %do% c(x,y)
} else {
  y_truth <- sqrt(1:3)
  y_truth_2 <- list(list(c(1L, 3L)), list(2:3))
}
str(list(y_truth = y_truth, y_truth_2 = y_truth_2))


message("foreach(...) %do% |> futurize()")
y <- foreach(x = 1:3, .combine = c) %do% {
  print(x)
  sqrt(x)
} |> futurize()
print(y)
stopifnot(identical(y, y_truth))

message("foreach(...) %:% foreach(...) %do% |> futurize()")
y_2 <- foreach(x = 1:2) %:% foreach(y = 3L) %do% c(x,y) |> futurize()
str(y_2)
stopifnot(identical(y_2, y_truth_2))

out <- utils::capture.output({
  y <- foreach(x = 1:3, .combine = c) %do% {
    print(x)
    sqrt(x)
  } |> futurize(stdout = FALSE)
})
print(out)
stopifnot(
  identical(out, character(0L)),
  identical(y, y_truth)
)


message("Test with RNG:")
y <- local({
  opts <- options(future.rng.onMisuse = "error")
  on.exit(options(opts))
  foreach(x = 1:3, .combine = c) %do% {
    dummy <- sample.int(2L)
    sqrt(x)
  } |> futurize(seed = TRUE)
})
print(y)
stopifnot(identical(y, y_truth))


message("times(...) %do% |> futurize()")
y <- times(1L) %do% { 42L } |> futurize()
print(y)
stopifnot(identical(y, 42L))


message("Non-supported %dopar% and %dofuture%")
res <- tryCatch({ foreach(x = 1) %dopar% x |> futurize() }, error = identity)
print(res)
stopifnot(inherits(res, "error"))

res <- tryCatch({ foreach(x = 1) %dofuture% x |> futurize() }, error = identity)
print(res)
stopifnot(inherits(res, "error"))

message("Special case: Zero futurize() options")
y <- foreach(x = 1) %do% identity(x) |> futurize(options = list())

plan(sequential)

message("Special case: Zero futurize() options")
y <- times(1L) %do% { 42L } |> futurize(options = list())
print(y)
stopifnot(identical(y, 42L))

message("Internals")
opts <- futurize:::make_options_for_doFuture(options = list(), defaults = list(stdout = TRUE))
str(opts)


} ## if (requireNamespace("foreach") && requireNamespace("doFuture"))
