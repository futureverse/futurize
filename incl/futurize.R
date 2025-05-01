xs <- list(1, 1:2, 1:2, 1:5)

# ------------------------------------------
# Base R apply functions
# ------------------------------------------
# Sequential call
y <- lapply(X = xs, FUN = function(x) {
  sum(x)
})
   
# Parallelized version
y <- lapply(X = xs, FUN = function(x) {
  sum(x)
}) |> futurize()
str(y)

# ------------------------------------------
# purrr map-reduce functions
# ------------------------------------------
if (require("purrr") && requireNamespace("furrr")) {

# Sequential call
y <- map(xs, function(x) {
  sum(x)
})
   
# Parallelized version
y <- map(xs, function(x) {
  sum(x)
}) |> futurize()
str(y)

} ## if (require("purrr") && requireNamespace("furrr"))


# ------------------------------------------
# foreach map-reduce functions
# ------------------------------------------
if (require("foreach") && requireNamespace("doFuture")) {

# Sequential call
y <- foreach(x = xs) %do% {
  sum(x)
}
   
# Parallelized version
y <- foreach(x = xs) %do% {
  sum(x)
} |> futurize()
str(y)

} ## if (require("foreach") && requireNamespace("doFuture"))


# ------------------------------------------
# foreach map-reduce functions
# ------------------------------------------
if (require("plyr")) {

# Sequential call
y <- llply(xs, sum)
   
# Parallelized version
y <- llply(xs, sum) |> futurize()
str(y)

} ## if (require("plyr"))
