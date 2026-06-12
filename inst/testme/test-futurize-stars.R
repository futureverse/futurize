#' @tags pkg-stars
if (requireNamespace("stars")) {
  library(futurize)
  library(stars)

  plan(multisession)

  ## Create a small stars object for testing
  m <- matrix(1:20, nrow = 5, ncol = 4)
  s <- st_as_stars(m)

  ## -------------------------------------------------------
  ## st_apply()
  ## -------------------------------------------------------
  result_truth <- stars::st_apply(s, MARGIN = 1, FUN = mean)
  print(result_truth)

  ## Futurized via st_apply()
  result <- st_apply(s, MARGIN = 1, FUN = mean) |> futurize_and_verify()
  print(result)

  stopifnot(all.equal(result, result_truth))

  ## Futurized via stars::st_apply()
  result2 <- stars::st_apply(s, MARGIN = 1, FUN = mean) |> futurize_and_verify()
  print(result2)

  stopifnot(all.equal(result2, result_truth))

  ## Assert that future.globals.maxSize is restored
  oopts <- getOption("future.globals.maxSize")
  result3 <- stars::st_apply(s, MARGIN = 1, FUN = mean) |> futurize_and_verify()
  stopifnot(identical(getOption("future.globals.maxSize"), oopts))

  plan(sequential)
} ## if (requireNamespace("stars"))
