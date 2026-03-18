#' @tags skip_on_cran  ## (35s) to limit total check time
if (requireNamespace("DESeq2") && requireNamespace("doFuture")) {
library(futurize)
library(DESeq2)
options(future.rng.onMisuse = "error")

plan(multisession)

## Create a simple DESeqDataSet
set.seed(42)
n_genes <- 30L
n_samples <- 4L
counts <- matrix(
  as.integer(runif(n_genes * n_samples, min = 0, max = 1000)),
  nrow = n_genes,
  ncol = n_samples
)
rownames(counts) <- paste0("gene", seq_len(n_genes))
colnames(counts) <- paste0("sample", seq_len(n_samples))

col_data <- data.frame(
  condition = factor(rep(c("control", "treated"), each = n_samples / 2L)),
  row.names = colnames(counts)
)

dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = col_data,
  design = ~ condition
)


## ---------------------------------------------------------
## DESeq()
## ---------------------------------------------------------
set.seed(42)
result_truth <- DESeq(dds)
print(result_truth)

set.seed(42)
counters <- plan("backend")[["counters"]]
result <- DESeq(dds) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(result)
stopifnot(all.equal(results(result), results(result_truth)))

set.seed(42)
counters <- plan("backend")[["counters"]]
result2 <- DESeq2::DESeq(dds) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(all.equal(results(result2), results(result_truth)))

plan(sequential)
} ## if (requireNamespace("DESeq2") && ...)
