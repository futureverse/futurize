if (requireNamespace("GSVA") && requireNamespace("doFuture")) {
library(futurize)
library(GSVA)
options(future.rng.onMisuse = "error")

plan(multisession)

## Create simple test data
set.seed(42)
n_genes <- 120L    # > 100 for gsva() to parallelize
n_samples <- 120L  # > 100 for gsva() to parallelize
expr <- matrix(rnorm(n_genes * n_samples), nrow = n_genes, ncol = n_samples)
rownames(expr) <- paste0("gene", seq_len(n_genes))
colnames(expr) <- paste0("sample", seq_len(n_samples))

geneSets <- list(
  geneSet1 = paste0("gene", sample(n_genes, 10L)),
  geneSet2 = paste0("gene", sample(n_genes, 15L)),
  geneSet3 = paste0("gene", sample(n_genes, 20L))
)


## ---------------------------------------------------------
## gsva() with gsvaParam()
## ---------------------------------------------------------
param <- gsvaParam(expr, geneSets)

set.seed(42)
result_truth <- gsva(param, verbose = FALSE)
str(result_truth)

set.seed(42)
result <- gsva(param, verbose = FALSE) |> futurize()
str(result)
stopifnot(all.equal(result, result_truth))

set.seed(42)
result2 <- GSVA::gsva(param, verbose = FALSE) |> futurize()
stopifnot(all.equal(result2, result_truth))


## ---------------------------------------------------------
## gsva() with ssgseaParam()
## ---------------------------------------------------------
param_ssgsea <- ssgseaParam(expr, geneSets)

set.seed(42)
result_truth <- gsva(param_ssgsea, verbose = FALSE)
str(result_truth)

set.seed(42)
result <- gsva(param_ssgsea, verbose = FALSE) |> futurize()
str(result)
stopifnot(all.equal(result, result_truth))


## ---------------------------------------------------------
## gsva() with plageParam()
## ---------------------------------------------------------
param_plage <- plageParam(expr, geneSets)

set.seed(42)
result_truth <- gsva(param_plage, verbose = FALSE)
str(result_truth)

set.seed(42)
result <- gsva(param_plage, verbose = FALSE) |> futurize()
str(result)
stopifnot(all.equal(result, result_truth))


plan(sequential)
} ## if (requireNamespace("GSVA") && ...)
