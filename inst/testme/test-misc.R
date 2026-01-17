library(futurize)

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


message("Internals")
options(futurize.debug = TRUE)
futurize:::.onLoad("futurize", "futurize")

futurize:::register_all_transpilers()
futurize:::register_vignette_engine_during_build_only("futurize")
Sys.setenv(R_CMD = "something")
futurize:::register_vignette_engine_during_build_only("futurize")



