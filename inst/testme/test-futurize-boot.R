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
b_truth <- boot(city, ratio, R = 99L, stype = "w")
print(b_truth)

set.seed(42)
b <- boot(city, ratio, R = 99L, stype = "w") |> futurize_and_verify()
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

  R <- 100L
  
  set.seed(42)
  b_truth <- censboot(aml, aml.fun, R = R, strata = aml$group)
  print(b_truth)
  
  set.seed(42)
  b <- censboot(aml, aml.fun, R = R, strata = aml$group) |> futurize_and_verify()
  print(b)

  b_truth$call <- NULL
  b$call <- NULL
  stopifnot(all.equal(b, b_truth))
}

message("censboot() ... done")

#------------------------------------------------------------------
# tsboot()
#------------------------------------------------------------------
message("tsboot() ...")
## Adopted from example("tsboot", package = "boot")

## stats::ar()
if (requireNamespace("stats", quietly = TRUE)) {

  lynx.fun <- function(tsb) {
    ar.fit <- ar(tsb, order.max = 25)
    c(ar.fit$order, mean(tsb), tsb)
  }

  R <- 99L
  
  set.seed(42)
  b_truth <- tsboot(log(lynx), lynx.fun, R = R, l = 20, sim = "geom")
  str(b_truth)
  
  set.seed(42)
  b <- tsboot(log(lynx), lynx.fun, R = R, l = 20, sim = "geom") |> futurize_and_verify()
  str(b)

  b_truth$call <- NULL
  b$call <- NULL
  stopifnot(all.equal(b, b_truth))
}

message("tsboot() ... done")

plan(sequential)
} ## if (requireNamespace("boot"))
