#' @tags skip_on_cran  ## (20s) to limit total check time
if (requireNamespace("bumphunter") && requireNamespace("doFuture")) {
library(futurize)
library(bumphunter)
fcns <- tryCatch({
  futurize::futurize_supported_functions("bumphunter")
}, error = identity)
print(fcns)
stopifnot(is.character(fcns), length(fcns) > 0L)
print(sessionInfo())

options(future.rng.onMisuse = "error")

plan(multisession, workers = 2L)

## Create simple test data with a differentially methylated region
pos <- list(
  pos1 = seq(from =    1L, to = 1000L, by = 35L),
  pos2 = seq(from = 2001L, to = 3000L, by = 35L),
  pos3 = seq(from =    1L, to = 1000L, by = 50L)
)
chr <- rep(paste0("chr", c(1, 1, 2)), times = lengths(pos))
pos <- unlist(pos, use.names = FALSE)
set.seed(42)
y <- matrix(rnorm(length(pos) * 10L), nrow = length(pos), ncol = 10L)
y[1:10, 6:10] <- y[1:10, 6:10] + 2
design <- cbind(1, rep(0:1, each = 5L))
cluster <- clusterMaker(chr, pos, maxGap = 300)


## ---------------------------------------------------------
## bumphunter()
## ---------------------------------------------------------
set.seed(42)
truth <- bumphunter(y, design, chr = chr, pos = pos, cutoff = 0.5, B = 20L, smooth = TRUE, verbose = FALSE)
truth_next <- runif(1L)
str(truth$table)

set.seed(42)
result <- bumphunter(y, design, chr = chr, pos = pos, cutoff = 0.5, B = 20L, smooth = TRUE, verbose = FALSE) |> futurize_and_verify()
result_next <- runif(1L)
str(result$table)
stopifnot(all.equal(result$table, truth$table))
stopifnot(all.equal(result$null, truth$null))

## The RNG state after the call is the same as when run sequentially
stopifnot(identical(result_next, truth_next))


## ---------------------------------------------------------
## bumphunterEngine() with bootstrap null distribution
## ---------------------------------------------------------
set.seed(42)
truth <- bumphunterEngine(y, design, chr = chr, pos = pos, cutoff = 0.5, B = 20L, nullMethod = "bootstrap", verbose = FALSE)
str(truth$table)

set.seed(42)
result <- bumphunter::bumphunterEngine(y, design, chr = chr, pos = pos, cutoff = 0.5, B = 20L, nullMethod = "bootstrap", verbose = FALSE) |> futurize_and_verify()
str(result$table)
stopifnot(all.equal(result$table, truth$table))
stopifnot(all.equal(result$null, truth$null))


## ---------------------------------------------------------
## smoother()
## ---------------------------------------------------------
truth <- smoother(y = y[, 1], x = pos, cluster = cluster, smoothFunction = runmedByCluster, k = 3, verbose = FALSE)
str(truth)

result <- smoother(y = y[, 1], x = pos, cluster = cluster, smoothFunction = runmedByCluster, k = 3, verbose = FALSE) |> futurize_and_verify()
str(result)
stopifnot(all.equal(result, truth))

plan(sequential)
} ## if (requireNamespace("bumphunter") && ...)
