#' @tags pkg-future.apply
#' @tags pkg-doFuture
if (requireNamespace("future.apply")) {
library(futurize)
options(future.rng.onMisuse = "error")

plan(multisession, workers = 2L)

xs <- 1:4
fcn <- function(x) rnorm(1L)

message("*** futurize(rng = TRUE) - same as futurize(seed = TRUE)")
set.seed(42)
y_rng <- lapply(xs, fcn) |> futurize(rng = TRUE)
set.seed(42)
y_seed <- lapply(xs, fcn) |> futurize(seed = TRUE)
stopifnot(identical(y_rng, y_seed))

message("*** futurize(rng = TRUE) - reproducible")
set.seed(42)
y2 <- lapply(xs, fcn) |> futurize(rng = TRUE)
stopifnot(identical(y2, y_rng))

message("*** futurize(rng = FALSE) - RNG misuse is detected")
res <- tryCatch({
  lapply(xs, fcn) |> futurize(rng = FALSE)
}, error = identity)
stopifnot(inherits(res, "error"))

message("*** futurize(rng = FALSE) - overrides transpiler default")
## replicate() is futurized with seed = TRUE by default
y <- replicate(2L, 42) |> futurize(rng = FALSE)
stopifnot(identical(y, c(42, 42)))
res <- tryCatch({
  replicate(2L, rnorm(1L)) |> futurize(rng = FALSE)
}, error = identity)
stopifnot(inherits(res, "error"))

expr <- futurize(replicate(2L, 42), rng = FALSE, eval = FALSE)
print(expr)
stopifnot(identical(expr[["future.seed"]], FALSE))

expr <- futurize(lapply(xs, fcn), rng = TRUE, eval = FALSE)
print(expr)
stopifnot(identical(expr[["future.seed"]], TRUE))

message("*** futurize(rng = NA) - no RNG streams and no RNG checks")
y <- lapply(xs, fcn) |> futurize(rng = NA)
stopifnot(length(y) == length(xs))

expr <- futurize(lapply(xs, fcn), rng = NA, eval = FALSE)
print(expr)
stopifnot(
  "future.seed" %in% names(expr),
  is.null(expr[["future.seed"]])
)

## Same as seed = NULL
expr2 <- futurize(lapply(xs, fcn), seed = NULL, eval = FALSE)
print(expr2)
stopifnot(identical(expr2, expr))

## rng = NA overrides transpiler default seed = TRUE
expr <- futurize(replicate(2L, rnorm(1L)), rng = NA, eval = FALSE)
print(expr)
stopifnot(is.null(expr[["future.seed"]]))
y <- replicate(2L, rnorm(1L)) |> futurize(rng = NA)
stopifnot(length(y) == 2L)

plan(sequential)
} ## if (requireNamespace("future.apply"))


## doFuture (> 1.4.0) is needed for seed = NULL to disable the RNG check
if (requireNamespace("foreach") && requireNamespace("doFuture") &&
    packageVersion("doFuture") >= "1.4.0.9006") {
library(futurize)
library(foreach)
options(future.rng.onMisuse = "error")

plan(multisession, workers = 2L)

message("*** futurize(rng = ...) with foreach()")
set.seed(42)
y_rng <- foreach(x = 1:4) %do% rnorm(1L) |> futurize(rng = TRUE)
set.seed(42)
y_seed <- foreach(x = 1:4) %do% rnorm(1L) |> futurize(seed = TRUE)
stopifnot(identical(y_rng, y_seed))

res <- tryCatch({
  foreach(x = 1:4) %do% rnorm(1L) |> futurize(rng = FALSE)
}, error = identity)
stopifnot(inherits(res, "error"))

y <- foreach(x = 1:4) %do% rnorm(1L) |> futurize(rng = NA)
stopifnot(length(y) == 4L)

plan(sequential)
} ## if (requireNamespace("foreach") && ...)


message("*** futurize_options(rng = ...)")
opts <- futurize_options(rng = TRUE)
str(opts)
stopifnot(
  isTRUE(opts[["seed"]]),
  "seed" %in% attr(opts, "specified"),
  !"rng" %in% names(opts)
)

opts <- futurize_options(rng = FALSE)
stopifnot(
  isFALSE(opts[["seed"]]),
  "seed" %in% attr(opts, "specified")
)

opts <- futurize_options(rng = NA)
stopifnot(
  "seed" %in% names(opts),
  is.null(opts[["seed"]]),
  "seed" %in% attr(opts, "specified")
)

opts <- futurize_options()
stopifnot(
  isFALSE(opts[["seed"]]),
  !"seed" %in% attr(opts, "specified")
)


message("*** futurize_options(rng = ..., seed = ...) - error")
for (seed in list(TRUE, FALSE, 42L)) {
  res <- tryCatch(futurize_options(rng = TRUE, seed = seed), error = identity)
  stopifnot(
    inherits(res, "error"),
    grepl("'rng' and 'seed'", conditionMessage(res), fixed = TRUE)
  )
}

res <- tryCatch({
  futurize(lapply(1:2, identity), rng = TRUE, seed = TRUE, eval = FALSE)
}, error = identity)
stopifnot(
  inherits(res, "error"),
  grepl("'rng' and 'seed'", conditionMessage(res), fixed = TRUE)
)


message("*** futurize_options(rng = <invalid>) - error")
for (rng in list(NULL, NA_integer_, NA_character_, 42L, 1, "per-task", c(TRUE, FALSE), logical(0L))) {
  res <- tryCatch(futurize_options(rng = rng), error = identity)
  print(res)
  stopifnot(
    inherits(res, "error"),
    grepl("'rng' must be TRUE, FALSE, or NA", conditionMessage(res), fixed = TRUE)
  )
}
