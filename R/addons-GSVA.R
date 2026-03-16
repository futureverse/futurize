# GSVA::gsva(gsvaParam(expr, geneSets)) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   GSVA::gsva(gsvaParam(expr, geneSets), BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_GSVA <- function() {
  ns <- getNamespace("GSVA")
  
  ## These GSVA functions accept BPPARAM via '...' (S4 generics)
  names <- c(
    ## gsva() in GSVA (< 2.4) relies on BiocParallel::bpiterate()
    ## which does _not_ support DoparParam by design.
    if (getNamespaceVersion(ns) >= "2.4") "gsva",
    "gsvaRanks", "gsvaScores",
    "spatCor"
  )
  
  transpilers <- list()
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = TRUE)) {
      args <- list(BPPARAM = quote(BiocParallel::DoparParam()))
      transpilers[[name]] <- list(
        label = sprintf("GSVA::%s() ~> GSVA::%s(..., BPPARAM = BiocParallel::DoparParam())", name, name),
        transpiler = make_futurize_for_doFuture(args = args)
      )
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "GSVA"

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("GSVA", "BiocParallel", "doFuture")
}
