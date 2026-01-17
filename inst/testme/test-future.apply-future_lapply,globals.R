#' @tags future_lapply
#' @tags sequential multisession multicore

library(futurize)
library(tools) ## toTitleCase()

options(future.debug = FALSE)
options(future.apply.debug = TRUE)

message("*** future_lapply() - globals ...")

plan(cluster, workers = "localhost")

a <- 1
b <- 2

globals_set <- list(
  A = FALSE,
  B = TRUE,
  C = c("a", "b"),
  D = list(a = 2, b = 3)
)

x <- list(1)
y_truth <- list(A = NULL, B = list(1), C = list(1), D = list(2))
str(y_truth)

for (name in names(globals_set)) {
  globals <- globals_set[[name]]
  message("Globals set ", sQuote(name))
  y <- tryCatch({
    lapply(x, FUN = function(x) {
      median(c(x, a, b))
    }) |> futurize(globals = globals, packages = "utils")
  }, error = identity)
  print(y)
  if (! "covr" %in% loadedNamespaces()) {
    stopifnot((name == "A" && inherits(y, "error")) || 
               identical(y, y_truth[[name]]))
  }
}

message("*** future_lapply() - globals ... DONE")


message("*** future_lapply() - manual globals ...")

d <- 42
y <- lapply(1:2, FUN = function(x) { x * d }) |> futurize(globals = structure(FALSE, add = "d"))
stopifnot(identical(y, list(42, 84)))

e <- 42
res <- tryCatch({
  lapply(1:2, FUN = function(x) { 2 * e }) |> futurize(globals = structure(TRUE, ignore = "e"))
}, error = identity)
if (! "covr" %in% loadedNamespaces()) {
  stopifnot(inherits(res, "error"))
}

message("*** future_lapply() - manual globals ... DONE")



## Test adopted from http://stackoverflow.com/questions/42561088/nested-do-call-within-a-foreach-dopar-environment-cant-find-function-passed-w

message("*** future_lapply() - tricky globals ...")

my_add <- function(a, b) a + b

call_my_add <- function(a, b) {
  do.call(my_add, args = list(a = a, b = b))
}

call_my_add_caller <- function(a, b, FUN = call_my_add) {
  do.call(FUN, args = list(a = a, b = b))
}

main <- function(x = 1:2, caller = call_my_add_caller,
                 args = list(FUN = call_my_add)) {
  results <- lapply(x, FUN = function(i) {
    do.call(caller, args = c(list(a = i, b = i + 1L), args))
  }) |> futurize()
  results
}

x <- list(list(1:2))
z_length <- lapply(x, FUN = do.call, what = length)
fun <- function(...) sum(...)
z_fun <- lapply(x, FUN = do.call, what = fun)

y0 <- NULL
for (strategy in supportedStrategies()) {
  plan(strategy)

  y <- main(1:3)
  if (is.null(y0)) y0 <- y
  stopifnot(identical(y, y0))

  message("- lapply(x, FUN = do.call, ...) |> futurize() ...")
  z <- lapply(x, FUN = do.call, what = length) |> futurize()
  stopifnot(identical(z, z_length))
  z <- lapply(x, FUN = do.call, what = fun) |> futurize()
  stopifnot(identical(z, z_fun))

  message("- lapply(x, ...) |> futurize() - passing arguments via '...' ...")
  ## typeof() == "list"
  obj <- data.frame(a = 1:2)
  stopifnot(typeof(obj) == "list")
  y <- lapply(1L, function(a, b) typeof(b), b = obj) |> futurize()
  stopifnot(identical(y[[1]], typeof(obj)))

  ## typeof() == "environment"
  obj <- new.env()
  stopifnot(typeof(obj) == "environment")
  y <- lapply(1L, function(a, b) typeof(b), b = obj) |> futurize()
  stopifnot(identical(y[[1]], typeof(obj)))

  ## typeof() == "S4"
  if (requireNamespace("methods")) {
    obj <- methods::getClass("MethodDefinition")
    stopifnot(typeof(obj) == "S4")
    y <- lapply(1L, function(a, b) typeof(b), b = obj) |> futurize()
    stopifnot(identical(y[[1]], typeof(obj)))
  }

  message("- lapply(X, ...) |> futurize() - 'X' containing globals ...")
  ## From https://github.com/futureverse/future.apply/issues/12
  a <- 42
  b <- 21
  X <- list(
    function(b) 2 * a,
    function() b / 2,
    function() a + b,
    function() nchar(tools::toTitleCase("hello world"))
  )
  z0 <- lapply(X, FUN = function(f) f())
  str(z0)
  z1 <- lapply(X, FUN = function(f) f()) |> futurize()
  str(z1)
  stopifnot(identical(z1, z0))

#  message("- lapply(x, ...) |> futurize() - passing '...' as a global ...")
#  ## https://github.com/futureverse/future/issues/417
#  fcn0 <- function(...) { lapply(1, FUN = function(x) list(...)) }
#  z0 <- fcn0(a = 1)
#  str(list(z0 = z0))
#  stopifnot(identical(z0, list(list(a = 1))))
#  fcn <- function(...) { lapply(1, FUN = function(x) list(...)) } |> futurize()
#  z1 <- fcn(a = 1)
#  str(list(z1 = z1))
#  stopifnot(identical(z1, z0))

  ## https://github.com/futureverse/future.apply/issues/47
  message("- lapply(X, ...) |> futurize() - '{ a <- a + 1; a }' ...")
  a <- 1
  z0 <- lapply(1, function(ii) {
    a <- a + 1
    a
  })
  z1 <- lapply(1, function(ii) {
    a <- a + 1
    a
  }) |> futurize()
  stopifnot(identical(z1, z0))

  ## https://github.com/futureverse/future.apply/issues/47
  message("- lapply(X, ...) |> futurize() - '{ a; a <- a + 1 }' ...")
  z2 <- tryCatch(lapply(1, function(ii) {
    a
    a <- a + 1
  }) |> futurize(), error = identity)
  stopifnot(identical(z2, z0))

  ## https://github.com/futureverse/future.apply/issues/85
  message("- lapply(..., future.globals = <list>) |> futurize() ...")
  a <- 0
  y <- lapply(1, FUN = function(x) a) |> futurize(globals = list(a = 42))
  str(y)
  if (! "covr" %in% loadedNamespaces()) {
    stopifnot(y[[1]] == 42)
  }
} ## for (strategy ...)

