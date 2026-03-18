#' @tags skip_on_cran  ## (35s) to limit total check time
if (requireNamespace("SingleCellExperiment") && requireNamespace("scuttle") && requireNamespace("doFuture")) {
library(futurize)
library(SingleCellExperiment)
library(scuttle)

plan(multisession)

## Create a simple SingleCellExperiment with alternative experiments
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

sce <- SingleCellExperiment(
  assays = list(counts = counts)
)

## Add an alternative experiment (e.g. spike-ins)
spike_counts <- matrix(
  rpois(10L * n_cells, lambda = 5),
  nrow = 10L,
  ncol = n_cells
)
rownames(spike_counts) <- paste0("spike", seq_len(10L))
colnames(spike_counts) <- paste0("cell", seq_len(n_cells))

altExp(sce, "spikes") <- SingleCellExperiment(
  assays = list(counts = spike_counts)
)


## ---------------------------------------------------------
## applySCE() with perCellQCMetrics
## ---------------------------------------------------------
result_truth <- applySCE(sce, perCellQCMetrics)

counters <- plan("backend")[["counters"]]
result <- applySCE(sce, perCellQCMetrics) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(all.equal(result, result_truth))

result2 <- SingleCellExperiment::applySCE(sce, perCellQCMetrics) |> futurize()
stopifnot(all.equal(result2, result_truth))


plan(sequential)
} ## if (requireNamespace("SingleCellExperiment") && ...)
