#' @tags skip_on_cran  ## to limit total check time
#' @tags pkg-ez
if (requireNamespace("ez") && getRversion() >= "4.4.0") {
library(futurize)
library(ez)
options(future.rng.onMisuse = "error")

plan(multisession)

# Read in the ANT data and subset to make it fast
data(ANT, package = "ez")
ANT <- subset(ANT, subnum %in% levels(subnum)[c(1, 2, 11, 12)])

#------------------------------------------------------------------
# ezBoot() and ezPlot2()
#------------------------------------------------------------------
message("ezBoot() and ezPlot2() ...")

set.seed(42)
rt_truth <- ezBoot(
  data = ANT,
  dv = rt,
  wid = subnum,
  within = .(cue, flank),
  between = group,
  iterations = 3L
)

set.seed(42)
rt <- ezBoot(
  data = ANT,
  dv = rt,
  wid = subnum,
  within = .(cue, flank),
  between = group,
  iterations = 3L
) |> futurize_and_verify()

stopifnot(
  identical(class(rt), class(rt_truth)),
  identical(names(rt), names(rt_truth)),
  identical(dim(rt$cells), dim(rt_truth$cells))
)

message("ezPlot2() ...")
p_truth <- ezPlot2(
  preds = rt_truth,
  x = flank,
  split = cue,
  col = group,
  do_plot = FALSE
)

p <- ezPlot2(
  preds = rt,
  x = flank,
  split = cue,
  col = group,
  do_plot = FALSE
) |> futurize_and_verify()

stopifnot(
  identical(class(p), class(p_truth)),
  identical(names(p), names(p_truth))
)

message("ezBoot() and ezPlot2() ... done")

#------------------------------------------------------------------
# ezPerm()
#------------------------------------------------------------------
message("ezPerm() ...")

# Compute some useful statistics per cell.
library(plyr)
cell_stats <- ddply(
  .data = ANT,
  .variables = .(subnum, group, cue, flank),
  .fun = function(x) {
    to_return <- data.frame(
      mrt = mean(x$rt[x$error == 0])
    )
    return(to_return)
  }
)

# Compute the grand mean RT per Ss.
gmrt <- ddply(
  .data = cell_stats,
  .variables = .(subnum, group),
  .fun = function(x) {
    to_return <- data.frame(
      mrt = mean(x$mrt)
    )
    return(to_return)
  }
)

set.seed(42)
perm_truth <- ezPerm(
  data = gmrt,
  dv = mrt,
  wid = subnum,
  between = group,
  perms = 3L
)

set.seed(42)
perm <- ezPerm(
  data = gmrt,
  dv = mrt,
  wid = subnum,
  between = group,
  perms = 3L
) |> futurize_and_verify()

# The exact p-values may differ due to different sequential vs. future RNG kinds (MT vs. L'Ecuyer-CMRG),
# but the structure, names, and dimensions should match exactly.
stopifnot(
  identical(class(perm), class(perm_truth)),
  identical(names(perm), names(perm_truth)),
  identical(dim(perm), dim(perm_truth))
)

message("ezPerm() ... done")

plan(sequential)
}
