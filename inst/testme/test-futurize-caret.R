#' @tags pkg-caret
if (requireNamespace("caret") && requireNamespace("randomForest") && requireNamespace("doFuture")) {
library(futurize)
library(caret)
options(future.rng.onMisuse = "error")

plan(multisession)

d_truth <- nearZeroVar(iris[, -5], saveMetrics = TRUE)
print(d_truth)

counters <- plan("backend")[["counters"]]
d <- nearZeroVar(iris[, -5], saveMetrics = TRUE) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(d)
stopifnot(all.equal(d, d_truth))


# Define training control
ctrl <- trainControl(method = "cv", number = 10)

set.seed(1011)
model_truth <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl)
print(model_truth)

set.seed(1011)
counters <- plan("backend")[["counters"]]
model <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(model)

## Cannot really compare results, because of different RNGs

plan(sequential)
} ## if (requireNamespace("caret") && requireNamespace("randomForest"))
