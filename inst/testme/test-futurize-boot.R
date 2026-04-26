#' @tags pkg-boot
if (requireNamespace("boot") && getRversion() >= "4.4.0") {
library(futurize)
library(boot)
options(future.rng.onMisuse = "error")

all_equal <- function(a, b, ...) {
  a$call <- b$call <- NULL
  all.equal(a, b, ...)
}

plan(multisession)

#------------------------------------------------------------------
# boot()
#------------------------------------------------------------------
message("boot() ...")
## Adopted from example("boot", package = "boot")

ratio <- function(d, w) {
  sum(d$x * w)/sum(d$u * w)
}

set.seed(42)
b_truth <- boot(city, ratio, R = 999, stype = "w")
print(b_truth)

set.seed(42)
counters <- plan("backend")[["counters"]]
b <- boot(city, ratio, R = 999, stype = "w") |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(b)

stopifnot(all_equal(b, b_truth))

message("boot() ... done")


#------------------------------------------------------------------
# censboot()
#------------------------------------------------------------------
message("censboot() ...")
## Adopted from example("censboot", package = "boot")

if (requireNamespace("survival", quietly = TRUE)) {
  ## From example("censboot", package = "boot")
  library(survival)
  data(aml, package = "boot") # not the version in 'survival'
  
  aml.fun <- function(data) {
    surv <- survfit(Surv(time, cens) ~ group, data = data)
    out <- NULL
    st <- 1
    for (s in seq_along(surv$strata)) {
       inds <- st:(st + surv$strata[s] - 1)
       md <- min(surv$time[inds[1-surv$surv[inds] >= 0.5]])
       st <- st + surv$strata[s]
       out <- c(out, md)
    }
    out
  }

  R <- 100
  
  set.seed(42)
  cens_truth <- censboot(aml, aml.fun, R = R, strata = aml$group)
  print(cens_truth)
  
  set.seed(42)
  cens <- censboot(aml, aml.fun, R = R, strata = aml$group) |> futurize()
  print(cens)

  cens_truth$call <- NULL
  cens$call <- NULL
  stopifnot(all.equal(cens, cens_truth))
}

message("censboot() ... done")


plan(sequential)
} ## if (requireNamespace("boot"))
