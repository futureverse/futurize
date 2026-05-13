#' @tags skip_on_cran  ## (35s) to limit total check time
if (requireNamespace("scuttle") && requireNamespace("doFuture") && requireNamespace("DelayedArray")) {
library(futurize)
library(scuttle)
library(DelayedArray)

## Use a small block size to ensure multiple blocks and thus multiple futures
setAutoBlockSize(10000)

plan(multisession)

## Create a simple SingleCellExperiment
set.seed(42)
n_genes <- 1000L
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

result <- logNormCounts(sce) |> futurize() ## FIXME: futurize_and_verify()
str(result)
stopifnot(all.equal(result, result_truth))

result2 <- scuttle::logNormCounts(sce) |> futurize() ## FIXME: futurize_and_verify()
str(result2)
stopifnot(all.equal(result2, result_truth))

## ---------------------------------------------------------
## perFeatureQCMetrics()
## ---------------------------------------------------------
result_truth <- perFeatureQCMetrics(sce)

result <- perFeatureQCMetrics(sce) |> futurize_and_verify()
stopifnot(all.equal(result, result_truth))

plan(sequential)
} ## if (requireNamespace("scuttle") && ...)
