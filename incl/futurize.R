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
library(purrr)

# Sequential call
y <- map(xs, function(x) {
  sum(x)
})
   
# Parallelized version
y <- map(xs, function(x) {
  sum(x)
}) |> futurize()
str(y)


# ------------------------------------------
# foreach map-reduce functions
# ------------------------------------------
# Sequential call
library(foreach)
y <- foreach(x = xs) %do% {
  sum(x)
}
   
# Parallelized version
y <- foreach(x = xs) %do% {
  sum(x)
} |> futurize()
str(y)
