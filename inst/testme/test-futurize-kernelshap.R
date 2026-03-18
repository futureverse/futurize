if (requireNamespace("kernelshap") && requireNamespace("doFuture")) {
  library(futurize)
  library(kernelshap)
  options(future.rng.onMisuse = "error")

  plan(multisession)

  ## Simple linear model
  set.seed(42)
  x_train <- data.frame(x1 = rnorm(100), x2 = rnorm(100))
  y_train <- 2 * x_train$x1 + x_train$x2 + rnorm(100)
  model <- lm(y ~ x1 + x2, data = data.frame(y = y_train, x_train))
  x_explain <- x_train[1:4, ]
  bg_X <- x_train[1:20, ]


  ## -------------------------------------------------------
  ## kernelshap()
  ## -------------------------------------------------------
  set.seed(42)
  result_truth <- kernelshap(
    model, X = x_explain, bg_X = bg_X
  )
  print(result_truth)

  set.seed(42)
  counters <- plan("backend")[["counters"]]
  result <- kernelshap(
    model, X = x_explain, bg_X = bg_X
  ) |> futurize()
  delta <- plan("backend")[["counters"]] - counters
  cat(sprintf("Futures created: %d\n", delta[["created"]]))
  stopifnot(delta[["created"]] > 0L)
  print(result)

  stopifnot(all.equal(result$S, result_truth$S))
  stopifnot(all.equal(result$SE, result_truth$SE))


  ## -------------------------------------------------------
  ## permshap()
  ## -------------------------------------------------------
  set.seed(42)
  result_truth2 <- permshap(
    model, X = x_explain, bg_X = bg_X
  )
  print(result_truth2)

  set.seed(42)
  counters <- plan("backend")[["counters"]]
  result2 <- permshap(
    model, X = x_explain, bg_X = bg_X
  ) |> futurize()
  delta <- plan("backend")[["counters"]] - counters
  cat(sprintf("Futures created: %d\n", delta[["created"]]))
  stopifnot(delta[["created"]] > 0L)
  print(result2)

  stopifnot(all.equal(result2$S, result_truth2$S))
  stopifnot(all.equal(result2$SE, result_truth2$SE))


  plan(sequential)
} ## if (requireNamespace("kernelshap") && requireNamespace("doFuture"))
