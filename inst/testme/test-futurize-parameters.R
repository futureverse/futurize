#' @tags pkg-parameters
if (requireNamespace("parameters") && getRversion() >= "4.4.0") {
library(futurize)
library(parameters)
options(future.rng.onMisuse = "error")

plan(multisession)

#------------------------------------------------------------------
# bootstrap_model()
#------------------------------------------------------------------
message("bootstrap_model() ...")

## Case A: lm model (uses bootstrap_model.default)
data(mtcars, package = "datasets")
model_lm <- lm(mpg ~ wt, data = mtcars)

set.seed(42)
fit_lm <- bootstrap_model(model_lm, iterations = 10L) |> futurize_and_verify()

print(head(fit_lm))
stopifnot(inherits(fit_lm, "bootstrap_model"))

## Case B: merMod model (uses bootstrap_model.merMod)
if (requireNamespace("lme4", quietly = TRUE)) {
  library(lme4)
  model_lmer <- lmer(Reaction ~ Days + (Days | Subject), sleepstudy)

  set.seed(42)
  fit_lmer <- bootstrap_model(model_lmer, iterations = 10L) |> futurize_and_verify()
  ## If it correctly uses ClusterFuture, delta[["created"]] should be > 0
  ## Actually, future::makeClusterFuture() creates a cluster that 
  ## bootstrap_model() then uses.
  print(head(fit_lmer))
  stopifnot(inherits(fit_lmer, "bootstrap_model"))
}

message("bootstrap_model() ... done")


#------------------------------------------------------------------
# bootstrap_parameters()
#------------------------------------------------------------------
message("bootstrap_parameters() ...")

set.seed(42)

params <- bootstrap_parameters(model_lm, iterations = 10L) |> futurize_and_verify()

print(params)
stopifnot(inherits(params, "parameters_model"))

message("bootstrap_parameters() ... done")

plan(sequential)
}
