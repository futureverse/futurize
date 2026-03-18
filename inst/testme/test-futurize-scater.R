#' @tags skip_on_cran  ## (35s) to limit total check time
if (requireNamespace("scater") && requireNamespace("doFuture")) {
library(futurize)
library(scater)
options(future.rng.onMisuse = "error")

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
sce <- scuttle::logNormCounts(sce)


## Standardize PCA sign so that the first loading of each
## component is positive.  This makes results comparable
## regardless of the arbitrary sign chosen by the SVD solver.
standardize_pca_sign <- function(pca) {
  rotation <- attr(pca, "rotation")
  signs <- sign(rotation[1L, ])
  signs[signs == 0] <- 1
  pca[] <- sweep(pca, 2L, signs, FUN = `*`)
  attr(pca, "rotation") <- sweep(rotation, 2L, signs, FUN = `*`)
  pca
}


## ---------------------------------------------------------
## runPCA()
## ---------------------------------------------------------
set.seed(42)
result_truth <- runPCA(sce)
result_truth <- reducedDim(result_truth, "PCA")
result_truth <- standardize_pca_sign(result_truth)
str(result_truth)

set.seed(42)
result <- runPCA(sce) |> futurize()
result <- reducedDim(result, "PCA")
result <- standardize_pca_sign(result)
str(result)
stopifnot(all.equal(result, result_truth))

set.seed(42)
result2 <- scater::runPCA(sce) |> futurize()
result2 <- reducedDim(result2, "PCA")
result2 <- standardize_pca_sign(result2)
str(result2)
stopifnot(all.equal(result2, result_truth))


## ---------------------------------------------------------
## getVarianceExplained()
## ---------------------------------------------------------
sce2 <- sce
sce2$group <- factor(rep(c("A", "B"), each = n_cells / 2L))

result_truth <- getVarianceExplained(sce2, variables = "group")

counters <- plan("backend")[["counters"]]
result <- getVarianceExplained(sce2, variables = "group") |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(all.equal(result, result_truth))

plan(sequential)
} ## if (requireNamespace("scater") && ...)
