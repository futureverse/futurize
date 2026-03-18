library(futurize)
options(futurize.debug = TRUE)

# --------------------------------------------------------------------
# futurize()
# --------------------------------------------------------------------
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



# --------------------------------------------------------------------
# futurize_options()
# --------------------------------------------------------------------
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


# --------------------------------------------------------------------
# futurize_supported_packages() and futurize_supported_functions()
# --------------------------------------------------------------------
pkgs <- futurize_supported_packages()
print(pkgs)

for (pkg in c(pkgs, "future", "aNonExistingPackage")) {
  cat(sprintf("Package %s:\n", pkg))
  fcns <- tryCatch({
    futurize::futurize_supported_functions(pkg)
  }, error = identity)
  print(fcns)
}

## Assert that there are not clashes between supported packages
pkgs <- futurize_supported_packages()
for (pkg in rep(pkgs, times = 2L)) {
  cat(sprintf("Package %s:\n", pkg))
  ## futurize_supported_functions() fail if required packages
  ## are not supported
  fcns <- tryCatch({
    futurize::futurize_supported_functions(pkg)
  }, error = identity)
  print(fcns)
}
