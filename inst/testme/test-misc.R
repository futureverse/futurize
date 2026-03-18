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

if (requireNamespace("future.apply", quietly = TRUE)) {
  message("futurize(when = FALSE):")
  y_truth <- lapply(1:3, identity)
  y <- lapply(1:3, identity) |> futurize(when = FALSE)
  stopifnot(identical(y, y_truth))
  y <- lapply(1:3, identity) |> futurize(when = TRUE)
  stopifnot(identical(y, y_truth))
  expr <- lapply(1:3, identity) |> futurize(when = FALSE, eval = FALSE)
  print(expr)
}

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

message("decend_wrappers()")
try(futurize:::decend_wrappers(NULL, unwrap = list()))
try(futurize:::decend_wrappers(quote({ lapply(x, f) }), unwrap = list(`{`), debug = TRUE))

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

message("*** futurize_options() - specified tracking")
opts <- futurize_options(seed = TRUE)
stopifnot("seed" %in% attr(opts, "specified"))
stopifnot(!("globals" %in% attr(opts, "specified")))

opts <- futurize_options(seed = TRUE, globals = FALSE, packages = "foo",
                         stdout = FALSE, conditions = "warning",
                         scheduling = 2.0, chunk_size = 10L)
specified <- attr(opts, "specified")
stopifnot(all(c("seed", "globals", "packages", "stdout", "conditions",
                "scheduling", "chunk_size") %in% specified))

opts <- futurize_options(extra_opt = 42)
stopifnot("extra_opt" %in% attr(opts, "specified"))


message("*** is_s3_generic()")
stopifnot(isTRUE(futurize:::is_s3_generic(print)))
stopifnot(isTRUE(futurize:::is_s3_generic(summary)))
stopifnot(isFALSE(futurize:::is_s3_generic(identity)))
stopifnot(isFALSE(futurize:::is_s3_generic(sum))) ## primitive
foo <- function() NULL ## A function with NULL body
stopifnot(
  is.null(body(foo)),
  isFALSE(futurize:::is_s3_generic(foo))
)


message("*** parse_call() - namespace-qualified calls")
## base::lapply - valid namespace-qualified call
info <- futurize:::parse_call(quote(base::lapply), envir = globalenv())
stopifnot(info$fcn_name == "lapply", info$ns_name == "base")

## Non-existing function in a namespace
res <- tryCatch(
  futurize:::parse_call(quote(base::nonExistingFcn), envir = globalenv()),
  error = identity
)
stopifnot(inherits(res, "error"))

## Non-symbol operator in call, e.g. function call as operator
res <- tryCatch(
  futurize:::parse_call(quote((function() NULL)()), envir = globalenv()),
  error = identity
)
stopifnot(inherits(res, "error"))

## Non-supported operator (not :: or :::)
res <- tryCatch(
  futurize:::parse_call(quote(base$lapply), envir = globalenv()),
  error = identity
)
stopifnot(inherits(res, "error"))

## Unknown function
res <- tryCatch(
  futurize:::parse_call(as.symbol("nonExistingFcn"), envir = globalenv()),
  error = identity
)
stopifnot(inherits(res, "error"))

## Unknown infix operator
res <- tryCatch(
  futurize:::parse_call(as.symbol("%nonExisting%"), envir = globalenv()),
  error = identity
)
stopifnot(inherits(res, "error"))

## Non-call, non-symbol expression
res <- tryCatch(
  futurize:::parse_call(42, envir = globalenv()),
  error = identity
)
stopifnot(inherits(res, "error"))

## Primitive function - namespace detection
info <- futurize:::parse_call(as.symbol("sum"), envir = globalenv())
stopifnot(info$fcn_name == "sum", info$ns_name == "base")

## Debug mode with namespace-qualified call
info <- futurize:::parse_call(quote(base::lapply), envir = globalenv(), debug = TRUE)
stopifnot(info$fcn_name == "lapply", info$ns_name == "base")

## Debug mode with unqualified call
info <- futurize:::parse_call(as.symbol("lapply"), envir = globalenv(), debug = TRUE)
stopifnot(info$fcn_name == "lapply", info$ns_name == "base")


message("*** find_s3_method()")
find_s3_method <- futurize:::find_s3_method

## print() on a data.frame
df <- data.frame(a = 1)
res <- find_s3_method(
  fcn = print, fcn_name = "print",
  call = quote(print(df)), envir = environment()
)
stopifnot(
  is.list(res),
  res$name == "print.data.frame",
  is.character(res$package), nzchar(res$package)
)

## Ditto with debug = TRUE
res <- find_s3_method(
  fcn = print, fcn_name = "print",
  call = quote(print(df)), envir = environment(),
  debug = TRUE
)
stopifnot(is.list(res), res$name == "print.data.frame")

## Function with no formals
res <- find_s3_method(
  fcn = function() NULL, fcn_name = "nofmls",
  call = quote(nofmls()), envir = environment()
)
stopifnot(is.null(res))

## First argument is "..." returns NULL
dotfcn <- function(...) UseMethod("dotfcn")
res <- find_s3_method(
  fcn = dotfcn, fcn_name = "dotfcn",
  call = quote(dotfcn(x)), envir = environment()
)
stopifnot(is.null(res))

## Dispatch argument not provided in call
res <- find_s3_method(
  fcn = print, fcn_name = "print",
  call = quote(print()), envir = environment()
)
stopifnot(is.null(res))

## Dispatch argument is a literal
res <- find_s3_method(
  fcn = print, fcn_name = "print",
  call = quote(print(42)), envir = environment()
)
stopifnot(is.null(res))

## Dispatch object cannot be evaluated
res <- find_s3_method(
  fcn = print, fcn_name = "print",
  call = quote(print(nonExistingVar)), envir = environment()
)
stopifnot(is.null(res))

## No S3 method registered for this generic + class
my_generic <- function(x) UseMethod("my_generic")
obj <- structure(1, class = "noMethodForThis")
res <- find_s3_method(
  fcn = my_generic, fcn_name = "my_generic",
  call = quote(my_generic(obj)), envir = environment()
)
stopifnot(is.null(res))


message("*** append_call_arguments()")
call <- quote(my_fcn(x, y))
call2 <- futurize:::append_call_arguments(call, z = 42, w = quote(1 + 2))
stopifnot(length(call2) == 5L)
stopifnot("z" %in% names(as.list(call2)))
stopifnot("w" %in% names(as.list(call2)))

call3 <- futurize:::append_call_arguments(call, .args = list(a = 1))
stopifnot("a" %in% names(as.list(call3)))


message("*** make_options_for_doFuture() - chunk_size rename")
if (requireNamespace("doFuture", quietly = TRUE)) {
  opts <- futurize_options(chunk_size = 10L)
  result <- futurize:::make_options_for_doFuture(opts, wrap = FALSE)
  stopifnot("chunk.size" %in% names(result))
  stopifnot(!("chunk_size" %in% names(result)))
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
