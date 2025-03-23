xs <- list(1, 1:2, 1:2, 1:5)
a <- 42

# Sequential call
y <- lapply(X = xs, FUN = function(x, ...) {
  sum(c(x, a), ...)
}, na.rm = TRUE)
   
# Parallelized version
y <- lapply(X = xs, FUN = function(x, ...) {
  sum(c(x, a), ...)
}) |> futurize()
