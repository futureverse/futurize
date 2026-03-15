if (requireNamespace("shapr")) {
  library(futurize)
  library(shapr)
  options(future.rng.onMisuse = "error")

  plan(multisession)

  ## Simple linear model
  set.seed(42)
  x_train <- data.frame(x1 = rnorm(100), x2 = rnorm(100))
  y_train <- 2 * x_train$x1 + x_train$x2 + rnorm(100)
  model <- lm(y_train ~ x1 + x2, data = x_train)
  x_explain <- data.frame(x1 = rnorm(3), x2 = rnorm(3))
  phi0 <- mean(y_train)

  ## Compare Shapley values only (ignoring metadata like timing and paths)
  all_equal <- function(a, b, ...) {
    all.equal(a$shapley_values, b$shapley_values, ...)
  }

  ## -------------------------------------------------------
  ## explain()
  ## -------------------------------------------------------
  set.seed(42)
  result_truth <- shapr::explain(
    model = model,
    x_explain = x_explain,
    x_train = x_train,
    approach = "empirical",
    phi0 = phi0,
    verbose = NULL
  )
  print(result_truth)

  ## Futurized via explain()
  set.seed(42)
  counters <- plan("backend")[["counters"]]
  result <- explain(
    model = model,
    x_explain = x_explain,
    x_train = x_train,
    approach = "empirical",
    phi0 = phi0,
    verbose = NULL
  ) |> futurize()
  delta <- plan("backend")[["counters"]] - counters
  cat(sprintf("Futures created: %d\n", delta[["created"]]))
  stopifnot(delta[["created"]] > 0L)
  print(result)

  stopifnot(all_equal(result, result_truth))

  ## Futurized via shapr::explain()
  set.seed(42)
  counters <- plan("backend")[["counters"]]
  result2 <- shapr::explain(
    model = model,
    x_explain = x_explain,
    x_train = x_train,
    approach = "empirical",
    phi0 = phi0,
    verbose = NULL
  ) |> futurize()
  delta <- plan("backend")[["counters"]] - counters
  cat(sprintf("Futures created: %d\n", delta[["created"]]))
  stopifnot(delta[["created"]] > 0L)
  print(result2)

  stopifnot(all_equal(result2, result_truth))


  plan(sequential)
} ## if (requireNamespace("shapr"))
