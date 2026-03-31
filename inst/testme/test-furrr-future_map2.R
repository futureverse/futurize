#' @tags pkg-furrr
#' @tags detritus-files

if (requireNamespace("purrr") && requireNamespace("furrr")) {
library(futurize)
library(purrr)

# ------------------------------------------------------------------------------
# map2()

message("future_map2() matches map2() for simple cases")
stopifnot(identical(
  map2(1:3, 4:6, ~.x + .y) |> futurize(),
  map2(1:3, 4:6, ~.x + .y)
))


message("names of `.x` are retained")
x <- c(a = 1, b = 2)
y <- c(c = 1, d = 2)
stopifnot(identical(names(map2(x, y, ~1) |> futurize()), c("a", "b")))


message("named empty input makes named empty output")
x <- set_names(list(), character())
stopifnot(identical(names(map2(x, x, ~.x) |> futurize()), character()))


# ------------------------------------------------------------------------------
# atomic variants

message("map2_dbl() |> futurize() works")
x <- c(1, 2, 3)
y <- c(4, 5, 6)

stopifnot(identical(
  map2_dbl(x, y, ~.x + .y) |> futurize(),
  map2_dbl(x, y, ~.x + .y)
))


message("future_map2_int() works")
x <- c(1L, 2L, 3L)
y <- c(4L, 5L, 6L)

stopifnot(identical(
  map2_int(x, y, ~.x + .y) |> futurize(),
  map2_int(x, y, ~.x + .y)
))


message("future_map2_lgl() works")
x <- c(TRUE, FALSE, TRUE)
y <- c(FALSE, TRUE, TRUE)

stopifnot(identical(
  map2_lgl(x, y, ~.x || .y) |> futurize(),
  map2_lgl(x, y, ~.x || .y)
))


message("future_map2_chr() works")
x <- c("a", "b", "c")
y <- c("d", "e", "f")

stopifnot(identical(
  map2_chr(x, y, ~.y) |> futurize(),
  map2_chr(x, y, ~.y)
))


message("names of `.x` are retained")
x <- c(a = 1, b = 2)
y <- c(c = 1, d = 2)
stopifnot(identical(names(map2_dbl(x, y, ~1) |> futurize()), c("a", "b")))


# ------------------------------------------------------------------------------
# data frame variants

message("future_map2_dfr() works")
x <- c("a", "b", "c")
y <- c("d", "e", "f")

stopifnot(identical(
  map2_dfr(x, y, ~data.frame(x = .x, y = .y)) |> futurize(),
  map2_dfr(x, y, ~data.frame(x = .x, y = .y))
))


message("future_map2_dfc() works")
x <- c("a", "b", "c")
y <- c("d", "e", "f")

stopifnot(identical(
  map2_dfc(x, y, ~as.data.frame(set_names(list(.x), .y))) |> futurize(),
  map2_dfc(x, y, ~as.data.frame(set_names(list(.x), .y)))
))


# ------------------------------------------------------------------------------
# size

message("future_map2() works with size zero input")
stopifnot(identical(map2(list(), list(), identity) |> futurize(), list()))


message("atomic variants work with size zero input")
stopifnot(identical(map2_chr(list(), list(), identity) |> futurize(), character()))
stopifnot(identical(map2_dbl(list(), list(), identity) |> futurize(), double()))
stopifnot(identical(map2_int(list(), list(), identity) |> futurize(), integer()))
stopifnot(identical(map2_lgl(list(), list(), identity) |> futurize(), logical()))


message("size one recycling works")
stopifnot(identical(
  map2(1, 1:2, ~c(.x, .y)) |> futurize(),
  list(c(1, 1), c(1, 2))
))

stopifnot(identical(
  map2(1:2, 1, ~c(.x, .y)) |> futurize(),
  list(c(1, 1), c(2, 1))
))

stopifnot(identical(
  map2(integer(), 1, ~c(.x, .y)) |> futurize(),
  list()
))

stopifnot(identical(
  map2(1, integer(), ~c(.x, .y)) |> futurize(),
  list()
))


message("generally can't recycle to size zero")
res <- tryCatch({
  map2(1:2, integer(), ~c(.x, .y)) |> futurize()
}, error = identity)
stopifnot(
  inherits(res, "error"),
  grepl("Can't recycle", conditionMessage(res))
)

res <- tryCatch({
  map2(integer(), 1:2, ~c(.x, .y)) |> futurize()
}, error = identity)
stopifnot(
  inherits(res, "error"),
  grepl("Can't recycle", conditionMessage(res))
)


# ------------------------------------------------------------------------------
# Miscellaneous

message("globals in `.x` and `.y` are found (#16)")
fn1 <- function(x) sum(x, na.rm = TRUE)
fn2 <- function(x) sum(x, na.rm = FALSE)

x <- list(c(1, 2, NA), c(2, 3, 4))

fns1 <- map(x, ~purrr::partial(fn1, x = .x))
fns2 <- map(x, ~purrr::partial(fn2, x = .x))

stopifnot(identical(
  map2(fns1, fns2, ~c(.x(), .y())) |> futurize(),
  list(c(3, NA), c(9, 9))
))


message("chunk balancing is correct after a recycle (#30)")
stopifnot(identical(
  map2(1, 1:4, ~c(.x, .y)) |> futurize(),
  list(c(1, 1), c(1, 2), c(1, 3), c(1, 4))
))

plan(sequential)
} ## if (requireNamespace("purrr") && requireNamespace("furrr"))
