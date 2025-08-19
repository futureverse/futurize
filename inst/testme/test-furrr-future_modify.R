if (requireNamespace("purrr") && requireNamespace("furrr")) {
library(futurize)
library(purrr)

# ------------------------------------------------------------------------------
# future_modify()

message("future_modify() default method works")
stopifnot(identical(modify(list(1, 2), ~3) |> futurize(), list(3, 3)))
stopifnot(identical(
  modify(data.frame(x = 1, y = 2), ~3) |> futurize(),
  data.frame(x = 3, y = 3)
))


# TODO: Fix `NULL` behavior to match what is done here
# https://github.com/tidyverse/purrr/pull/754
message("modify() |> futurize() is not stable when returning `NULL`")
stopifnot(identical(
  modify(
    list(1, 2),
    ~if (.x == 1) {
      NULL
    } else {
      .x
    }
  ) |> futurize(),
  list(2, 2)
))


message("future_modify() variants work")
stopifnot(identical(modify(c(1L, 2L, 3L), ~2L) |> futurize(), rep(2L, 3)))
stopifnot(identical(modify(c(1, 2, 3), ~2) |> futurize(), rep(2, 3)))
stopifnot(identical(modify(c("a", "b", "c"), toupper) |> futurize(), c("A", "B", "C")))
stopifnot(identical(modify(c(TRUE, FALSE, TRUE), ~TRUE) |> futurize(), rep(TRUE, 3)))


message("modify(<pairlist>) |> futurize() works")
x <- as.pairlist(list(1, 2))
stopifnot(identical(class(modify(x, ~.x) |> futurize()), "pairlist"))


# ------------------------------------------------------------------------------
# future_modify_at()

message("future_modify_at() default works")
stopifnot(identical(modify_at(list(1, 2, 3), c(1, 3), ~5) |> futurize(), list(5, 2, 5)))
stopifnot(identical(
  modify_at(data.frame(x = 1, y = 2), 2, ~3) |> futurize(),
  data.frame(x = 1, y = 3)
))


message("future_modify_at() variants works")
stopifnot(identical(modify_at(c(1L, 2L, 3L), c(1, 3), ~5L) |> futurize(), c(5L, 2L, 5L)))
stopifnot(identical(modify_at(c(1, 2, 3), c(1, 3), ~5) |> futurize(), c(5, 2, 5)))
stopifnot(identical(
  modify_at(c("a", "b", "c"), c(1, 3), toupper) |> futurize(),
  c("A", "b", "C")
))
stopifnot(identical(
  modify_at(c(TRUE, FALSE, TRUE), c(1, 3), ~NA) |> futurize(),
  c(NA, FALSE, NA)
))


# ------------------------------------------------------------------------------
# future_modify_if()

message("future_modify_if() default works")
stopifnot(identical(modify_if(list(1, 2), ~.x == 1, ~3) |> futurize(), list(3, 2)))
stopifnot(identical(
  modify_if(data.frame(x = 1, y = 2), ~.x == 1, ~3) |> futurize(),
  data.frame(x = 3, y = 2)
))


message("future_modify_if() `.else` works for default")
stopifnot(identical(
  modify_if(list(1, 2, 1, 4), ~.x == 1, ~3, .else = ~4) |> futurize(),
  list(3, 4, 3, 4)
))


message("future_modify_if() variants works")
stopifnot(identical(
  modify_if(c(1L, 2L, 3L), ~.x == 1L, ~2L, .else = ~3L) |> futurize(),
  c(2L, 3L, 3L)
))
stopifnot(identical(
  modify_if(c(1, 2, 3), ~.x == 1, ~2, .else = ~3) |> futurize(),
  c(2, 3, 3)
))
stopifnot(identical(
  modify_if(c("a", "b", "c"), ~.x == "a", toupper, .else = ~"d") |> futurize(),
  c("A", "d", "d")
))
stopifnot(identical(
  modify_if(c(TRUE, FALSE, TRUE), ~.x == TRUE, ~TRUE, .else = ~NA) |> futurize(),
  c(TRUE, NA, TRUE)
))

plan(sequential)
} ## if (requireNamespace("purrr") && requireNamespace("furrr"))
