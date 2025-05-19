# BiocParallel::bplapply(xs, fcn) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   BiocParallel::bplapply(xs, fcn, BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_BiocParallel <- function() {
  template <- quote(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), (EXPR))
  )

  make_options <- function(options) {
    options
  }

  transpiler <- eval(bquote(function(expr, options = NULL) {
    parts <- c(
      as.list(expr),
      BPPARAM = BiocParallel::DoparParam()
    )
    template[[3]][[2]] <- as.call(parts)
    template
  }))
  body(transpiler) <- body(transpiler)

  transpilers <- list()

  ns <- getNamespace("BiocParallel")
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- exports
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
      fcn <- get(name, mode = "function", envir = ns, inherits = FALSE)
      if ("BPPARAM" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("BiocParallel::%s() ~> BiocParallel::%s(..., BPPARAM = BiocParallel::DoparParam())", name, name),
          transpiler = transpiler
        )
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "BiocParallel"

  append_transpilers("add-on", transpilers)

  ## Return required packages
  c("BiocParallel", "doFuture")
}
