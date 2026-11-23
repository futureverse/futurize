#' @tags pkg-mlr3
if (requireNamespace("mlr3") && requireNamespace("rpart")) {
library(futurize)
library(mlr3)
fcns <- tryCatch({
  futurize::futurize_supported_functions("mlr3")
}, error = identity)
print(fcns)
stopifnot(is.character(fcns), length(fcns) > 0L)
options(future.rng.onMisuse = "error")

task <- tsk("penguins")
learner <- lrn("classif.rpart")

## Use the same resampling folds for all calls
set.seed(42)
resampling <- rsmp("cv", folds = 3L)
resampling$instantiate(task)


## Truth results are calculated sequentially
plan(sequential)
design <- benchmark_grid(task, list(learner, lrn("classif.featureless")), resampling)

message("Ordinary processing:")
set.seed(42)
rr_truth <- resample(task, learner, resampling)
print(rr_truth)
set.seed(42)
bmr_truth <- benchmark(design)
print(bmr_truth)


## Futurized results are calculated in parallel
plan(multisession, workers = 2L)

## resample()
message("Futurized processing:")
set.seed(42)
rr <- resample(task, learner, resampling) |> futurize_and_verify()
print(rr)

message("Comparing results:")
stopifnot(all.equal(rr$aggregate(), rr_truth$aggregate()))
stopifnot(all.equal(as.data.table(rr$prediction()), as.data.table(rr_truth$prediction())))


## benchmark()
message("Futurized processing:")
set.seed(42)
bmr <- benchmark(design) |> futurize_and_verify()
print(bmr)

message("Comparing results:")
stopifnot(all.equal(bmr$aggregate()[["classif.ce"]], bmr_truth$aggregate()[["classif.ce"]]))


## futurize() makes 'mlr3' use futures, even if mirai daemons have been
## set up for the 'mlr3' compute profile
if (requireNamespace("mirai")) {
  message("Futurized processing with mirai daemons for 'mlr3_parallelization':")
  rr2 <- local({
    mirai::daemons(1L, .compute = "mlr3_parallelization")
    on.exit(mirai::daemons(0L, .compute = "mlr3_parallelization"))
    stopifnot(mirai::daemons_set(.compute = "mlr3_parallelization"))

    ## Sanity check: without futurize(), 'mlr3' uses mirai, not futures
    backend <- plan("backend")
    created <- backend[["counters"]][["created"]]
    rr <- resample(task, learner, resampling)
    stopifnot(backend[["counters"]][["created"]] == created)

    set.seed(42)
    resample(task, learner, resampling) |> futurize_and_verify()
  })
  stopifnot(!mirai::daemons_set(.compute = "mlr3_parallelization"))
  stopifnot(all.equal(rr2$aggregate(), rr_truth$aggregate()))
  stopifnot(is.null(getOption("mlr3.mirai_parallelization")))
}

plan(sequential)
} ## if (requireNamespace("mlr3"))
