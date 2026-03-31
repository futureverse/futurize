#' @tags pkg-lme4
if (requireNamespace("lme4") && getRversion() >= "4.4.0") {
library(futurize)
library(lme4)
options(future.rng.onMisuse = "error")

## Disable checks for stray assignments to the global environment(),
## because lme4::allFit() assigns a 'ctrl' variable when called.
## See https://github.com/lme4/lme4/issues/853 (aug 2025) for details.
options(future.globalenv.onMisuse = "warning")

all_equal <- function(a, b, ...) {
  ## Cannot use all.equal(a, b), because there is timing data
  a <- lapply(a, summary)
  b <- lapply(b, summary)
  all.equal(a, b, ...)
}

plan(multisession)

## Adopted from example("allFit", package = "lme4")
gm1 <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
             data = cbpp, family = binomial)

message("Ordinary processing:")
set.seed(42)
gm_all_truth <- allFit(gm1)
print(gm_all_truth)

message("Futurized processing:")
set.seed(42)
counters <- plan("backend")[["counters"]]
gm_all <- allFit(gm1) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(gm_all)

message("Comparing results:")
stopifnot(all_equal(gm_all, gm_all_truth))


if (utils::packageVersion("lme4") >= "2.0.1") {
  ## influence.merMod() via stats::influence() S3 generic dispatch
  ## Adopted from example("influence.merMod", package = "lme4")
  fm1 <- lmer(Reaction ~ Days + (Days | Subject), data = sleepstudy)
  stopifnot(inherits(fm1, "merMod"))
  
  message("Ordinary processing:")
  inf_truth <- influence(fm1, groups = "Subject")
  
  message("Futurized processing:")
  counters <- plan("backend")[["counters"]]
  inf <- influence(fm1, groups = "Subject") |> futurize()
  delta <- plan("backend")[["counters"]] - counters
  cat(sprintf("Futures created: %d\n", delta[["created"]]))
  stopifnot(delta[["created"]] > 0L)
  
  message("Comparing results:")
  stopifnot(all.equal(inf, inf_truth))
}

plan(sequential)
} ## if (requireNamespace("lme4"))
