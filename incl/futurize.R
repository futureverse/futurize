xs <- list(1, 1:2, 1:2, 1:5)
a <- 42

# ------------------------------------------
# Base R apply functions
# ------------------------------------------
# Sequential call
y <- lapply(X = xs, FUN = function(x, ...) {
  sum(c(x, a), ...)
}, na.rm = TRUE)
   
# Parallelized version
y <- lapply(X = xs, FUN = function(x, ...) {
  sum(c(x, a), ...)
}, na.rm = TRUE) |> futurize()


# ------------------------------------------
# purrr map-reduce functions
# ------------------------------------------
# Sequential call
y <- purrr::map_dbl(xs, function(x, ...) {
  sum(c(x, a), ...)
}, na.rm = TRUE)
   
# Parallelized version
y <- purrr::map_dbl(xs, function(x, ...) {
  sum(c(x, a), ...)
}) |> futurize(stdout = FALSE, seed = FALSE)
print(y)
