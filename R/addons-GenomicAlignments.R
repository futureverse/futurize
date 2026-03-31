# GenomicAlignments::summarizeOverlaps(features, reads) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   GenomicAlignments::summarizeOverlaps(features, reads, BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_GenomicAlignments <- function() {
  ## These GenomicAlignments functions accept BPPARAM via '...'
  ## (S4 generics)
  names <- c(
    "summarizeOverlaps"
  )

  ns <- getNamespace("GenomicAlignments")
  transpilers <- list()
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = TRUE)) {
      args <- list(BPPARAM = quote(BiocParallel::DoparParam()))
      transpilers[[name]] <- list(
        label = sprintf("GenomicAlignments::%s() ~> GenomicAlignments::%s(..., BPPARAM = BiocParallel::DoparParam())", name, name),
        transpiler = make_futurize_for_doFuture(
          args = args,
          defaults = list(label = sprintf("fz:GenomicAlignments::%s-%%d", name))
        )
      )
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "GenomicAlignments"

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("GenomicAlignments", "BiocParallel", "doFuture")
}
