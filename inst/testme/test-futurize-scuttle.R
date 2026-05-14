#' @tags skip_on_cran  ## (35s) to limit total check time
if (requireNamespace("scuttle") && requireNamespace("doFuture") && requireNamespace("DelayedArray")) {
library(futurize)
library(scuttle)

## Use a small block size to ensure multiple blocks and thus multiple futures
DelayedArray::setAutoBlockSize(10000)

plan(multisession)

## Create a simple SingleCellExperiment
set.seed(42)
sce <- mockSCE(ncells = 20L, ngenes = 70L, nspikes = 30L)

## ---------------------------------------------------------
## perFeatureQCMetrics()
## ---------------------------------------------------------
result_truth <- perFeatureQCMetrics(sce)

result <- perFeatureQCMetrics(sce) |> futurize_and_verify()
stopifnot(all.equal(result, result_truth))

plan(sequential)
} ## if (requireNamespace("scuttle") && ...)
