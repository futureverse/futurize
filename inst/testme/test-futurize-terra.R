#' @tags pkg-terra
if (requireNamespace("terra") && requireNamespace("future.apply")) {
  library(futurize)
  library(terra)

  plan(multisession, workers = 2)

  ## We need a raster large enough for focal() to run in parallel,
  ## which happens at nrow(v) >= max(256L, 64L * nworkers), i.e.
  ## nrow(v) >= 256 for nworkers = 2
  set.seed(42)
  r <- rast(nrows = 200L, ncols = 200L, vals = runif(200 * 200))
  myfun <- function(v) mean(v, na.rm = TRUE)

  ## -------------------------------------------------------
  ## focal()
  ## -------------------------------------------------------
  result_truth <- focal(r, w = 3, fun = myfun)

  result <- focal(r, w = 3, fun = myfun) |> futurize_and_verify()

  stopifnot(all.equal(result, result_truth))

  ## Also test with a fully-qualified call
  result_qualified <- terra::focal(r, w = 3, fun = myfun) |> futurize_and_verify()

  stopifnot(all.equal(result_qualified, result_truth))

  ## -------------------------------------------------------
  ## tile_apply()
  ## -------------------------------------------------------
  r2 <- rast(nrows = 20, ncols = 20, vals = 1:400)

  result_truth2 <- tile_apply(r2, function(x) x * 2, tiles = 10L)

  result2 <- tile_apply(r2, function(x) x * 2, tiles = 10L) |> futurize_and_verify()

  stopifnot(all.equal(result2, result_truth2))

  ## Assert R option 'future.disposable' is undone
  oopts <- getOption("future.disposable")
  result3 <- tile_apply(r2, function(x) x * 2, tiles = 10L) |> futurize_and_verify()
  stopifnot(identical(getOption("future.disposable"), oopts))

  ## Argument 'cores' must not be specified when using futurize()
  res <- tryCatch({
    tile_apply(r2, function(x) x * 2, cores = 2L) |> futurize()
    NULL
  }, error = identity)
  stopifnot(inherits(res, "error"))

  plan(sequential)
} ## if (requireNamespace("terra") ...)