message("*** future_lapply() - tricky globals ... DONE")


message("*** future_lapply() - missing arguments ...")

## Here 'abc' becomes missing, i.e. missing(abc) is TRUE
foo <- function(x, abc) lapply(x, FUN = function(y) y) |> futurize()
y <- foo(1:2)
stopifnot(identical(y, as.list(1:2)))

message("*** future_lapply() - missing arguments ... DONE")


message("*** future_lapply() - false positives ...")

## Here 'abc' becomes a promise, which fails to resolve
## iff 'xyz' does not exist. (Issue #161)
suppressWarnings(rm(list = "xyz"))
foo <- function(x, abc) lapply(x, FUN = function(y) y) |> futurize()
y <- foo(1:2, abc = (xyz >= 3.14))
stopifnot(identical(y, as.list(1:2)))

message("*** future_lapply() - false positives ... DONE")


message("*** future_lapply() - too large ...")

oMaxSize <- getOption("future.globals.maxSize")
X <- replicate(10L, 1:100, simplify = FALSE)
FUN <- function(x) {
  getOption("future.globals.maxSize")
}

y0 <- lapply(X, FUN = FUN)
stopifnot(all(sapply(y0, FUN = identical, oMaxSize)))

sizes <- unclass(c(FUN = object.size(FUN), X = object.size(X)))
cat(sprintf("Baseline size of globals: %.2f KiB\n", sizes[["FUN"]] / 1024))

message("- true positive ...")
options(future.globals.maxSize = 1L)
res <- tryCatch({
  y <- lapply(X, FUN = FUN) |> futurize()
}, error = identity)
stopifnot(inherits(res, "error"))
res <- NULL
options(future.globals.maxSize = oMaxSize)

maxSize <- getOption("future.globals.maxSize")
y <- lapply(X, FUN = FUN) |> futurize()
str(y)
stopifnot(all(sapply(y, FUN = identical, oMaxSize)))

message("- approximately invariant to chunk size ...")
maxSize <- sizes[["FUN"]] + sizes[["X"]] / length(X)
if ("covr" %in% loadedNamespaces()) maxSize <- maxSize + 65e3
options(future.globals.maxSize = maxSize)

for (chunk_size in c(1L, 2L, 5L, 10L)) {
  y <- lapply(X, FUN = FUN) |> futurize(chunk_size = chunk_size)
  str(y)
  stopifnot(all(unlist(y) == maxSize))
  cat(sprintf("maxSize = %g bytes\nfuture.globals.maxSize = %g bytes\n",
              maxSize, getOption("future.globals.maxSize")))
  stopifnot(getOption("future.globals.maxSize") == maxSize)
}
y <- NULL
options(future.globals.maxSize = oMaxSize)


message("*** future_lapply() - too large ... DONE")


message("*** future_lapply() - globals exceptions ...")

res <- tryCatch({
  y <- lapply(1, FUN = function(x) x) |> futurize(globals = 42)
}, error = identity)
stopifnot(inherits(res, "error"))

res <- tryCatch({
  y <- lapply(1, FUN = function(x) x) |> futurize(globals = list(1))
}, error = identity)
stopifnot(inherits(res, "error"))

res <- tryCatch({
  y <- lapply(1, FUN = function(x) x) |> futurize(globals = "...future.FUN")
}, error = identity)
stopifnot(inherits(res, "error"))

res <- tryCatch({
  y <- lapply(1, FUN = function(x) x) |> futurize(globals = "...future.FUN")
}, error = identity)
stopifnot(inherits(res, "error"))

...future.elements_ii <- 42L
X <- list(function() 2 * ...future.elements_ii)
res <- tryCatch({
  y <- lapply(X, FUN = function(f) f()) |> futurize()
}, error = identity)
if (! "covr" %in% loadedNamespaces()) {
  stopifnot(inherits(res, "error"))
}

message("*** future_lapply() - globals exceptions ... DONE")


