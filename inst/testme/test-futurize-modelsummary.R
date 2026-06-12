#' @tags pkg-modelsummary
if (requireNamespace("modelsummary") && requireNamespace("future.apply")) {
  library(futurize)
  library(modelsummary)
  options(future.rng.onMisuse = "error")

  plan(multisession, workers = 2L)

  ## Fit two simple linear models
  fit1 <- lm(mpg ~ cyl, data = mtcars)
  fit2 <- lm(mpg ~ cyl + hp, data = mtcars)
  models <- list(Model1 = fit1, Model2 = fit2)

  ## -------------------------------------------------------
  ## modelsummary()
  ## -------------------------------------------------------

  ## Truth (sequential, with modelsummary_future = FALSE)
  oopts <- options(modelsummary_future = FALSE)
  result_truth <- modelsummary::modelsummary(
    models,
    output = "data.frame",
    fmt = 2
  )
  options(oopts)

  ## Futurized modelsummary()
  result <- modelsummary::modelsummary(
    models,
    output = "data.frame",
    fmt = 2
  ) |> futurize_and_verify()

  stopifnot(
    is.data.frame(result),
    nrow(result) > 0,
    all.equal(result, result_truth)
  )

  ## -------------------------------------------------------
  ## modelplot()
  ## -------------------------------------------------------

  ## Truth (sequential, with modelsummary_future = FALSE)
  oopts <- options(modelsummary_future = FALSE)
  result_plot_truth <- modelsummary::modelplot(models, draw = FALSE)
  options(oopts)

  ## Futurized modelplot()
  result_plot <- modelsummary::modelplot(models, draw = FALSE) |> futurize_and_verify()

  stopifnot(
    is.data.frame(result_plot),
    nrow(result_plot) > 0,
    all.equal(result_plot, result_plot_truth)
  )

  plan(sequential)
}
