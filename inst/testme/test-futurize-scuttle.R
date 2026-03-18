#' @tags skip_on_cran  ## (35s) to limit total check time
if (requireNamespace("scuttle") && requireNamespace("doFuture")) {
library(futurize)
library(scuttle)

plan(multisession)

## Create a simple SingleCellExperiment
set.seed(42)
n_genes <- 50L
n_cells <- 20L
counts <- matrix(
  rpois(n_genes * n_cells, lambda = 10),
  nrow = n_genes,
  ncol = n_cells
)
rownames(counts) <- paste0("gene", seq_len(n_genes))
colnames(counts) <- paste0("cell", seq_len(n_cells))

sce <- SingleCellExperiment::SingleCellExperiment(
  assays = list(counts = counts)
)


## ---------------------------------------------------------
## logNormCounts()
## ---------------------------------------------------------
result_truth <- logNormCounts(sce)

result <- logNormCounts(sce) |> futurize()
str(result)
stopifnot(all.equal(result, result_truth))

result2 <- scuttle::logNormCounts(sce) |> futurize()
str(result2)
stopifnot(all.equal(result2, result_truth))


## ---------------------------------------------------------
## perCellQCMetrics()
## ---------------------------------------------------------
result_truth <- perCellQCMetrics(sce)

counters <- plan("backend")[["counters"]]
result <- perCellQCMetrics(sce) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(all.equal(result, result_truth))

plan(sequential)
} ## if (requireNamespace("scuttle") && ...)
