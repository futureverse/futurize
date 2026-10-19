#' @tags pkg-terra
if (requireNamespace("terra") && requireNamespace("future.apply")) {
  library(futurize)
  library(terra)
  fcns <- tryCatch({
    futurize::futurize_supported_functions("terra")
  }, error = identity)
  print(fcns)
  stopifnot(is.character(fcns), length(fcns) > 0L)

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

  ## -------------------------------------------------------
  ## app(), lapp(), and predict()
  ## -------------------------------------------------------
  r3 <- rast(nrows = 30L, ncols = 30L, nlyr = 2L, vals = 1:1800)
  names(r3) <- c("x1", "x2")

  result_truth4 <- app(r3, fun = function(v) sum(v))
  result4 <- app(r3, fun = function(v) sum(v)) |> futurize_and_verify()
  stopifnot(all.equal(result4, result_truth4))

  result_truth5 <- lapp(r3, fun = function(a, b) a + b)
  result5 <- lapp(r3, fun = function(a, b) a + b) |> futurize_and_verify()
  stopifnot(all.equal(result5, result_truth5))

  set.seed(42)
  df <- data.frame(y = 1:100, x1 = rnorm(100), x2 = rnorm(100))
  model <- lm(y ~ x1 + x2, data = df)
  result_truth6 <- predict(r3, model)
  result6 <- predict(r3, model) |> futurize_and_verify()
  stopifnot(all.equal(result6, result_truth6))

  ## Argument 'cores' must not be specified when using futurize()
  res2 <- tryCatch({
    app(r3, fun = sum, cores = 2L) |> futurize()
    NULL
  }, error = identity)
  stopifnot(inherits(res2, "error"))

  plan(sequential)
} ## if (requireNamespace("terra") ...)
