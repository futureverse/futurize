#' @tags pkg-lme4
if (requireNamespace("lme4") && (getRversion() >= "4.4.0" || utils::packageVersion("lme4") >= "2.0-6")) {
library(futurize)
library(lme4)
fcns <- tryCatch({
  futurize::futurize_supported_functions("lme4")
}, error = identity)
print(fcns)
stopifnot(is.character(fcns), length(fcns) > 0L)
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
meth.tab <- allFit(show.meth.tab = TRUE)[1:2, , drop = FALSE]

message("Ordinary processing:")
set.seed(42)
gm_all_truth <- allFit(gm1, meth.tab = meth.tab)
print(gm_all_truth)

message("Futurized processing:")
set.seed(42)
gm_all <- allFit(gm1, meth.tab = meth.tab) |> futurize_and_verify()
print(gm_all)

message("Comparing results:")
stopifnot(all_equal(gm_all, gm_all_truth))

if (utils::packageVersion("lme4") >= "2.0.1") {
  ## influence.merMod() via stats::influence() S3 generic dispatch
  ## Adopted from example("influence.merMod", package = "lme4")
  sleepstudy_sub <- subset(sleepstudy, Subject %in% c("308", "309", "310", "330", "333"))
  fm1 <- lmer(Reaction ~ Days + (Days | Subject), data = sleepstudy_sub)
  stopifnot(inherits(fm1, "merMod"))
  
  message("Ordinary processing:")
  inf_truth <- influence(fm1, groups = "Subject")
  
  message("Futurized processing:")
  inf <- influence(fm1, groups = "Subject") |> futurize_and_verify()
  
  message("Comparing results:")
  stopifnot(all.equal(inf, inf_truth))
}

if (utils::packageVersion("lme4") >= "2.0-6") {
  ## bootMer() requires parallel RNG
  ## Adopted from example("bootMer", package = "lme4")
  fm01ML <- lmer(Yield ~ 1 | Batch, Dyestuff, REML = FALSE)
  mySumm <- function(.) { s <- sigma(.); c(beta = getME(., "beta"), sigma = s) }

  message("Futurized processing:")
  set.seed(42)
  boo_1 <- bootMer(fm01ML, mySumm, nsim = 3L) |> futurize_and_verify()
  set.seed(42)
  boo_2 <- bootMer(fm01ML, mySumm, nsim = 3L) |> futurize()

  message("Comparing results:")
  stopifnot(all.equal(boo_1$t, boo_2$t))
}

plan(sequential)
} ## if (requireNamespace("lme4"))
