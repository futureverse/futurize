# Rsamtools::countBam(bamViews, ...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   Rsamtools::countBam(bamViews, ..., BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_Rsamtools <- function() {
  ## These Rsamtools functions accept BPPARAM via '...' (S4 generics).
  ## Parallelization occurs when the input is a BamViews object,
  ## which distributes work across BAM files via bplapply().
  names <- c(
    "countBam",
    "scanBam"
  )

  ns <- getNamespace("Rsamtools")
  transpilers <- list()
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = TRUE)) {
      args <- list(BPPARAM = quote(BiocParallel::DoparParam()))
      transpilers[[name]] <- list(
        label = sprintf("Rsamtools::%s() ~> Rsamtools::%s(..., BPPARAM = BiocParallel::DoparParam())", name, name),
        transpiler = make_futurize_for_doFuture(
          args = args,
          defaults = list(label = sprintf("fz:Rsamtools::%s-%%d", name))
        )
      )
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "Rsamtools"

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("Rsamtools", "BiocParallel", "doFuture")
}
