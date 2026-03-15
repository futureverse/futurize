# GSVA::gsva(gsvaParam(expr, geneSets)) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   GSVA::gsva(gsvaParam(expr, geneSets), BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_GSVA <- function() {
  ## These GSVA functions accept BPPARAM via '...' (S4 generics)
  names <- c(
    "gsva",
    "gsvaRanks", "gsvaScores",
    "spatCor"
  )

  ns <- getNamespace("GSVA")
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
