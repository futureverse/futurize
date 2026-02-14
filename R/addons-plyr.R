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

  transpilers <- make_package_transpilers(package, FUN = function(fcn, package, name) {
    if (".parallel" %in% names(formals(fcn))) {
      list(
        label = sprintf("%s::%s() ~> %s::%s(..., parallel = TRUE)", package, name, package, name),
        transpiler = transpiler
      )
    }
  })

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c(package, "doFuture")
}
