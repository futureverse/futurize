library(futurize)
options(futurize.debug = TRUE)

message("futurize(NA):")
res <- futurize(NA)
print(res)
stopifnot(isTRUE(res))

message("futurize(FALSE):")
res <- futurize(FALSE)
print(res)
stopifnot(isTRUE(res))

message("futurize(TRUE):")
res <- futurize(TRUE)
print(res)
stopifnot(isFALSE(res))

message("futurize(when = FALSE):")
y_truth <- lapply(1:3, identity)
y <- lapply(1:3, identity) |> futurize(when = FALSE)
stopifnot(identical(y, y_truth))
y <- lapply(1:3, identity) |> futurize(when = TRUE)
stopifnot(identical(y, y_truth))
expr <- lapply(1:3, identity) |> futurize(when = FALSE, eval = FALSE)
print(expr)


## Cannot futurize non-calls
res <- tryCatch(base::pi |> futurize(), error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Cannot futurize non-calls
res <- tryCatch(quote(1 + 2) |> futurize(), error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Cannot futurize non-existing functions
res <- tryCatch(futurize:::unknown |> futurize(), error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Cannot futurize non-existing infix operators
res <- tryCatch(futurize:::`%unknown%` |> futurize(), error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Cannot futurize non-supported functions
res <- tryCatch(futurize:::futurize_supported_packages() |> futurize(), error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Cannot futurize private functions
res <- tryCatch(futurize:::import_future() |> futurize(), error = identity)
print(res)
stopifnot(inherits(res, "error"))


message("*** Internals")
options(futurize.debug = TRUE)

message("debug_indent()")
try(futurize:::debug_indent(delta = -1L))

message("decend_wrappers()")
try(futurize:::decend_wrappers(NULL, unwrap = list()))
try(futurize:::decend_wrappers(quote({ lapply(x, f) }), unwrap = list(`{`), debug = TRUE))

message(".onLoad()")
futurize:::.onLoad("futurize", "futurize")

message("register_all_transpilers()")
futurize:::register_all_transpilers()

message("register_vignette_engine_during_build_only()")
futurize:::register_vignette_engine_during_build_only("futurize")
Sys.setenv(R_CMD = "something")
futurize:::register_vignette_engine_during_build_only("futurize")

message("transpiler_packages()")
db <- futurize:::transpiler_packages()
print(db)
if (requireNamespace("future.apply", quietly = TRUE)) {
  y <- lapply(x, f) |> futurize(eval = FALSE)
  db <- futurize:::transpiler_packages()
  print(db)
  db <- futurize:::transpiler_packages(classes = c("futurize::add-on"))
  print(db)
}

message("make_options_for_makeClusterFuture()")
opts <- futurize:::make_options_for_makeClusterFuture(options = list())
str(opts)
opts <- futurize:::make_options_for_makeClusterFuture(options = list(), defaults = list(packages = character(0L), stdout = TRUE))
str(opts)

message("list_transpilers()")
ts <- futurize:::list_transpilers(class = "non-existing")
str(ts)
ts <- futurize:::list_transpilers(class = "futurize::add-on")
str(ts)
ts <- futurize:::list_transpilers(pattern = ".*", class = "futurize::add-on")
str(ts)
if (requireNamespace("future.apply", quietly = TRUE)) {
  y <- lapply(x, f) |> futurize(eval = FALSE)
  ts <- futurize:::list_transpilers(pattern = ".*", class = "futurize::add-on")
  str(ts)
}

message("transpilers_for_package()")
ts <- futurize:::transpilers_for_package(type = "unknown", package = "base", fcn = lapply, debug = TRUE)
str(ts)
ts <- futurize:::transpilers_for_package(type = "unknown", package = "base", fcn = lapply, action = "get", debug = TRUE)
str(ts)
ts <- futurize:::transpilers_for_package(type = "unknown", package = "base", fcn = lapply, action = "list", debug = TRUE)
str(ts)
ts <- futurize:::transpilers_for_package(type = "unknown", package = "base", fcn = lapply, action = "reset", debug = TRUE)
str(ts)
res <- tryCatch(futurize:::transpilers_for_package(type = "unknown", package = "unknown", action = "make", debug = TRUE), error = identity)
str(res)



