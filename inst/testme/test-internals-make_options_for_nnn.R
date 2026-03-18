library(futurize)

message("make_options_for_makeClusterFuture()")
opts <- futurize:::make_options_for_makeClusterFuture(options = list())
str(opts)
opts <- futurize:::make_options_for_makeClusterFuture(options = list(), defaults = list(packages = character(0L), stdout = TRUE))
str(opts)

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
