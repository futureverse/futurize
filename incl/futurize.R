xs <- list(1, 1:2, 1:2, 1:5)

# ------------------------------------------
# Base R apply functions
# ------------------------------------------
# Sequential lapply()
y <- lapply(X = xs, FUN = function(x) {
  sum(x)
})
   
# Parallel version
y <- lapply(X = xs, FUN = function(x) {
  sum(x)
}) |> futurize()
str(y)


# ------------------------------------------
# purrr map-reduce functions with pipes
# ------------------------------------------
if (require("purrr") && requireNamespace("furrr", quietly = TRUE)) {

# Sequential map()
y <- xs |> map(sum)
   
# Parallel version
y <- xs |> map(sum) |> futurize()
str(y)

} ## if (require ...)


# ------------------------------------------
# foreach map-reduce functions
# ------------------------------------------
if (require("foreach") && requireNamespace("doFuture", quietly = TRUE)) {

# Sequential foreach()
y <- foreach(x = xs) %do% {
  sum(x)
}
   
# Parallel version
y <- foreach(x = xs) %do% {
  sum(x)
} |> futurize()
str(y)


# Sequential times()
y <- times(3) %do% rnorm(1)
str(y)
   
# Parallel version
y <- times(3) %do% rnorm(1) |> futurize()
str(y)

} ## if (require ...)


# ------------------------------------------
# plyr map-reduce functions
# ------------------------------------------
if (require("plyr") && requireNamespace("doFuture", quietly = TRUE)) {

# Sequential llply()
y <- llply(xs, sum)
   
# Parallel version
y <- llply(xs, sum) |> futurize()
str(y)

} ## if (require ...)
