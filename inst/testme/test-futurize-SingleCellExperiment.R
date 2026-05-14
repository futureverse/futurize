#' @tags skip_on_cran  ## (35s) to limit total check time
if (requireNamespace("SingleCellExperiment") && requireNamespace("scuttle") && requireNamespace("doFuture") && requireNamespace("DelayedArray")) {
library(futurize)
library(SingleCellExperiment)
library(scuttle)
library(DelayedArray)

## Use a small block size to ensure multiple blocks and thus multiple futures
setAutoBlockSize(10000)

plan(multisession)

## Create a simple SingleCellExperiment with alternative experiments
set.seed(42)
sce <- mockSCE(ncells = 20L, ngenes = 70L, nspikes = 30L)

## ---------------------------------------------------------
## applySCE() with perFeatureQCMetrics
## ---------------------------------------------------------
result_truth <- applySCE(sce, perFeatureQCMetrics)

result <- applySCE(sce, perFeatureQCMetrics) |> futurize_and_verify()
stopifnot(all.equal(result, result_truth))

result2 <- SingleCellExperiment::applySCE(sce, perFeatureQCMetrics) |> futurize_and_verify()
stopifnot(all.equal(result2, result_truth))

plan(sequential)
} ## if (requireNamespace("SingleCellExperiment") && ...)
