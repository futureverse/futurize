if (requireNamespace("purrr") && requireNamespace("furrr")) {
library(futurize)
library(purrr)

message("imap functions work with unnamed input")

stopifnot(identical(imap(1:2, ~.y) |> futurize(), list(1L, 2L)))
stopifnot(identical(imap_chr(1:2, ~as.character(.y)) |> futurize(), c("1", "2")))
stopifnot(identical(imap_int(1:2, ~.y) |> futurize(), c(1L, 2L)))
stopifnot(identical(imap_dbl(1:2, ~.y) |> futurize(), c(1, 2)))
stopifnot(identical(imap_lgl(1:2, ~identical(.y, 1L)) |> futurize(), c(TRUE, FALSE)))
stopifnot(identical(
  imap_dfr(1:2, ~data.frame(x = .y)) |> futurize(),
  data.frame(x = c(1L, 2L))
))
stopifnot(identical(
  imap_dfc(1:2, ~vctrs::new_data_frame(set_names(list(1), .y))) |> futurize(),
  vctrs::new_data_frame(list(`1` = 1, `2` = 1))
))


message("imap functions work with named input")
x <- set_names(1:2, c("x", "y"))
stopifnot(identical(imap(x, ~.y) |> futurize(), list(x = "x", y = "y")))
stopifnot(identical(imap_chr(x, ~as.character(.y)) |> futurize(), c(x = "x", y = "y")))
stopifnot(identical(
  imap_int(x, ~if (.y == "x") 1L else 2L) |> futurize(),
  c(x = 1L, y = 2L)
))
stopifnot(identical(
  imap_dbl(x, ~if (.y == "x") 1 else 2) |> futurize(),
  c(x = 1, y = 2)
))
stopifnot(identical(
  imap_lgl(x, ~if (.y == "x") TRUE else FALSE) |> futurize(),
  c(x = TRUE, y = FALSE)
))
stopifnot(identical(
  imap_dfr(x, ~data.frame(x = .y)) |> futurize(),
  data.frame(x = c("x", "y"))
))
stopifnot(identical(
  imap_dfc(x, ~vctrs::new_data_frame(set_names(list(1), .y))) |> futurize(),
  vctrs::new_data_frame(list(x = 1, y = 1))
))
  
plan(sequential)
} ## if (requireNamespace("purrr") && requireNamespace("furrr"))
