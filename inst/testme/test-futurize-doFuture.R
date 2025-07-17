if (requireNamespace("foreach") && requireNamespace("doFuture")) {
library(futurize)
library(foreach)
options(future.rng.onMisuse = "error")

plan(multisession)

y_truth <- foreach(x = 1:3, .combine = c) %do% {
  print(x)
  sqrt(x)
}
print(y_truth)

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

plan(sequential)

} ## if (requireNamespace("foreach") && requireNamespace("doFuture"))
