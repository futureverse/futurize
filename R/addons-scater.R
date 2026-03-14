# scater::runPCA(sce) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   scater::runPCA(sce, BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_scater <- function() {
  ## These scater functions accept BPPARAM via '...' (S4 generics) or
  ## directly in their formals
  names <- c(
    "calculatePCA", "calculateTSNE", "calculateUMAP",
    "runPCA", "runTSNE", "runUMAP",
    "runColDataPCA",
    "nexprs",
    "getVarianceExplained",
    "plotRLE"
  )

  ns <- getNamespace("scater")
  transpilers <- list()
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = TRUE)) {
      args <- list(BPPARAM = quote(BiocParallel::DoparParam()))
      transpilers[[name]] <- list(
        label = sprintf("scater::%s() ~> scater::%s(..., BPPARAM = BiocParallel::DoparParam())", name, name),
        transpiler = make_futurize_for_doFuture(args = args)
      )
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "scater"

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("scater", "BiocParallel", "doFuture")
}
