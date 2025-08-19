#' @tags future_vapply
#' @tags detritus-files
#' @tags sequential multisession multicore

library(futurize)

message("*** future_vapply() ...")

for (strategy in supportedStrategies()) {
  message(sprintf("*** strategy = %s ...", sQuote(strategy)))
  plan(strategy)
  
  x <- NULL
  fun <- is.factor
  fun_name <- "is.factor"
  fun_value <- logical(1L)
  y0 <- vapply(x, FUN = fun, FUN.VALUE = fun_value)
  str(y0)
  y1 <- vapply(x, FUN = fun, FUN.VALUE = fun_value) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))
  y2 <- vapply(x, FUN = fun_name, FUN.VALUE = fun_value) |> futurize()
  str(y2)
  stopifnot(all.equal(y2, y0))
  
  x <- list()
  fun <- is.numeric
  fun_value <- logical(1L)
  y0 <- vapply(x, FUN = fun, FUN.VALUE = fun_value)
  str(y0)
  y1 <- vapply(x, FUN = fun, FUN.VALUE = fun_value) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))
  
  x <- integer()
  fun <- identity
  fun_value <- fun(integer(1L))
  y0 <- vapply(x, FUN = fun, FUN.VALUE = fun_value)
  str(y0)
  y1 <- vapply(x, FUN = fun, FUN.VALUE = fun_value) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))
  
  
  df <- data.frame(x = 1:10, y = letters[1:10], stringsAsFactors=FALSE)
  fun <- class
  fun_value <- character(1L)
  y0 <- vapply(df, FUN = fun, FUN.VALUE = fun_value)
  str(y0)
  y1 <- vapply(df, FUN = fun, FUN.VALUE = fun_value) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))
  
  x <- 1:10
  fun <- function(x) double(0L)
  fun_value <- fun(double(1L))
  y0 <- vapply(x, FUN = fun, FUN.VALUE = fun_value)
  str(y0)
  y1 <- vapply(x, FUN = fun, FUN.VALUE = fun_value) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))
  
  fun <- function(x) integer(0L)
  fun_value <- fun(double(1L))
  y0 <- vapply(x, FUN = fun, FUN.VALUE = fun_value)
  str(y0)
  y1 <- vapply(x, FUN = fun, FUN.VALUE = fun_value) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))
  
  fun <- sqrt
  fun_value <- fun(double(1L))
  y0 <- vapply(x, FUN = fun, FUN.VALUE = fun_value)
  str(y0)
  y1 <- vapply(x, FUN = fun, FUN.VALUE = fun_value) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))
  
  fun <- function(x) c(x, x^2)
  fun_value <- fun(double(1L))
  y0 <- vapply(x, FUN = fun, FUN.VALUE = fun_value)
  str(y0)
  y1 <- vapply(x, FUN = fun, FUN.VALUE = fun_value) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))
  
  fun <- function(x) matrix(x, nrow = 2L, ncol = 2L)
  fun_value <- fun(integer(1L))
  y0 <- vapply(x, FUN = fun, FUN.VALUE = fun_value)
  str(y0)
  y1 <- vapply(x, FUN = fun, FUN.VALUE = fun_value) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))
  
  fun <- function(x) matrix(x, nrow = 2L, ncol = 2L)
  fun_value <- fun(double(1L))
  y0 <- vapply(x, FUN = fun, FUN.VALUE = fun_value)
  str(y0)
  y1 <- vapply(x, FUN = fun, FUN.VALUE = fun_value) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))

  ## Ditto with dimnames on FUN.VALUE
  fun <- function(x) {
    matrix(x, nrow = 2L, ncol = 2L, dimnames = list(c("a", "b"), c("A", "B")))
  }
  fun_value <- fun(double(1L))
  y0 <- vapply(x, FUN = fun, FUN.VALUE = fun_value)
  str(y0)
  y1 <- vapply(x, FUN = fun, FUN.VALUE = fun_value) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))
  
  message("- From example(vapply) ...")
  x <- list(a = 1:10, beta = exp(-3:3), logic = c(TRUE, FALSE, FALSE, TRUE))
  y0 <- vapply(x, FUN = quantile, FUN.VALUE = double(5L))
  y1 <- vapply(x, FUN = quantile, FUN.VALUE = double(5L)) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))
  
  i39 <- sapply(3:9, seq)
  ys0 <- sapply(i39, fivenum)
  ys1 <- sapply(i39, fivenum) |> futurize()
  stopifnot(all.equal(ys1, ys0))
  
  yv0 <- vapply(i39, fivenum,
          c(Min. = 0, "1st Qu." = 0, Median = 0, "3rd Qu." = 0, Max. = 0))
  yv1 <- vapply(i39, fivenum,
          c(Min. = 0, "1st Qu." = 0, Median = 0, "3rd Qu." = 0, Max. = 0)) |> futurize()
  str(yv1)
  stopifnot(all.equal(yv1, yv0))
  
  v <- structure(10*(5:8), names = LETTERS[1:4])
  f <- function(x, y) outer(rep(x, length.out = 3L), y)
  ys0 <- sapply(v, f, y = 2*(1:5), simplify = "array")
  ys1 <- sapply(v, f, y = 2*(1:5), simplify = "array") |> futurize()
  stopifnot(all.equal(ys1, ys0))
  
  fv <- outer(1:3, 1:5)
  y <- 2*(1:5)
  yv0 <- vapply(v, f, fv, y = y)
  yv1 <- vapply(v, f, fv, y = y) |> futurize()
  str(yv1)
  stopifnot(all.equal(yv1, yv0))
  
  y0 <- vapply(mtcars, FUN = is.numeric, FUN.VALUE = logical(1L))
  y1 <- vapply(mtcars, FUN = is.numeric, FUN.VALUE = logical(1L)) |> futurize()
  str(y1)
  stopifnot(all.equal(y1, y0))

  message("- vapply(x, ...) |> futurize() where length(x) != length(as.list(x)) ...")
  x <- structure(list(a = 1, b = 2), class = "Foo")
  as.list.Foo <- function(x, ...) c(x, c = 3)
  y0 <- vapply(x, FUN = length, FUN.VALUE = -1L)
  y1 <- vapply(x, FUN = length, FUN.VALUE = -1L) |> futurize()
  stopifnot(identical(y1, y0))

  message("- exceptions ...")
  res <- tryCatch({
    y0 <- vapply(1:3, FUN = identity, FUN.VALUE = c(3, 3))
  }, error = identity)
  stopifnot(inherits(res, "error"))
  res <- tryCatch({
    y1 <- vapply(1:3, FUN = identity, FUN.VALUE = c(3, 3)) |> futurize()
  }, error = identity)
  stopifnot(inherits(res, "error"))
  
  plan(sequential)
  message(sprintf("*** strategy = %s ... done", sQuote(strategy)))
} ## for (strategy in ...) 


message("*** future_vapply() ... DONE")
