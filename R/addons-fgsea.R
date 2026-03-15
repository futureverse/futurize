# fgsea::fgsea(pathways, stats) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   fgsea::fgsea(pathways, stats, BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_fgsea <- function() {
  ## These fgsea functions accept BPPARAM directly or via '...'
  names <- c(
    "fgsea",
    "fgseaMultilevel", "fgseaSimple", "fgseaLabel",
    "geseca", "gesecaSimple",
    "collapsePathwaysGeseca"
  )

  ns <- getNamespace("fgsea")
  transpilers <- list()
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = TRUE)) {
      args <- list(BPPARAM = quote(BiocParallel::DoparParam()))
      transpilers[[name]] <- list(
        label = sprintf("fgsea::%s() ~> fgsea::%s(..., BPPARAM = BiocParallel::DoparParam())", name, name),
        transpiler = make_futurize_for_doFuture(args = args)
      )
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "fgsea"

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("fgsea", "BiocParallel", "doFuture")
}
