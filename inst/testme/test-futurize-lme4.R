if (requireNamespace("lme4")) {
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
gm_all <- allFit(gm1) |> futurize()
print(gm_all)

message("Comparing results:")
stopifnot(all_equal(gm_all, gm_all_truth))

plan(sequential)
} ## if (requireNamespace("lme4"))
