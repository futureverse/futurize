if (requireNamespace("foreach") && requireNamespace("doFuture")) {
library(futurize)
library(foreach)

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
stopifnot(identical(out, character(0L)))

plan(sequential)

} ## if (requireNamespace("foreach") && requireNamespace("doFuture"))
