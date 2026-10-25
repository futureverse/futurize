#' @tags skip_on_cran  ## (20s) to limit total check time
if (requireNamespace("GSVA") && requireNamespace("doFuture")) {
library(futurize)
library(GSVA)
fcns <- tryCatch({
  futurize::futurize_supported_functions("GSVA")
}, error = identity)
print(fcns)
stopifnot(is.character(fcns), length(fcns) > 0L)
print(sessionInfo())

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

## GSVA (>= 2.7.0 & < 2.7.25) is not supported. As of GSVA (>= 2.7.25),
## support is back, with an additional check for early 2.7.25 builds.
## https://github.com/futureverse/futurize/issues/14
gsva_doparparam_broken <- (utils::packageVersion("GSVA") >= "2.7.0") &&
  (utils::packageVersion("GSVA") < "2.7.25" ||
   exists(".gsva_bpiterate", envir = asNamespace("GSVA"), inherits = FALSE))

if (gsva_doparparam_broken) {
  param <- gsvaParam(expr, geneSets)
  gsvarnorm <- gsvaRowNorm(param, verbose = FALSE)
  gsvaranks <- gsvaColRanks(gsvarnorm, verbose = FALSE)

  assert_not_supported <- function(res) {
    stopifnot(inherits(res, "error"))
    stopifnot(grepl("futurize[(][)] does not support", conditionMessage(res)))
  }

  res <- tryCatch({
    gsva(param, verbose = FALSE) |> futurize()
  }, error = identity)
  assert_not_supported(res)

  res <- tryCatch({
    gsvaRowNorm(param, verbose = FALSE) |> futurize()
  }, error = identity)
  assert_not_supported(res)

  res <- tryCatch({
    gsvaColRanks(gsvarnorm, verbose = FALSE) |> futurize()
  }, error = identity)
  assert_not_supported(res)

  res <- tryCatch({
    gsvaColScores(gsvaranks, geneSets(param), verbose = FALSE) |> futurize()
  }, error = identity)
  assert_not_supported(res)
}

## gsva() in GSVA (< 2.4) relies on BiocParallel::bpiterate(),
## which does _not_ support DoparParam by design.
if (!gsva_doparparam_broken && "gsva" %in% futurize_supported_functions("GSVA")) {
  ## ---------------------------------------------------------
  ## gsva() with gsvaParam()
  ## ---------------------------------------------------------
  param <- gsvaParam(expr, geneSets)
  
  set.seed(42)
  result_truth <- gsva(param, verbose = FALSE)
  str(result_truth)
  
  set.seed(42)
  result <- gsva(param, verbose = FALSE) |> futurize_and_verify()
  str(result)
  stopifnot(all.equal(result, result_truth))
  
  set.seed(42)
  result2 <- GSVA::gsva(param, verbose = FALSE) |> futurize_and_verify()
  stopifnot(all.equal(result2, result_truth))


  ## ---------------------------------------------------------
  ## gsva() with ssgseaParam()
  ## ---------------------------------------------------------
  param_ssgsea <- ssgseaParam(expr, geneSets)
  
  set.seed(42)
  result_truth <- gsva(param_ssgsea, verbose = FALSE)
  str(result_truth)
  
  set.seed(42)
  result <- gsva(param_ssgsea, verbose = FALSE) |> futurize_and_verify()
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
  result <- gsva(param_plage, verbose = FALSE) |> futurize_and_verify()
  str(result)
  stopifnot(all.equal(result, result_truth))
} ## if ("gsva" %in% futurize_supported_functions("GSVA"))

## gsvaRowNorm(), gsvaColRanks(), and gsvaColScores() replace
## deprecated gsvaRanks() and gsvaScores() as of GSVA (>= 2.7.25)
## https://github.com/futureverse/futurize/issues/14
if (!gsva_doparparam_broken && "gsvaColRanks" %in% futurize_supported_functions("GSVA")) {
  ## ---------------------------------------------------------
  ## gsvaRowNorm() + gsvaColRanks() + gsvaColScores()
  ## ---------------------------------------------------------
  param <- gsvaParam(expr, geneSets)

  set.seed(42)
  rnorm_truth <- gsvaRowNorm(param, verbose = FALSE)
  ranks_truth <- gsvaColRanks(rnorm_truth, verbose = FALSE)
  result_truth <- gsvaColScores(ranks_truth, geneSets(param), verbose = FALSE)
  str(result_truth)

  set.seed(42)
  rnorm <- gsvaRowNorm(param, verbose = FALSE) |> futurize_and_verify()
  ranks <- gsvaColRanks(rnorm, verbose = FALSE) |> futurize_and_verify()
  result <- gsvaColScores(ranks, geneSets(param), verbose = FALSE) |> futurize_and_verify()
  str(result)
  stopifnot(all.equal(result, result_truth))
} ## if ("gsvaColRanks" %in% futurize_supported_functions("GSVA"))

plan(sequential)
} ## if (requireNamespace("GSVA") && ...)
