#' @tags pkg-furrr
#' @tags detritus-files

if (requireNamespace("purrr") && requireNamespace("furrr")) {
library(futurize)
library(purrr)

# ------------------------------------------------------------------------------
# map()

message("future_map() matches map() for simple cases")
stopifnot(identical(
  map(1:3, ~.x) |> futurize(),
  map(1:3, ~.x)
))


message("names of `.x` are retained")
x <- c(a = 1, b = 2)
stopifnot(identical(names(map(x, ~1) |> futurize()), c("a", "b")))


message("named empty input makes named empty output")
x <- set_names(list(), character())
stopifnot(identical(names(map(x, ~.x) |> futurize()), character()))


# ------------------------------------------------------------------------------
# atomic variants

message("future_map_dbl() works")
x <- c(1, 2, 3)

stopifnot(identical(
  map_dbl(x, ~.x) |> futurize(),
  map_dbl(x, ~.x)
))


message("future_map_int() works")
x <- c(1L, 2L, 3L)

stopifnot(identical(
  map_int(x, ~.x) |> futurize(),
  map_int(x, ~.x)
))


message("future_map_lgl() works")
x <- c(TRUE, FALSE, TRUE)

stopifnot(identical(
  map_lgl(x, ~.x) |> futurize(),
  map_lgl(x, ~.x)
))


message("future_map_chr() works")
x <- c("a", "b", "c")

stopifnot(identical(
  map_chr(x, ~.x) |> futurize(),
  map_chr(x, ~.x)
))


message("names of `.x` are retained")
x <- c(a = 1, b = 2)
stopifnot(identical(names(map_dbl(x, ~1) |> futurize()), c("a", "b")))


# ------------------------------------------------------------------------------
# data frame variants

message("future_map_dfr() works")
x <- c("a", "b", "c")

stopifnot(identical(
  map_dfr(x, ~data.frame(x = .x)) |> futurize(),
  map_dfr(x, ~data.frame(x = .x))
))


message("future_map_dfc() works")
x <- c("a", "b", "c")

stopifnot(identical(
  map_dfc(x, ~as.data.frame(set_names(list(1), .x))) |> futurize(),
  map_dfc(x, ~as.data.frame(set_names(list(1), .x)))
))


# ------------------------------------------------------------------------------
# size

message("future_map() works with size zero input")
stopifnot(identical(map(list(), identity) |> futurize(), list()))


message("atomic variants work with size zero input")
stopifnot(identical(map_chr(list(), identity) |> futurize(), character()))
stopifnot(identical(map_dbl(list(), identity) |> futurize(), double()))
stopifnot(identical(map_int(list(), identity) |> futurize(), integer()))
stopifnot(identical(map_lgl(list(), identity) |> futurize(), logical()))


# ------------------------------------------------------------------------------
# at / if variants

message("future_map_at() works")
x <- list("a", "b", "c")

stopifnot(identical(
  map_at(x, 2, ~3) |> futurize(),
  map_at(x, 2, ~3)
))


message("names of `.x` are retained")
x <- list(a = "a", b = "b", c = "c")
stopifnot(identical(names(map_at(x, 2, ~3) |> futurize()), c("a", "b", "c")))


message("future_map_if() works")
x <- list("a", "b", "c")

stopifnot(identical(
  map_if(x, ~.x %in% c("a", "c"), ~3) |> futurize(),
  map_if(x, ~.x %in% c("a", "c"), ~3)
))


message("names of `.x` are retained")
x <- list(a = "a", b = "b", c = "c")
stopifnot(identical(names(map_if(x, ~.x %in% c("a", "c"), ~3) |> futurize()), c("a", "b", "c")))


message("`.else` can be used")
x <- list("a", "b", "c")

stopifnot(identical(
  map_if(x, ~.x %in% c("a", "c"), ~3, .else = ~-1) |> futurize(),
  map_if(x, ~.x %in% c("a", "c"), ~3, .else = ~-1)
))


# ------------------------------------------------------------------------------
# Miscellaneous

message("Calling `~` from within `.f` works")
x <- list(
  list(a = 4, b = 6),
  list(c = 5, d = 7)
)

stopifnot(identical(map(x, ~map(.x, ~.x)) |> futurize(), x))


message("Calling `~` from within `.f` inside a `mutate()` works (#7, #123)")
x <- list(
  list(a = 4, b = 6),
  list(c = 5, d = 7)
)

df <- dplyr::tibble(x = x)

stopifnot(identical(
  dplyr::mutate(df, x = map(x, ~map(.x, ~.x)) |> futurize()),
  df
))


message("globals in `.x` are found (#16)")
fn <- function(x) sum(x, na.rm = TRUE)

x <- list(c(1, 2, NA), c(2, 3, 4))

fns1 <- map(x, ~purrr::partial(fn, x = .x))
fns2 <- map(x, ~function() fn(.x))

stopifnot(identical(map_dbl(fns1, ~.x()) |> futurize(), c(3, 9)))
stopifnot(identical(map_dbl(fns2, ~.x()) |> futurize(), c(3, 9)))


message("globals in `.x` are only exported to workers that use them")
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
  map_lgl(.x = x, .f = ~.x(c(1, NA))) |> futurize(),
  c(TRUE, FALSE)
))


message("base package functions can be exported to workers (HenrikBengtsson/future#401)")
stopifnot(identical(map(1:2, identity) |> futurize(), list(1L, 2L)))


message("`.f` globals are only looked up in the function env of `.f` (#153)")
fn <- function(x) {
  y
}

fn2 <- local({
  y <- -1

  function(x) {
    y
  }
})

wrapper <- function(f) {
  y <- 1
  map(1:2, f) |> futurize()
}

res <- tryCatch(wrapper(fn), error = identity)
stopifnot(
  inherits(res, "error"),
  grepl("'y' not found", conditionMessage(res))
)
stopifnot(identical(wrapper(fn2), list(-1, -1)))


message("`...` globals/packages are found")
# We set the function environments to the global environment to ensure
# that they aren't set to something else while `test()` is running

fn <- function(x, fn_arg) {
  fn_arg()
}
environment(fn) <- .GlobalEnv

fn_arg_env <- new.env(parent = .GlobalEnv)
fn_arg_env$x <- 1

# This function is passed through `...`
fn_arg <- function() {
  x
}
environment(fn_arg) <- fn_arg_env

stopifnot(identical(
  map(1:2, fn, fn_arg = fn_arg) |> futurize(),
  list(1, 1)
))


plan(sequential)
} ## if (requireNamespace("purrr") && requireNamespace("furrr"))
