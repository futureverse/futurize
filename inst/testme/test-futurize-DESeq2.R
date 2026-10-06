#' @tags pkg-DESeq2
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
result <- DESeq(dds) |> futurize_and_verify()
print(result)
stopifnot(all.equal(results(result), results(result_truth)))

set.seed(42)
result2 <- DESeq2::DESeq(dds) |> futurize_and_verify()
stopifnot(all.equal(results(result2), results(result_truth)))

## With DESeq2 attached, so is BiocGenerics, which masks base::lapply()
## with an S4 generic. The S4 dispatch argument must be evaluated only
## once, also when it is not a variable
stopifnot(methods::is(lapply, "standardGeneric"))
n_calls <- 0L
make_xs <- function() {
  n_calls <<- n_calls + 1L
  1:3
}
y_truth <- base::lapply(1:3, sqrt)
y <- lapply(1:3, sqrt) |> futurize_and_verify()
stopifnot(identical(y, y_truth))
y <- lapply(make_xs(), sqrt) |> futurize_and_verify()
stopifnot(identical(y, y_truth), n_calls == 1L)

## An S4 method that is not supported, here lapply() for an S4Vectors
## 'List', should give an informative error naming the method's package,
## and suggest using base::lapply()
x <- S4Vectors::List(a = 1:3, b = 4:6)
res <- tryCatch(lapply(x, sum) |> futurize(), error = identity)
print(res)
stopifnot(
  inherits(res, "error"),
  grepl("S4Vectors", conditionMessage(res), fixed = TRUE),
  grepl("base::lapply()", conditionMessage(res), fixed = TRUE)
)

plan(sequential)
} ## if (requireNamespace("DESeq2") && ...)
