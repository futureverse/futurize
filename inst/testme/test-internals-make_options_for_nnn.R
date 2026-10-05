library(futurize)

message("make_options_for_makeClusterFuture()")
opts <- futurize:::make_options_for_makeClusterFuture(options = list())
str(opts)
opts <- futurize:::make_options_for_makeClusterFuture(options = list(), defaults = list(packages = character(0L), stdout = TRUE))
str(opts)

## Required packages are appended to the default packages
opts <- futurize:::make_options_for_makeClusterFuture(options = futurize_options(), defaults = list(packages = "lme4"))
str(opts)
stopifnot(identical(opts[["packages"]], "lme4"))

## Required packages are appended to user-specified packages
opts <- futurize:::make_options_for_makeClusterFuture(options = futurize_options(packages = "tools"), defaults = list(packages = "lme4"))
str(opts)
stopifnot(identical(opts[["packages"]], c("tools", "lme4")))

## ... without duplicates
opts <- futurize:::make_options_for_makeClusterFuture(options = futurize_options(packages = c("lme4", "tools")), defaults = list(packages = "lme4"))
str(opts)
stopifnot(identical(opts[["packages"]], c("lme4", "tools")))

message("make_options_for_future.apply()")
if (requireNamespace("future.apply", quietly = TRUE)) {
  fcn <- future.apply::future_lapply

  ## Required packages are appended to the default packages
  opts <- futurize:::make_options_for_future.apply(options = futurize_options(), fcn = fcn, defaults = list(future.packages = "lme4"))
  str(opts)
  stopifnot(identical(opts[["future.packages"]], "lme4"))

  ## Required packages are appended to user-specified packages
  opts <- futurize:::make_options_for_future.apply(options = futurize_options(packages = "tools"), fcn = fcn, defaults = list(future.packages = "lme4"))
  str(opts)
  stopifnot(identical(opts[["future.packages"]], c("tools", "lme4")))

  ## ... without duplicates
  opts <- futurize:::make_options_for_future.apply(options = futurize_options(packages = c("lme4", "tools")), fcn = fcn, defaults = list(future.packages = "lme4"))
  str(opts)
  stopifnot(identical(opts[["future.packages"]], c("lme4", "tools")))
}

message("*** make_options_for_doFuture()")
if (requireNamespace("doFuture", quietly = TRUE)) {
  opts <- futurize_options(chunk_size = 10L)
  result <- futurize:::make_options_for_doFuture(opts, wrap = FALSE)
  stopifnot("chunk.size" %in% names(result))
  stopifnot(!("chunk_size" %in% names(result)))
}

## Assert that future options are properly named
options <- list(seed = TRUE)
attr(options, "specified") <- "seed"
doFuture_options <- futurize:::make_options_for_doFuture(options, wrap = TRUE)
print(doFuture_options)
stopifnot(
  length(doFuture_options) == 1L,
  names(doFuture_options) == ".options.future"
)
opts <- doFuture_options[[".options.future"]]
stopifnot(
  length(opts) == 1L,
  names(opts) == "seed"
)
