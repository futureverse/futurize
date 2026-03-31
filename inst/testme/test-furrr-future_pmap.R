#' @tags detritus-files
if (requireNamespace("purrr") && requireNamespace("furrr")) {
library(futurize)
library(purrr)

# ------------------------------------------------------------------------------
# pmap()

message("future_pmap() matches pmap() for simple cases")
stopifnot(identical(
  pmap(list(1:3, 4:6, 7:9), ~.x + .y + ..3) |> futurize(),
  pmap(list(1:3, 4:6, 7:9), ~.x + .y + ..3)
))


message("names of `.x` are retained")
x <- c(a = 1, b = 2)
y <- c(c = 1, d = 2)
stopifnot(identical(names(pmap(list(x, y), ~1) |> futurize()), c("a", "b")))


message("named empty input makes named empty output")
x <- set_names(list(), character())
stopifnot(identical(names(pmap(list(x, x), ~.x) |> futurize()), character()))


# ------------------------------------------------------------------------------
# atomic variants

message("future_pmap_dbl() works")
x <- c(1, 2, 3)
y <- c(4, 5, 6)

stopifnot(identical(
  pmap_dbl(list(x, y), ~.x + .y) |> futurize(),
  pmap_dbl(list(x, y), ~.x + .y)
))


message("future_pmap_int() works")
x <- c(1L, 2L, 3L)
y <- c(4L, 5L, 6L)

stopifnot(identical(
  pmap_int(list(x, y), ~.x + .y) |> futurize(),
  pmap_int(list(x, y), ~.x + .y)
))


message("future_pmap_lgl() works")
x <- c(TRUE, FALSE, TRUE)
y <- c(FALSE, TRUE, TRUE)

stopifnot(identical(
  pmap_lgl(list(x, y), ~.x || .y) |> futurize(),
  pmap_lgl(list(x, y), ~.x || .y)
))


message("future_pmap_chr() works")
x <- c("a", "b", "c")
y <- c("d", "e", "f")

stopifnot(identical(
  pmap_chr(list(x, y), ~.y) |> futurize(),
  pmap_chr(list(x, y), ~.y)
))


message("names of `.x` are retained")
x <- c(a = 1, b = 2)
y <- c(c = 1, d = 2)
stopifnot(identical(names(pmap_dbl(list(x, y), ~1) |> futurize()), c("a", "b")))


# ------------------------------------------------------------------------------
# data frame variants

message("future_pmap_dfr() works")
x <- c("a", "b", "c")
y <- c("d", "e", "f")

stopifnot(identical(
  pmap_dfr(list(x, y), ~data.frame(x = .x, y = .y)) |> futurize(),
  pmap_dfr(list(x, y), ~data.frame(x = .x, y = .y))
))


message("future_pmap_dfc() works")
x <- c("a", "b", "c")
y <- c("d", "e", "f")

stopifnot(identical(
  pmap_dfc(list(x, y), ~as.data.frame(set_names(list(.x), .y))) |> futurize(),
  pmap_dfc(list(x, y), ~as.data.frame(set_names(list(.x), .y)))
))


# ------------------------------------------------------------------------------
# size

message("future_pmap() works with completely empty list")
stopifnot(identical(pmap(list(), identity) |> futurize(), list()))
stopifnot(identical(pmap_dbl(list(), identity) |> futurize(), double()))


message("future_pmap() works with size zero input")
stopifnot(identical(pmap(list(list(), list()), identity) |> futurize(), list()))


message("atomic variants work with size zero input")
stopifnot(identical(pmap_chr(list(list(), list()), identity) |> futurize(), character()))
stopifnot(identical(pmap_dbl(list(list(), list()), identity) |> futurize(), double()))
stopifnot(identical(pmap_int(list(list(), list()), identity) |> futurize(), integer()))
stopifnot(identical(pmap_lgl(list(list(), list()), identity) |> futurize(), logical()))


message("size one recycling works")
stopifnot(identical(
  pmap(list(1, 1:2), ~c(.x, .y)) |> futurize(),
  list(c(1, 1), c(1, 2))
))

stopifnot(identical(
  pmap(list(1:2, 1), ~c(.x, .y)) |> futurize(),
  list(c(1, 1), c(2, 1))
))

stopifnot(identical(
  pmap(list(integer(), 1), ~c(.x, .y)) |> futurize(),
  list()
))

stopifnot(identical(
  pmap(list(1, integer()), ~c(.x, .y)) |> futurize(),
  list()
))


message("generally can't recycle to size zero")
res <- tryCatch({
  pmap(list(1:2, integer(), ~c(.x, .y))) |> futurize()
}, error = identity)
stopifnot(
  inherits(res, "error"),
  grepl("Can't recycle", conditionMessage(res)
))

res <- tryCatch({
  pmap(list(integer(), 1:2), ~c(.x, .y)) |> futurize()
}, error = identity)
stopifnot(
  inherits(res, "error"),
  grepl("Can't recycle", conditionMessage(res)
))


# ------------------------------------------------------------------------------
# Miscellaneous

message("named arguments can be passed through")
vec_mean <- function(.x, .y, na.rm = FALSE) {
  mean(c(.x, .y), na.rm = na.rm)
}

x <- list(c(NA, 1), 1:2)

stopifnot(identical(
  pmap(x, vec_mean, na.rm = TRUE) |> futurize(),
  list(1, 1.5)
))


message("arguments can be matched by name")
x <- list(x = c(1, 2), y = c(3, 5))

fn <- function(y, x) {
  y - x
}

stopifnot(identical(pmap_dbl(x, fn) |> futurize(), c(2, 3)))


message("unused components can be absorbed")
x <- list(c(1, 2), c(3, 5))

fn1 <- function(x) {
  x
}
fn2 <- function(x, ...) {
  x
}

res <- tryCatch({
  pmap_dbl(x, fn1) |> futurize()
}, error = identity)
stopifnot(
  inherits(res, "error")
)
stopifnot(identical(pmap_dbl(x, fn2) |> futurize(), c(1, 2)))


message("globals in `.x` and `.y` are found (#16)")
fn1 <- function(x) sum(x, na.rm = TRUE)
fn2 <- function(x) sum(x, na.rm = FALSE)

x <- list(c(1, 2, NA), c(2, 3, 4))

fns1 <- map(x, ~purrr::partial(fn1, x = .x))
fns2 <- map(x, ~purrr::partial(fn2, x = .x))

stopifnot(identical(
  pmap(list(fns1, fns2), ~c(.x(), .y())) |> futurize(),
  list(c(3, NA), c(9, 9))
))


message("globals in `.l` are only exported to workers that use them")
plan(multisession, workers = 2)
on.exit(plan(sequential), add = TRUE)

# Use `local()` to ensure that the wrapper functions and the anonymous
# functions created with `~` don't pick up extra globals
my_wrapper1 <- local({
  my_mean1 <- function(x) mean(x, na.rm = TRUE)

  function(x) {
    my_mean1(x)
    exists("my_mean1")
  }
})

my_wrapper2 <- local({
  my_mean2 <- function(x) mean(x, na.rm = FALSE)

  function(x) {
    my_mean2(x)
    exists("my_mean1")
  }
})

x <- list(my_wrapper1, my_wrapper2)

stopifnot(identical(
  pmap_lgl(list(x), .f = ~.x(c(1, NA))) |> futurize(),
  c(TRUE, FALSE)
))

plan(sequential)
} ## if (requireNamespace("purrr") && requireNamespace("furrr"))
