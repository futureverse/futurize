# plyr::llply(xs, fcn) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), 
#   plyr::llply(xs, fcn,
#     .parallel = TRUE,
#     .paropts = list(.options.future = <future arguments>)
#   )
# )
#
append_transpilers_for_plyr <- function() {
  package <- "plyr"
  
  template <- bquote_compile(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), (.(EXPR)))
  )

  transpiler <- function(expr, options = NULL) {
    options <- make_options_for_doFuture(options, wrap = TRUE)
    expr <- append_call_arguments(expr,
      .parallel = TRUE,
      .paropts = options
    )
    bquote_apply(template, EXPR = expr)
  }
  body(transpiler) <- body(transpiler)

  transpilers <- list()

  ns <- getNamespace(package)
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- exports
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
      fcn <- get(name, mode = "function", envir = ns, inherits = FALSE)
      if (".parallel" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("%s::%s() ~> %s::%s(..., parallel = TRUE)", package, name, package, name),
          transpiler = transpiler
        )
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c(package, "doFuture")
}
