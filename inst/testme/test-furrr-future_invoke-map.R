if (requireNamespace("purrr") && requireNamespace("furrr")) {
library(futurize)
library(purrr)

# ------------------------------------------------------------------------------
# future_invoke_map()

message("future_invoke_map() matches invoke_map() for simple cases")
stopifnot(identical(
  invoke_map(list(mean, median), list(list(c(1, 2, 3, 6)))) |> futurize(),
  invoke_map(list(mean, median), list(list(c(1, 2, 3, 6))))
))


message("named empty input makes named empty output")
x <- set_names(list(), character())
stopifnot(identical(
  names(invoke_map(x, list(list(c(1, 2, 3, 6)))) |> futurize()),
  character()
))


# ------------------------------------------------------------------------------
# atomic variants

message("future_invoke_map_dbl() works")
x <- list(list(c(1, 2, 3)))

stopifnot(identical(
  invoke_map_dbl(mean, x) |> futurize(),
  invoke_map_dbl(mean, x)
))


message("future_invoke_map_int() works")
x <- list(list(1L))

stopifnot(identical(
  invoke_map_int(identity, x) |> futurize(),
  invoke_map_int(identity, x)
))


message("future_invoke_map_lgl() works")
x <- list(list(TRUE))

stopifnot(identical(
  invoke_map_lgl(identity, x) |> futurize(),
  invoke_map_lgl(identity, x)
))


message("future_invoke_map_chr() works")
x <- list(list("a"))

stopifnot(identical(
  invoke_map_chr(identity, x) |> futurize(),
  invoke_map_chr(identity, x)
))


message("future_invoke_map_raw() works")
x <- list(list(as.raw(1)))

stopifnot(identical(
  invoke_map_raw(identity, x) |> futurize(),
  invoke_map_raw(identity, x)
))


message("names of `.x` are retained")
f <- list(x = mean, y = median)
x <- list(list(1))
stopifnot(identical(
  names(invoke_map_dbl(f, x) |> futurize()), c("x", "y")
))


# ------------------------------------------------------------------------------
# data frame variants

message("future_invoke_map_dfr() works")
x <- list(list("a"))

f <- function(x) {
  data.frame(x = x)
}

stopifnot(identical(
  invoke_map_dfr(f, x) |> futurize(),
  invoke_map_dfr(f, x)
))


message("invoke_future_map_dfc() works")

x <- list(list("a"))

f <- function(x) {
  as.data.frame(set_names(list(1), x))
}

stopifnot(identical(
  invoke_map_dfc(f, x) |> futurize(),
  invoke_map_dfc(f, x)
))

plan(sequential)
} ## if (requireNamespace("purrr") && requireNamespace("furrr"))
