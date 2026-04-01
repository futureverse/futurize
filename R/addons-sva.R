# sva::ComBat(dat, batch, mod) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   sva::ComBat(dat, batch, mod, BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_sva <- function() {
  ## These sva functions accept BPPARAM directly in their formals
  names <- c(
    "ComBat",
    "read.degradation.matrix"
  )

  ns <- getNamespace("sva")
  transpilers <- list()
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = TRUE)) {
      args <- list(BPPARAM = quote(BiocParallel::DoparParam()))
      transpilers[[name]] <- list(
        label = sprintf("sva::%s() ~> sva::%s(..., BPPARAM = BiocParallel::DoparParam())", name, name),
        transpiler = make_futurize_for_doFuture(
          args = args,
          defaults = list(label = sprintf("fz:sva::%s-%%d", name))
        )
      )
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "sva"

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("sva", "BiocParallel", "doFuture")
}
