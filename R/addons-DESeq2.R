# DESeq2::DESeq(dds) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   DESeq2::DESeq(dds, parallel = TRUE, BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_DESeq2 <- function() {
  transpilers <- make_package_transpilers("DESeq2", FUN = function(fcn, name) {
    if ("BPPARAM" %in% names(formals(fcn))) {
      args <- list(BPPARAM = quote(BiocParallel::DoparParam()))
      if ("parallel" %in% names(formals(fcn))) {
        args <- c(list(parallel = TRUE), args)
      }
      transpilers[[name]] <- list(
        label = sprintf("DESeq2::%s() ~> DESeq2::%s(..., parallel = TRUE, BPPARAM = BiocParallel::DoparParam())", name, name),
        transpiler = make_futurize_for_doFuture(
          args = args,
          defaults = list(label = sprintf("fz:DESeq2::%s-%%d", name))
        )
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("DESeq2", "BiocParallel", "doFuture")
}
