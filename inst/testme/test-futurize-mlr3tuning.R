#' @tags pkg-mlr3tuning
if (requireNamespace("mlr3tuning") && requireNamespace("rpart")) {
library(futurize)
library(mlr3tuning)
fcns <- tryCatch({
  futurize::futurize_supported_functions("mlr3tuning")
}, error = identity)
print(fcns)
stopifnot(is.character(fcns), length(fcns) > 0L)
options(future.rng.onMisuse = "error")

task <- tsk("penguins")
learner <- lrn("classif.rpart", cp = to_tune(1e-4, 1e-1, logscale = TRUE))
tuner <- tnr("grid_search", resolution = 4L, batch_size = 2L)
measure <- msr("classif.ce")

## Use the same resampling folds for all calls
set.seed(42)
resampling <- rsmp("cv", folds = 3L)
resampling$instantiate(task)

archive_ce <- function(instance) {
  ce <- as.data.table(instance$archive)[, c("cp", "classif.ce")]
  ce[order(ce[["cp"]]), ]
}


## Truth results are calculated sequentially
plan(sequential)

message("Ordinary processing:")
set.seed(42)
instance_truth <- tune(tuner, task, learner, resampling, measure, term_evals = 4L)
print(instance_truth$result)
set.seed(42)
rr_truth <- tune_nested(tuner, task, learner, rsmp("holdout"), resampling, measure, term_evals = 2L)
print(rr_truth$aggregate())


## Futurized results are calculated in parallel
plan(multisession, workers = 2L)

## tune()
message("Futurized processing:")
set.seed(42)
instance <- tune(tuner, task, learner, resampling, measure, term_evals = 4L) |> futurize_and_verify()
print(instance$result)

message("Comparing results:")
stopifnot(all.equal(archive_ce(instance), archive_ce(instance_truth)))


## tune_nested()
message("Futurized processing:")
set.seed(42)
rr <- tune_nested(tuner, task, learner, rsmp("holdout"), resampling, measure, term_evals = 2L) |> futurize_and_verify()
print(rr$aggregate())

message("Comparing results:")
stopifnot(all.equal(rr$aggregate(), rr_truth$aggregate()))


## Asynchronous tuners are not supported
message("Asynchronous tuners are not supported:")
tuner_async <- suppressWarnings(tnr("async_random_search"))
stopifnot(inherits(tuner_async, "TunerAsync"))
res <- tryCatch({
  tune(tuner_async, task, learner, resampling, measure, term_evals = 4L) |> futurize()
}, error = identity)
print(res)
stopifnot(inherits(res, "error"), grepl("asynchronous tuners", conditionMessage(res)))

plan(sequential)
} ## if (requireNamespace("mlr3tuning"))
