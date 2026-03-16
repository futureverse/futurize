# SingleCellExperiment::applySCE(sce, FUN, ...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   SingleCellExperiment::applySCE(sce, FUN, ..., BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_SingleCellExperiment <- function() {
  names <- c(
    "applySCE"
  )

  ns <- getNamespace("SingleCellExperiment")
  transpilers <- list()
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = TRUE)) {
      args <- list(BPPARAM = quote(BiocParallel::DoparParam()))
      transpilers[[name]] <- list(
        label = sprintf("SingleCellExperiment::%s() ~> SingleCellExperiment::%s(..., BPPARAM = BiocParallel::DoparParam())", name, name),
        transpiler = make_futurize_for_doFuture(args = args)
      )
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "SingleCellExperiment"

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("SingleCellExperiment", "BiocParallel", "doFuture")
}
