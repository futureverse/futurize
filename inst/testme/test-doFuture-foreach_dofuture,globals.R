#' @tags pkg-doFuture
#' @tags %dofuture%
#' @tags detritus-files
#' @tags sequential multisession cluster multicore

if (requireNamespace("foreach") && requireNamespace("doFuture")) {
library(futurize)
library(foreach)

strategies <- future:::supportedStrategies()

library("tools") ## toTitleCase()

## ----------------------------------------------------------------
## Setup for: explicitly exported globals
## ----------------------------------------------------------------
message("- Globals manually specified as named list - also with '...' ...")

x <- 1:3
y1_truth <- lapply(1:2, FUN = function(i) x[c(i, 2:3)])
str(y1_truth)

## ----------------------------------------------------------------
## Setup for: automatically finding globals
## ----------------------------------------------------------------
## Example adopted from StackOverflow comment
## https://stackoverflow.com/a/10114192/1072091
fibonacci <- function(n) {
  if (n <= 1L) return(1L)
  return(fibonacci(n - 1L) + fibonacci(n - 2L))
}
X <- matrix(1:4, nrow = 3L, ncol = 4L)
y2_truth <- foreach(rr = 1:nrow(X)) %do% {
  Vectorize(fibonacci)(X[rr, ])
}
str(y2_truth)

## ----------------------------------------------------------------
## Setup for: automatically finding globals in 'args_list'
## ----------------------------------------------------------------
a <- 42
b <- 21
F <- list(
  function() b / 2,
  function(b) 2 * a,
  function() a + b
)
G <- list(
  function(b) 2 * a,
  function() b / 2,
  function() nchar(toTitleCase("hello world"))
)
z0 <- foreach(f = F, g = G) %do% list(f(), g())
str(z0)

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  message("*** doFuture - explicitly exported globals ...")

  ## (a) automatic
  sub <- function(x, ...) {
    foreach(i = 1:2) %do% { x[c(i, ...)] } |> futurize_and_verify()
  }
  y <- sub(x, 2:3)
  str(y)
  stopifnot(identical(y, y1_truth))

  ## (b) explicit and with '...'
  sub <- function(x, ...) {
    foreach(i = 1:2) %do% { x[c(i, ...)] } |> futurize_and_verify(globals = c("x", "..."))
  }
  y <- sub(x, 2:3)
  str(y)
  stopifnot(identical(y, y1_truth))

  ## (c) with '...', but not last
  sub <- function(x, ...) {
    foreach(i = 1:2) %do% { x[c(i, ...)] } |> futurize_and_verify(globals = c("...", "x"))
  }
  y <- sub(x, 2:3)
  str(y)
  stopifnot(identical(y, y1_truth))

  ## (d) explicit, but forgotten '...'
  sub <- function(x, ...) {
    foreach(i = 1:2) %do% { x[c(i, ...)] } |> futurize_and_verify(globals = c("x"))
  }
  y <- tryCatch(sub(x, 2:3), FuturizeTestAssertionError = stop, error = identity)
  str(y)
  stopifnot(inherits(y, "simpleError"))

  message("*** doFuture - explicitly exported globals ... DONE")


  message("*** doFuture - automatically finding globals ...")

  y <- foreach(rr = 1:nrow(X)) %do% {
    Vectorize(fibonacci)(X[rr, ])
  } |> futurize_and_verify()
  str(y)
  stopifnot(all.equal(y, y2_truth))

  message("*** doFuture - automatically finding globals ... DONE")


  message("*** doFuture - automatically finding globals in 'args_list' ...")

  message("- foreach(f = X, ...) - 'f' containing globals ...")
  ## From https://github.com/futureverse/future.apply/issues/12
  z1 <- foreach(f = F, g = G) %do% list(f(), g()) |> futurize_and_verify()
  str(z1)
  stopifnot(identical(z1, z0))

  message("*** doFuture - automatically finding globals in 'args_list' ... DONE")

  # Shutdown current plan
  plan(sequential)

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

plan(sequential)
} ## if (requireNamespace("foreach") && requireNamespace("doFuture"))
