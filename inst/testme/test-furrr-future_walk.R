#' @tags pkg-furrr
if (requireNamespace("purrr") && requireNamespace("furrr")) {
library(futurize)
library(purrr)

message("walk functions work")

x <- 1:5
out <- walk(x, ~"hello") |> futurize()
stopifnot(identical(out, x))

y <- 6:10
out <- walk2(x, y, ~"hello") |> futurize()
stopifnot(identical(out, x))

l <- list(x, y)
out <- pwalk(list(x, y), ~"hello") |> futurize()
stopifnot(identical(out, l))

out <- iwalk(x, ~"hello") |> futurize()
stopifnot(identical(out, x))

plan(sequential)
} ## if (requireNamespace("purrr") && requireNamespace("furrr"))
