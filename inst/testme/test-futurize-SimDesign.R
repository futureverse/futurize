#' @tags pkg-SimDesign
if (requireNamespace("SimDesign") && getRversion() >= "4.4.0") {
library(futurize)
library(SimDesign)

plan(multisession)

## -------------------------------------------------------------------
## runSimulation() - Monte Carlo simulation
## -------------------------------------------------------------------
## Adopted from help("runSimulation", package = "SimDesign")
Design <- createDesign(
  sample_size = c(30, 60),
  distribution = c("norm", "chi")
)

Generate <- function(condition, fixed_objects) {
  N <- condition$sample_size
  dist <- condition$distribution
  if (dist == "norm") {
    dat <- rnorm(N)
  } else if (dist == "chi") {
    dat <- rchisq(N, df = 5)
  }
  dat
}

Analyse <- function(condition, dat, fixed_objects) {
  ret <- mean(dat)
  c(mean_est = ret)
}

Summarise <- function(condition, results, fixed_objects) {
  obs_bias <- bias(results[, "mean_est"],
    parameter = ifelse(condition$distribution == "norm", 0, 5))
  obs_RMSE <- RMSE(results[, "mean_est"],
    parameter = ifelse(condition$distribution == "norm", 0, 5))
  c(bias = obs_bias, RMSE = obs_RMSE)
}

counters <- plan("backend")[["counters"]]
res <- runSimulation(
  design = Design,
  replications = 10,
  generate = Generate,
  analyse = Analyse,
  summarise = Summarise,
  save = FALSE
) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created (runSimulation): %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(res)

plan(sequential)
} ## if (requireNamespace("SimDesign"))
