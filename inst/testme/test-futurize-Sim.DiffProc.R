#' @tags pkg-Sim.DiffProc
if (requireNamespace("Sim.DiffProc") && getRversion() >= "4.4.0") {
library(futurize)
library(Sim.DiffProc)
options(future.rng.onMisuse = "error")

plan(multisession)

#------------------------------------------------------------------
# MCM.sde()
#------------------------------------------------------------------
message("MCM.sde() ...")

f <- expression(0)
g <- expression(1)
mod1d <- snssde1d(drift=f, diffusion=g, x0=1, M=10, N=100)
stat <- function(x, ...) mean(x)

res_truth <- MCM.sde(mod1d, statistic = stat, R = 10, time = 0.5)

res <- MCM.sde(mod1d, statistic = stat, R = 10, time = 0.5) |> futurize_and_verify()

## Compare structure/metadata since simulation results themselves are stochastic
stopifnot(
  identical(class(res), class(res_truth)),
  identical(names(res), names(res_truth)),
  identical(res$dim, res_truth$dim),
  identical(res$Class, res_truth$Class)
)

message("MCM.sde() ... done")

plan(sequential)
}
