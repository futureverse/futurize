# fwb::fwb(...) =>
#
# local({
#   fwb::fwb(..., cl = "future")
# })
#
append_transpilers_for_fwb <- function() {
  package <- "fwb"

  template <- quote(
    local({
      EXPR
    })
  )

  idx_EXPR <- c(2, 2)

  transpiler <- eval(bquote(function(expr, options = NULL) {
    ## Update 'EXPR'
    parts <- c(
      as.list(expr),
      cl = "future"
    )
    template[[idx_EXPR]] <- as.call(parts)

    template
  }))
  body(transpiler) <- body(transpiler)

  transpilers <- list()

  ns <- getNamespace(package)
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- exports
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
      fcn <- get(name, mode = "function", envir = ns, inherits = FALSE)
      if ("cl" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("%s::%s() ~> %s::%s(..., cl = \"future\")", package, name, package, name),
          transpiler = transpiler
        )
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c(package, "future")
}
