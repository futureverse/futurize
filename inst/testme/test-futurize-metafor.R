#' @tags pkg-metafor
if (requireNamespace("metafor") && getRversion() >= "4.4.0") {
library(futurize)
library(metafor)
fcns <- tryCatch({
  futurize::futurize_supported_functions("metafor")
}, error = identity)
print(fcns)
stopifnot(is.character(fcns), length(fcns) > 0L)

plan(multisession)

## -------------------------------------------------------------------
## profile() - profile likelihood plots for rma objects
## -------------------------------------------------------------------
## Example from help("rma", package = "metafor")
dat <- escalc(measure = "RR", ai = tpos, bi = tneg,
              ci = cpos, di = cneg, data = dat.bcg)
fit <- rma(yi, vi, data = dat)

prof <- profile(fit) |> futurize_and_verify()
print(prof)

plan(sequential)
} ## if (requireNamespace("metafor"))
