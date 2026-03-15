if (requireNamespace("fgsea") && requireNamespace("doFuture")) {
library(futurize)
library(fgsea)
options(future.rng.onMisuse = "error")

plan(multisession)

## Create simple test data
set.seed(42)
n_genes <- 100L
stats <- rnorm(n_genes)
names(stats) <- paste0("gene", seq_len(n_genes))

pathways <- list(
  pathway1 = paste0("gene", sample(n_genes, 10L)),
  pathway2 = paste0("gene", sample(n_genes, 15L)),
  pathway3 = paste0("gene", sample(n_genes, 20L))
)


## ---------------------------------------------------------
## fgseaSimple()
## ---------------------------------------------------------
set.seed(42)
result_truth <- fgseaSimple(pathways, stats, nperm = 10000)
print(result_truth)

set.seed(42)
counters <- plan("backend")[["counters"]]
result <- fgseaSimple(pathways, stats, nperm = 10000) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(result)
stopifnot(all.equal(result$pval, result_truth$pval))

set.seed(42)
counters <- plan("backend")[["counters"]]
result2 <- fgsea::fgseaSimple(pathways, stats, nperm = 10000) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(all.equal(result2$pval, result_truth$pval))


## ---------------------------------------------------------
## fgsea() via fgseaMultilevel()
## ---------------------------------------------------------
## To test fgsea(), we need a large enough data set with
## strong enrichment signals so that fgseaMultilevel() needs
## multilevel refinement. Hence the a bit complicated
## simulation set up.
set.seed(42)
n_genes2 <- 500L
stats2 <- rnorm(n_genes2)
names(stats2) <- paste0("gene", seq_len(n_genes2))

## Give pathway genes strong positive signals
p1 <- paste0("gene", 1:15)
p2 <- paste0("gene", 31:55)
p3 <- paste0("gene", 71:105)
p4 <- paste0("gene", 121:170)
stats2[p1] <- stats2[p1] + 4
stats2[p2] <- stats2[p2] + 3
stats2[p3] <- stats2[p3] + 3
stats2[p4] <- stats2[p4] + 3

pathways2 <- list(
  pathway1 = p1,
  pathway2 = p2,
  pathway3 = p3,
  pathway4 = p4
)

set.seed(42)
result_truth <- fgsea(pathways2, stats2)
print(result_truth)

set.seed(42)
counters <- plan("backend")[["counters"]]
result <- fgsea(pathways2, stats2) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(result)
stopifnot(all.equal(result$pval, result_truth$pval))

set.seed(42)
counters <- plan("backend")[["counters"]]
result2 <- fgsea::fgsea(pathways2, stats2) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(all.equal(result2$pval, result_truth$pval))


plan(sequential)
} ## if (requireNamespace("fgsea") && ...)
