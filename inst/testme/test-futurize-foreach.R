if (requireNamespace("foreach") && requireNamespace("doFuture")) {
library(futurize)
library(foreach)
options(future.rng.onMisuse = "error")

plan(multisession)



message("%do%")
if (! "covr" %in% loadedNamespaces()) {
  ## NOTE: This basic foreach() call produces "Error in frameTypes(env) :
  ## namespace found within global environments" when checked with 'covr'
  y_truth <- foreach(x = 1:3, .combine = c) %do% {
    print(x)
    sqrt(x)
  }
} else {
  y_truth <- sqrt(1:3)
}
print(y_truth)

message("%do% |> futurize()")
y <- foreach(x = 1:3, .combine = c) %do% {
  print(x)
  sqrt(x)
} |> futurize()
print(y)

stopifnot(identical(y, y_truth))

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


message("Non-supported %dopar% and %dofuture%")
res <- tryCatch({ foreach(x = 1) %dopar% x |> futurize() }, error = identity)
print(res)
stopifnot(inherits(res, "error"))

res <- tryCatch({ foreach(x = 1) %dofuture% x |> futurize() }, error = identity)
print(res)
stopifnot(inherits(res, "error"))

plan(sequential)

} ## if (requireNamespace("foreach") && requireNamespace("doFuture"))
