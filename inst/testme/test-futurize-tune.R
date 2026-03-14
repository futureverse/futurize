if (requireNamespace("tune") && requireNamespace("parsnip") && requireNamespace("rsample") && requireNamespace("workflows") && requireNamespace("yardstick") && requireNamespace("future.apply")) {
library(futurize)
library(tune)
library(parsnip)
library(rsample)
library(workflows)
library(yardstick)
options(future.rng.onMisuse = "error")

plan(multisession)

set.seed(42)
folds <- vfold_cv(iris, v = 3)

spec <- decision_tree(mode = "classification") |>
  set_engine("rpart")

wf <- workflow() |>
  workflows::add_formula(Species ~ .) |>
  workflows::add_model(spec)

message("Ordinary processing:")
set.seed(42)
result_truth <- fit_resamples(wf, resamples = folds)
m_truth <- collect_metrics(result_truth)
print(m_truth)

message("Futurized processing:")
set.seed(42)
result <- fit_resamples(wf, resamples = folds) |> futurize()
m <- collect_metrics(result)
print(m)

message("Comparing results:")
stopifnot(all.equal(m, m_truth))


message("Ordinary processing (tune_grid):")
spec2 <- decision_tree(mode = "classification", cost_complexity = tune()) |>
  set_engine("rpart")

wf2 <- workflow() |>
  workflows::add_formula(Species ~ .) |>
  workflows::add_model(spec2)

grid <- dials::grid_regular(dials::cost_complexity(), levels = 3)

set.seed(42)
result_truth2 <- tune_grid(wf2, resamples = folds, grid = grid)
m_truth2 <- collect_metrics(result_truth2)
print(m_truth2)

message("Futurized processing (tune_grid):")
set.seed(42)
result2 <- tune_grid(wf2, resamples = folds, grid = grid) |> futurize()
m2 <- collect_metrics(result2)
print(m2)

message("Comparing results:")
stopifnot(all.equal(m2, m_truth2))

plan(sequential)
} ## if (requireNamespace("tune") && ...)
