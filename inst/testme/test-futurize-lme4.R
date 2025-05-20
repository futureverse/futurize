if (requireNamespace("lme4") && requireNamespace("future.ideas")) {
library(futurize)
library(lme4)

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
gm_all <- allFit(gm1) |> futurize(packages = "lme4")
print(gm_all)

message("Comparing results:")
stopifnot(all_equal(gm_all, gm_all_truth))

plan(sequential)
} ## if (requireNamespace("lme4"))
